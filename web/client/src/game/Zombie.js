import { CONFIG } from "../../../shared/config.js";

// Zombie générique paramétré par type. Logique partagée pour Roblox plus tard.
export class Zombie {
  constructor(x, y, type) {
    const stats = CONFIG.zombie[type];
    this.type = type;
    this.x = x;
    this.y = y;
    this.r = stats.radius;
    this.speed = stats.speed;
    this.hp = stats.hp;
    this.maxHp = stats.hp;
    this.damage = stats.damage;
    this.score = stats.score;
    this.coins = stats.coins;
    this.color = stats.color;
    this.touchCooldown = 0;
    this.alive = true;
  }

  update(dt, target) {
    if (!this.alive) return;
    const dx = target.x - this.x;
    const dy = target.y - this.y;
    const d = Math.hypot(dx, dy) || 1;
    this.x += (dx / d) * this.speed * dt;
    this.y += (dy / d) * this.speed * dt;
    this.touchCooldown = Math.max(0, this.touchCooldown - dt);
  }

  damage_take(amount) {
    this.hp -= amount;
    if (this.hp <= 0) this.alive = false;
  }

  draw(ctx) {
    if (!this.alive) return;

    // Corps
    ctx.fillStyle = this.color;
    ctx.beginPath();
    ctx.arc(this.x, this.y, this.r, 0, Math.PI * 2);
    ctx.fill();

    // Contour plus sombre
    ctx.strokeStyle = "#0a0a0a";
    ctx.lineWidth = 1.5;
    ctx.stroke();

    // Yeux rouges
    const eyeR = Math.max(1, this.r * 0.13);
    const eyeOff = this.r * 0.35;
    ctx.fillStyle = "#ff3030";
    ctx.beginPath();
    ctx.arc(this.x - eyeOff, this.y - eyeOff * 0.4, eyeR, 0, Math.PI * 2);
    ctx.arc(this.x + eyeOff, this.y - eyeOff * 0.4, eyeR, 0, Math.PI * 2);
    ctx.fill();

    // Barre de vie pour gros mobs
    if (this.maxHp > 60 && this.hp < this.maxHp) {
      const w = this.r * 2.2;
      const h = 4;
      const x = this.x - w / 2;
      const y = this.y - this.r - 9;
      ctx.fillStyle = "#000";
      ctx.fillRect(x, y, w, h);
      ctx.fillStyle = "#f25555";
      ctx.fillRect(x, y, w * (this.hp / this.maxHp), h);
    }
  }
}
