import { CONFIG } from "../../../shared/config.js";

// Le joueur. Garde l'API simple : update, draw, hit, fire.
export class Player {
  constructor(x, y) {
    this.x = x;
    this.y = y;
    this.r = CONFIG.player.radius;
    this.hp = CONFIG.player.maxHp;
    this.aim = 0;            // angle en radians
    this.cooldown = 0;
    this.invuln = 0;
    this.alive = true;
  }

  update(dt, input, arena) {
    if (!this.alive) return;

    const ax = input.axis();
    this.x += ax.x * CONFIG.player.speed * dt;
    this.y += ax.y * CONFIG.player.speed * dt;

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
    this.cooldown = CONFIG.player.fireRate;
    return {
      x: this.x + Math.cos(this.aim) * (this.r + 2),
      y: this.y + Math.sin(this.aim) * (this.r + 2),
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

  draw(ctx) {
    // Corps
    ctx.save();
    ctx.translate(this.x, this.y);
    ctx.rotate(this.aim);

    // Clignote en invulnérabilité
    const blink = this.invuln > 0 && Math.floor(this.invuln * 20) % 2 === 0;
    ctx.fillStyle = blink ? "#ffffff" : "#5ab0ff";
    ctx.beginPath();
    ctx.arc(0, 0, this.r, 0, Math.PI * 2);
    ctx.fill();

    // Canon
    ctx.fillStyle = "#2a3a4a";
    ctx.fillRect(this.r - 4, -3, 12, 6);

    ctx.restore();
  }
}
