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
  }

  update(dt, zombies, bullets) {
    if (!this.alive || this.type !== DEFENSE_TYPE.TURRET) return;
    const cfg = CONFIG.defense.turret;
    this.cooldown = Math.max(0, this.cooldown - dt);
    if (this.cooldown > 0) return;

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
    if (!target) return;

    const a = Math.atan2(target.y - this.y, target.x - this.x);
    bullets.push({
      x: this.x + Math.cos(a) * (this.r + 4),
      y: this.y + Math.sin(a) * (this.r + 4),
      vx: Math.cos(a) * cfg.bulletSpeed,
      vy: Math.sin(a) * cfg.bulletSpeed,
      life: 1.1,
      damage: cfg.damage,
      r: 3,
      fromDefense: true
    });
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
    ctx.save();
    ctx.translate(this.x, this.y);
    if (this.type === DEFENSE_TYPE.TURRET) {
      ctx.fillStyle = "#33220f";
      ctx.beginPath();
      ctx.arc(0, 0, this.r, 0, Math.PI * 2);
      ctx.fill();
      ctx.fillStyle = this.color;
      ctx.fillRect(-5, -22, 10, 26);
      ctx.beginPath();
      ctx.arc(0, 0, this.r * 0.55, 0, Math.PI * 2);
      ctx.fill();
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
