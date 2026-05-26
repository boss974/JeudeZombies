import { CONFIG } from "../../../shared/config.js";

// Le joueur. Garde l'API simple : update, draw, hit, fire.
// Sprite cartoon : corps + tête + bras + jambes + canon. Animation de marche
// basée sur le temps écoulé et le mouvement réel (oscillation des jambes).
export class Player {
  constructor(x, y) {
    this.x = x;
    this.y = y;
    this.r = CONFIG.player.radius;
    this.hp = CONFIG.player.maxHp;
    this.maxHp = CONFIG.player.maxHp;
    this.aim = 0;            // angle en radians
    this.cooldown = 0;
    this.invuln = 0;
    this.alive = true;
    // Multiplicateurs de stats appliqués par GameScene (upgrades permanents +
    // buffs temporaires des pickups). Défaut 1 = pas d'effet.
    this.speedMul = 1;
    this.fireRateMul = 1;
    // État d'animation
    this._walkPhase = 0;     // 0..1, avance quand on bouge
    this._moving = false;
  }

  update(dt, input, arena) {
    if (!this.alive) return;

    const ax = input.axis();
    const speed = CONFIG.player.speed * (this.speedMul || 1);
    const dx = ax.x * speed * dt;
    const dy = ax.y * speed * dt;
    this.x += dx;
    this.y += dy;

    // Détecte le mouvement pour animer les jambes
    this._moving = Math.abs(ax.x) > 0.01 || Math.abs(ax.y) > 0.01;
    if (this._moving) {
      this._walkPhase = (this._walkPhase + dt * 6) % (Math.PI * 2);
    } else {
      // Retour doux à 0 pour stopper les jambes proprement
      this._walkPhase *= 0.85;
    }

    // Clamp à l'arène
    const pad = CONFIG.arena.padding + this.r;
    this.x = Math.max(pad, Math.min(arena.width - pad, this.x));
    this.y = Math.max(pad, Math.min(arena.height - pad, this.y));

    this.aim = Math.atan2(input.mouse.y - this.y, input.mouse.x - this.x);

    this.cooldown = Math.max(0, this.cooldown - dt);
    this.invuln = Math.max(0, this.invuln - dt);
  }

  canFire() { return this.alive && this.cooldown <= 0; }

  fire() {
    this.cooldown = CONFIG.player.fireRate * (this.fireRateMul || 1);
    return {
      x: this.x + Math.cos(this.aim) * (this.r + 10),
      y: this.y + Math.sin(this.aim) * (this.r + 10),
      vx: Math.cos(this.aim) * CONFIG.player.bulletSpeed,
      vy: Math.sin(this.aim) * CONFIG.player.bulletSpeed,
      life: CONFIG.player.bulletLifetime,
      damage: CONFIG.player.bulletDamage,
      r: 3
    };
  }

  hit(damage) {
    if (this.invuln > 0 || !this.alive) return false;
    this.hp -= damage;
    this.invuln = CONFIG.player.invulnAfterHit;
    if (this.hp <= 0) {
      this.hp = 0;
      this.alive = false;
    }
    return true;
  }

