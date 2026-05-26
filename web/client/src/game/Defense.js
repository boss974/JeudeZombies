import { CONFIG } from "../../../shared/config.js";
import { DEFENSE_TYPE } from "../../../shared/constants.js";

export class Defense {
  constructor(x, y, type) {
    const cfg = CONFIG.defense[type];
    this.x = x;
    this.y = y;
    this.type = type;
    this.r = cfg.radius;
    this.hp = cfg.hp || 1;
    this.maxHp = this.hp;
    this.cooldown = 0;
    this.alive = true;
    this.color = cfg.color;
    // Anim tourelle : angle du canon, phase de recul, puffs de fumée, LED de scan
    this.aimAngle = 0;            // direction du canon (suit la cible si elle existe)
    this.recoil = 0;               // 0..1, décroît après chaque tir
    this.smoke = [];               // bouffées { x, y, r, life }
    this.scanPulse = 0;            // 0..1, sinusoidal pour LED "scan" sans cible
    this.hasTarget = false;        // pour différencier LED scan (verte) / aim (rouge)
    this.deployT = 0.4;            // durée d'animation "apparition" au placement
  }

  update(dt, zombies, bullets) {
    // Anim d'apparition + LED + recul (commun aux 2 types)
    if (this.deployT > 0) this.deployT = Math.max(0, this.deployT - dt);
    this.recoil = Math.max(0, this.recoil - dt * 5);    // recul revient en 0.2s
    this.scanPulse = (this.scanPulse + dt * 2.5) % (Math.PI * 2);
    // Update puffs de fumée
    for (const p of this.smoke) {
      p.life -= dt;
      p.r += dt * 22;            // grandit en montant
      p.y -= dt * 18;            // monte doucement
    }
    this.smoke = this.smoke.filter(p => p.life > 0);

    if (!this.alive || this.type !== DEFENSE_TYPE.TURRET) return;
    const cfg = CONFIG.defense.turret;
    this.cooldown = Math.max(0, this.cooldown - dt);

    // Cherche la cible la plus proche (pour orienter le canon même hors fire)
    let target = null;
    let best = cfg.range * cfg.range;
    for (const z of zombies) {
      if (!z.alive) continue;
      const dx = z.x - this.x;
      const dy = z.y - this.y;
      const d2 = dx * dx + dy * dy;
      if (d2 < best) {
        best = d2;
        target = z;
      }
    }
    this.hasTarget = !!target;
    if (target) {
      // Oriente le canon (suivi avec interpolation pour fluidité)
      const wanted = Math.atan2(target.y - this.y, target.x - this.x);
      // Tween d'angle court (lerp angulaire simple)
      const diff = ((wanted - this.aimAngle + Math.PI * 3) % (Math.PI * 2)) - Math.PI;
      this.aimAngle += diff * Math.min(1, dt * 12);
    }

    if (this.cooldown > 0 || !target) return;

    const a = this.aimAngle;     // tire dans la direction effective du canon
    bullets.push({
      x: this.x + Math.cos(a) * (this.r + 4),
      y: this.y + Math.sin(a) * (this.r + 4),
      vx: Math.cos(a) * cfg.bulletSpeed,
      vy: Math.sin(a) * cfg.bulletSpeed,
      life: 1.1,
      damage: cfg.damage,
      r: 3,
      fromDefense: true,
      weapon: "turret"            // pour le rendu des trails (jaune doré dédié)
    });
    // FX de tir : recul + bouffée de fumée à la sortie du canon
    this.recoil = 1;
    const muzzleX = this.x + Math.cos(a) * (this.r + 8);
    const muzzleY = this.y + Math.sin(a) * (this.r + 8);
    this.smoke.push({ x: muzzleX, y: muzzleY, r: 4 + Math.random() * 3, life: 0.45 });
    if (Math.random() < 0.5) {
      // 2e petite bouffée latérale pour donner du volume
      this.smoke.push({
        x: muzzleX + (Math.random() - 0.5) * 6,
        y: muzzleY + (Math.random() - 0.5) * 6,
        r: 3, life: 0.3
      });
    }
    this.cooldown = cfg.fireRate;
  }

