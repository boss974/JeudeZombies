import { CONFIG } from "../../../shared/config.js";
import { DEFENSE_TYPE, STATE, STORAGE_KEYS } from "../../../shared/constants.js";
import { Defense } from "./Defense.js";
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
    this.defenses = [];
    this.selectedDefense = DEFENSE_TYPE.TURRET;
    this.worldTime = 0;

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
    this.defenses = [];
    this.particles = [];
    this.score = 0;
    this.coins = 24;
    this.worldTime = 0;
    this._lastStatus = "intermission";
    this.state = STATE.PLAYING;
  }

  start() { this.reset(); }

  pause() { this.state = STATE.PAUSED; }
  resume() { this.state = STATE.PLAYING; }

  _loop(t) {
    const dt = Math.min(0.05, (t - this.lastTime) / 1000 || 0);
    this.lastTime = t;
    if (this.state === STATE.PLAYING) this._update(dt);
    this._draw();
    requestAnimationFrame(this._loop);
  }

  _update(dt) {
    this.player.update(dt, this.input, this.arena);
    this.worldTime += dt;

    // Tir
    if (this.input.mouse.down && this.player.canFire()) {
      this.bullets.push(this.player.fire());
      // Blague créole occasionnelle au tir (15% de chance, throttle ~3s)
      const now = performance.now();
      if (Math.random() < 0.15 && now - (this._lastShootLine || 0) > 3000) {
        this._lastShootLine = now;
        this.onPlayerShoot?.();
      }
    }

    if (this.input.consumeRightClick() || this.input.consumeKey("KeyE")) {
      this._tryPlaceDefense(this.input.mouse.x, this.input.mouse.y);
    }

    // Vague
    const spawned = this.waveManager.update(dt, this.zombies, this._isNight());
    if (spawned) this.zombies.push(spawned);

    for (const d of this.defenses) d.update(dt, this.zombies, this.bullets);

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
      const blockingDefense = this._nearestBarricade(z);
      if (blockingDefense) {
        if (z.touchCooldown <= 0 && blockingDefense.hit(z.damage)) {
          z.touchCooldown = 0.55;
          this._spawnHitParticles(blockingDefense.x, blockingDefense.y, "#f4b942", 4);
        }
        continue;
      }
      const dx = z.x - this.player.x, dy = z.y - this.player.y;
      const rr = (z.r + this.player.r) * (z.r + this.player.r);
      if (dx * dx + dy * dy <= rr && z.touchCooldown <= 0) {
        if (this.player.hit(z.damage)) {
          z.touchCooldown = 0.5;
          // Blague créole quand on se prend un coup (throttle ~2s)
          const now = performance.now();
          if (now - (this._lastHitLine || 0) > 2000) {
            this._lastHitLine = now;
            this.onPlayerHit?.();
            // Si HP critique, ligne "lowHp" plutôt
            if (this.player.hp / CONFIG.player.maxHp < 0.25) {
              setTimeout(() => this.onLowHp?.(), 300);
            }
          }
        }
      }
    }

    // Évènements de vague pour la couche narrative
    if (this.waveManager.status === "spawning" && this._lastStatus !== "spawning") {
      this.onWaveStart?.(this.waveManager.wave);
      if (this.waveManager._pendingBoss) this.onBossWave?.();
    }
    if (this.waveManager.status === "intermission" && this._lastStatus === "clearing") {
      this.score += CONFIG.scoring.waveClearBonus;
      this.onWaveCleared?.(this.waveManager.wave);
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
    this.defenses = this.defenses.filter(d => d.alive);
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
    if (this.hud.phase) this.hud.phase.textContent = this._isNight() ? "Nuit" : "Jour";
  }

  setSelectedDefense(type) {
    if (CONFIG.defense[type]) this.selectedDefense = type;
  }

  _tryPlaceDefense(x, y) {
    if (this.state !== STATE.PLAYING) return false;
    const cfg = CONFIG.defense[this.selectedDefense];
    if (!cfg || this.coins < cfg.cost) {
      this.onNoCoins?.();
      return false;
    }
    const tooCloseToPlayer = Math.hypot(x - this.player.x, y - this.player.y) < 52;
    const blocked = this.defenses.some(d => Math.hypot(x - d.x, y - d.y) < d.r + cfg.radius + 12);
    if (tooCloseToPlayer || blocked) return false;
    this.coins -= cfg.cost;
    this.defenses.push(new Defense(x, y, this.selectedDefense));
    this.onDefensePlaced?.(cfg.label);
    this._refreshHud();
    return true;
  }

  _nearestBarricade(z) {
    for (const d of this.defenses) {
      if (d.type !== DEFENSE_TYPE.BARRICADE || !d.alive) continue;
      const rr = (z.r + d.r) * (z.r + d.r);
      const dx = z.x - d.x, dy = z.y - d.y;
      if (dx * dx + dy * dy <= rr) return d;
    }
    return null;
  }

  _isNight() {
    const cycle = CONFIG.world.dayNightSeconds;
    return (this.worldTime % cycle) > cycle * 0.52;
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
    ctx.fillStyle = this._isNight() ? "#120f18" : "#1a1a1a";
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

    if (this.state !== STATE.PLAYING && this.state !== STATE.GAMEOVER && this.state !== STATE.PAUSED) return;

    // Particules
    for (const p of this.particles) {
      ctx.globalAlpha = Math.max(0, p.life * 2);
      ctx.fillStyle = p.color;
      ctx.fillRect(p.x - 1.5, p.y - 1.5, 3, 3);
    }
    ctx.globalAlpha = 1;

    // Zombies
    for (const z of this.zombies) z.draw(ctx);

    // Defenses
    for (const d of this.defenses) d.draw(ctx);

    // Bullets
    ctx.fillStyle = "#ffd76b";
    for (const b of this.bullets) {
      ctx.beginPath();
      ctx.arc(b.x, b.y, b.r, 0, Math.PI * 2);
      ctx.fill();
    }

    // Joueur
    this.player.draw(ctx);

    // Preview defense
    if (this.state === STATE.PLAYING) this._drawDefensePreview(ctx);

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

  _drawDefensePreview(ctx) {
    const cfg = CONFIG.defense[this.selectedDefense];
    if (!cfg) return;
    const x = this.input.mouse.x, y = this.input.mouse.y;
    const canPay = this.coins >= cfg.cost;
    ctx.save();
    ctx.globalAlpha = 0.22;
    ctx.fillStyle = canPay ? "#6ed87a" : "#ff3030";
    ctx.beginPath();
    ctx.arc(x, y, cfg.radius, 0, Math.PI * 2);
    ctx.fill();
    if (this.selectedDefense === DEFENSE_TYPE.TURRET) {
      ctx.strokeStyle = canPay ? "#6ed87a" : "#ff3030";
      ctx.beginPath();
      ctx.arc(x, y, cfg.range, 0, Math.PI * 2);
      ctx.stroke();
    }
    ctx.restore();
  }
}