  // time : timestamp en secondes (pour animations indépendantes du mouvement)
  draw(ctx, time = 0) {
    // Couleurs Réunion : bleu lagon corps, jaune cannelle accents
    const bodyColor = "#0099b8";       // Bleu Lagon (corps principal)
    const accentColor = "#f4b942";     // Jaune Cannelle (bandana, équipement)
    const skinColor = "#e8b48a";       // Peau légèrement bronzée
    const pantsColor = "#2a3a4a";      // Pantalon sombre

    // Clignote en invulnérabilité (flash blanc)
    const blink = this.invuln > 0 && Math.floor(this.invuln * 20) % 2 === 0;

    ctx.save();
    ctx.translate(this.x, this.y);

    // Ombre au sol (ellipse sombre semi-transparente)
    ctx.fillStyle = "rgba(0,0,0,0.35)";
    ctx.beginPath();
    ctx.ellipse(0, this.r + 4, this.r * 0.9, this.r * 0.3, 0, 0, Math.PI * 2);
    ctx.fill();

    // Oscillation des jambes (deux barres animées)
    const legSwing = Math.sin(this._walkPhase) * 4;
    ctx.strokeStyle = pantsColor;
    ctx.lineWidth = 4;
    ctx.lineCap = "round";
    // Jambe gauche
    ctx.beginPath();
    ctx.moveTo(-4, this.r - 2);
    ctx.lineTo(-4 - legSwing * 0.4, this.r + 8);
    ctx.stroke();
    // Jambe droite
    ctx.beginPath();
    ctx.moveTo(4, this.r - 2);
    ctx.lineTo(4 + legSwing * 0.4, this.r + 8);
    ctx.stroke();

    // Corps (rectangle arrondi)
    ctx.fillStyle = blink ? "#ffffff" : bodyColor;
    ctx.beginPath();
    ctx.roundRect ? ctx.roundRect(-this.r * 0.75, -this.r * 0.2, this.r * 1.5, this.r * 1.2, 4)
                  : ctx.rect(-this.r * 0.75, -this.r * 0.2, this.r * 1.5, this.r * 1.2);
    ctx.fill();

    // Ceinture jaune cannelle (accent)
    ctx.fillStyle = accentColor;
    ctx.fillRect(-this.r * 0.75, this.r * 0.6, this.r * 1.5, 3);

    // Tête (cercle peau)
    ctx.fillStyle = blink ? "#ffffff" : skinColor;
    ctx.beginPath();
    ctx.arc(0, -this.r * 0.5, this.r * 0.55, 0, Math.PI * 2);
    ctx.fill();

    // Bandana jaune (bande au-dessus du front)
    ctx.fillStyle = accentColor;
    ctx.fillRect(-this.r * 0.5, -this.r * 0.85, this.r * 1.0, 3);
    // Pointe du bandana qui flotte
    ctx.beginPath();
    ctx.moveTo(this.r * 0.5, -this.r * 0.85);
    ctx.lineTo(this.r * 0.7 + Math.sin(time * 3) * 1.5, -this.r * 0.65);
    ctx.lineTo(this.r * 0.5, -this.r * 0.78);
    ctx.closePath();
    ctx.fill();

    // Yeux (deux petits points noirs)
    ctx.fillStyle = "#1a1a1a";
    ctx.beginPath();
    ctx.arc(-3, -this.r * 0.5, 1.5, 0, Math.PI * 2);
    ctx.arc(3, -this.r * 0.5, 1.5, 0, Math.PI * 2);
    ctx.fill();

    // Bras gauche (côté opposé au tir, suit le balancier de marche)
    ctx.strokeStyle = bodyColor;
    ctx.lineWidth = 4;
    ctx.beginPath();
    ctx.moveTo(-this.r * 0.7, 0);
    ctx.lineTo(-this.r * 0.7 - legSwing * 0.3, this.r * 0.6);
    ctx.stroke();

    // Arme : canon qui sort dans la direction visée (par-dessus le corps)
    ctx.rotate(this.aim);
    // Bras qui tient l'arme
    ctx.strokeStyle = bodyColor;
    ctx.lineWidth = 4;
    ctx.beginPath();
    ctx.moveTo(0, 0);
    ctx.lineTo(this.r * 0.6, 0);
    ctx.stroke();
    // Canon (rectangle métallique)
    ctx.fillStyle = "#1a2a36";
    ctx.fillRect(this.r * 0.5, -3, this.r * 0.9, 6);
    // Reflet sur le canon
    ctx.fillStyle = "#3a4a5a";
    ctx.fillRect(this.r * 0.5, -3, this.r * 0.9, 1.5);
    // Bout du canon (cercle plus large)
    ctx.fillStyle = "#0e1418";
    ctx.beginPath();
    ctx.arc(this.r * 1.4, 0, 3, 0, Math.PI * 2);
    ctx.fill();
    // Flash de tir : éclair orange quand le cooldown vient de démarrer
    if (this.cooldown > CONFIG.player.fireRate * 0.7) {
      ctx.fillStyle = "rgba(255,107,53,0.85)";
      ctx.beginPath();
      ctx.arc(this.r * 1.5, 0, 5 + Math.random() * 2, 0, Math.PI * 2);
      ctx.fill();
      ctx.fillStyle = "rgba(255,230,160,0.95)";
      ctx.beginPath();
      ctx.arc(this.r * 1.5, 0, 2.5, 0, Math.PI * 2);
      ctx.fill();
    }

    ctx.restore();
  }
}