  hit(amount) {
    if (this.type !== DEFENSE_TYPE.BARRICADE) return false;
    this.hp -= amount;
    if (this.hp <= 0) this.alive = false;
    return true;
  }

  draw(ctx) {
    if (!this.alive) return;

    // 1) Puffs de fumée d'abord (sous la tourelle pour pas la masquer)
    for (const p of this.smoke) {
      const alpha = (p.life / 0.45) * 0.7;
      ctx.fillStyle = `rgba(220,210,200,${alpha})`;
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
      ctx.fill();
    }

    ctx.save();
    ctx.translate(this.x, this.y);
    // Effet "pop-in" au placement (scale qui monte de 0.5 à 1.0)
    if (this.deployT > 0) {
      const t = 1 - (this.deployT / 0.4);
      const s = 0.5 + 0.5 * t + Math.sin(t * Math.PI) * 0.15;  // overshoot léger
      ctx.scale(s, s);
    }
    if (this.type === DEFENSE_TYPE.TURRET) {
      // Base : disque sombre avec petit bord plus clair
      ctx.fillStyle = "#33220f";
      ctx.beginPath();
      ctx.arc(0, 0, this.r, 0, Math.PI * 2);
      ctx.fill();
      ctx.strokeStyle = "#5a3a1a";
      ctx.lineWidth = 2;
      ctx.stroke();

      // Canon orientable avec recul (rotation = aimAngle - PI/2 car canon dessiné vers le haut)
      ctx.save();
      ctx.rotate(this.aimAngle + Math.PI / 2);  // PI/2 car le canon de base pointe vers le haut
      const recoilOffset = this.recoil * 4;       // déplacement du canon vers l'arrière au tir
      ctx.fillStyle = this.color;
      ctx.fillRect(-5, -22 + recoilOffset, 10, 26);
      // Petite bouche du canon (cercle clair en bout)
      ctx.fillStyle = "#1a0e08";
      ctx.beginPath();
      ctx.arc(0, -20 + recoilOffset, 2.5, 0, Math.PI * 2);
      ctx.fill();
      ctx.restore();

      // Disque central rotatif (chapeau du mécanisme)
      ctx.fillStyle = this.color;
      ctx.beginPath();
      ctx.arc(0, 0, this.r * 0.55, 0, Math.PI * 2);
      ctx.fill();

      // LED de scan : verte qui pulse sans cible, rouge fixe brillant avec cible
      const ledR = 3;
      if (this.hasTarget) {
        // Rouge : LED brillante stable
        ctx.fillStyle = "#ff4040";
        ctx.beginPath();
        ctx.arc(0, 0, ledR, 0, Math.PI * 2);
        ctx.fill();
        // Halo rouge léger
        ctx.fillStyle = "rgba(255,80,80,0.4)";
        ctx.beginPath();
        ctx.arc(0, 0, ledR * 2.2, 0, Math.PI * 2);
        ctx.fill();
      } else {
        // Verte : pulse en sinusoidal (alpha varie)
        const pulse = (Math.sin(this.scanPulse) + 1) * 0.5;     // 0..1
        ctx.fillStyle = `rgba(110,216,122,${0.55 + pulse * 0.4})`;
        ctx.beginPath();
        ctx.arc(0, 0, ledR, 0, Math.PI * 2);
        ctx.fill();
      }
    } else {
      ctx.fillStyle = this.color;
      ctx.fillRect(-this.r, -this.r * 0.55, this.r * 2, this.r * 1.1);
      ctx.strokeStyle = "#3a220f";
      ctx.lineWidth = 4;
      ctx.beginPath();
      ctx.moveTo(-this.r + 5, -this.r * 0.45);
      ctx.lineTo(this.r - 5, this.r * 0.45);
      ctx.moveTo(-this.r + 5, this.r * 0.45);
      ctx.lineTo(this.r - 5, -this.r * 0.45);
      ctx.stroke();
      if (this.hp < this.maxHp) {
        ctx.fillStyle = "#000";
        ctx.fillRect(-this.r, -this.r - 9, this.r * 2, 4);
        ctx.fillStyle = "#6ed87a";
        ctx.fillRect(-this.r, -this.r - 9, this.r * 2 * (this.hp / this.maxHp), 4);
      }
    }
    ctx.restore();
  }
}
