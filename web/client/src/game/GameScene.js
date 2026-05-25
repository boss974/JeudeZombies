import { CONFIG } from "../../../shared/config.js";
import { STATE, STORAGE_KEYS } from "../../../shared/constants.js";
import { Input } from "./input.js";
import { Player } from "./Player.js";
import { WaveManager } from "./WaveManager.js";

// Scène principale : boucle update/draw + collisions + score.
export class GameScene {
  constructor(canvas, hud) {
    this.canvas = canvas;
    this.ctx = canvas.getContext("2d");
    this.hud = hud;
    this.input = new Input(canvas);
    this.arena = { width: canvas.width, height: canvas.height };

    this.state = STATE.MENU;
    this.lastTime = 0;
    this.particles = [];
    this.bullets = [];
    this.zombies = [];

    this.bestScore = parseInt(localStorage.getItem(STORAGE_KEYS.BEST_SCORE) || "0", 10);

    this._loop = this._loop.bind(this);
    requestAnimationFrame(this._loop);
  }

  reset() {
    this.player = new Player(this.arena.width / 2, this.arena.height / 2);
    this.waveManager = new WaveManager(this.arena);
    this.waveManager.start();
    this.bullets = [];
    this.zombies = [];
    this.particles = [];
    this.score = 0;
    this.coins = 0;
    this._lastStatus = "intermission";
    this.state = STATE.PLAYING;
  }

  start() { this.reset(); }

  _loop(t) {
    const dt = Math.min(0.05, (t - this.lastTime) / 1000 || 0);
    this.lastTime = t;
    if (this.state === STATE.PLAYING) this._update(dt);
    this._draw();
    requestAnimationFrame(this._loop);
  }

  _update(dt) {
    this.player.update(dt, this.input, this.arena);

    // Tir
    if (this.input.mouse.down && this.player.canFire()) {
      this.bullets.push(this.player.fire());
    }

    // Vague
    const spawned = this.waveManager.update(dt, this.zombies);
    if (spawned) this.zombies.push(spawned);

    // Bullets
    for (const b of this.bullets) {
      b.x += b.vx * dt;
      b.y += b.vy * dt;
      b.life -= dt;
    }

    // Zombies
    for (const z of this.zombies) z.update(dt, this.player);

    // Collisions balles -> zombies
    for (const b of this.bullets) {
      if (b.life <= 0) continue;
      for (const z of this.zombies) {
        if (!z.alive) continue;
        const dx = z.x - b.x, dy = z.y - b.y;
        if (dx * dx + dy * dy <= (z.r + b.r) * (z.r + b.r)) {
          z.damage_take(b.damage);
          b.life = 0;
          this._spawnHitParticles(b.x, b.y, z.color);
          if (!z.alive) {
            this.score += z.score;
            this.coins += z.coins;
            this._spawnHitParticles(z.x, z.y, z.color, 14);
          }
          break;
        }
      }
    }

    // Collisions zombies -> joueur
    for (const z of this.zombies) {
      if (!z.alive) continue;
      const dx = z.x - this.player.x, dy = z.y - this.player.y;
      const rr = (z.r + this.player.r) * (z.r + this.player.r);
      if (dx * dx + dy * dy <= rr && z.touchCooldown <= 0) {
        if (this.player.hit(z.damage)) z.touchCooldown = 0.5;
      }
    }

    // Bonus fin de vague (déclenché une fois quand status passe à intermission)
    if (this.waveManager.status === "intermission" && this._lastStatus === "clearing") {
      this.score += CONFIG.scoring.waveClearBonus;
    }
    this._lastStatus = this.waveManager.status;

    // Particules
    for (const p of this.particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.life -= dt;
    }

    // Nettoyage
    this.bullets = this.bullets.filter(b => b.life > 0
      && b.x > -10 && b.x < this.arena.width + 10
      && b.y > -10 && b.y < this.arena.height + 10);
    this.zombies = this.zombies.filter(z => z.alive);
    this.particles = this.particles.filter(p => p.life > 0);

    // Game over
    if (!this.player.alive) {
      this.state = STATE.GAMEOVER;
      this._saveBest();
      this.onGameOver?.({ wave: this.waveManager.wave, score: this.score, coins: this.coins });
    }

    this._refreshHud();
  }

  _saveBest() {
    if (this.score > this.bestScore) {
      this.bestScore = this.score;
      localStorage.setItem(STORAGE_KEYS.BEST_SCORE, String(this.bestScore));
    }
    const total = parseInt(localStorage.getItem(STORAGE_KEYS.TOTAL_COINS) || "0", 10);
    localStorage.setItem(STORAGE_KEYS.TOTAL_COINS, String(total + this.coins));
  }

  _refreshHud() {
    this.hud.wave.textContent  = this.waveManager.wave;
    this.hud.score.textContent = this.score;
    this.hud.coins.textContent = this.coins;
    this.hud.best.textContent  = this.bestScore;
    this.hud.hpFill.style.width = `${(this.player.hp / CONFIG.player.maxHp) * 100}%`;
  }

  _spawnHitParticles(x, y, color, count = 5) {
    for (let i = 0; i < count; i++) {
      const a = Math.random() * Math.PI * 2;
      const s = 80 + Math.random() * 120;
      this.particles.push({
        x, y,
        vx: Math.cos(a) * s,
        vy: Math.sin(a) * s,
        life: 0.4 + Math.random() * 0.3,
        color
      });
    }
  }

  _draw() {
    const { ctx } = this;
    // Fond
    ctx.fillStyle = "#1a1a1a";
    ctx.fillRect(0, 0, this.arena.width, this.arena.height);

    // Grille subtile
    ctx.strokeStyle = "#262626";
    ctx.lineWidth = 1;
    for (let x = 0; x < this.arena.width; x += 40) {
      ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, this.arena.height); ctx.stroke();
    }
    for (let y = 0; y < this.arena.height; y += 40) {
      ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(this.arena.width, y); ctx.stroke();
    }

    if (this.state !== STATE.PLAYING && this.state !== STATE.GAMEOVER) return;

    // Particules
    for (const p of this.particles) {
      ctx.globalAlpha = Math.max(0, p.life * 2);
      ctx.fillStyle = p.color;
      ctx.fillRect(p.x - 1.5, p.y - 1.5, 3, 3);
    }
    ctx.globalAlpha = 1;

    // Zombies
    for (const z of this.zombies) z.draw(ctx);

    // Bullets
    ctx.fillStyle = "#ffd76b";
    for (const b of this.bullets) {
      ctx.beginPath();
      ctx.arc(b.x, b.y, b.r, 0, Math.PI * 2);
      ctx.fill();
    }

    // Joueur
    this.player.draw(ctx);

    // Message de vague
    if (this.waveManager.messageTimer > 0) {
      ctx.save();
      const alpha = Math.min(1, this.waveManager.messageTimer);
      ctx.globalAlpha = alpha;
      ctx.fillStyle = "#f25555";
      ctx.font = "bold 42px Segoe UI, sans-serif";
      ctx.textAlign = "center";
      ctx.fillText(this.waveManager.message, this.arena.width / 2, this.arena.height / 2 - 40);
      ctx.restore();
    }
  }
}
