import { CONFIG } from "../../../shared/config.js";
import { DEFENSE_TYPE, STATE, STORAGE_KEYS } from "../../../shared/constants.js";
import { CityScene } from "./CityScene.js";
import { Defense } from "./Defense.js";
import { Input } from "./input.js";
import { Minimap } from "./Minimap.js";
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
    // Décor dynamique par ville + mini-carte radar
    this.cityScene = new CityScene();
    this.minimap = new Minimap();
    this.mission = null;            // setté par main.js avant start()
    // Post-processing : screen shake + flash dégât + vignette
    this._shake = 0;                // intensité du tremblement (pixels)
    this._damageFlash = 0;          // 0..1, fade out après hit
    this._lastPlayerHp = null;

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

    // Post-processing : si HP a baissé depuis la frame précédente, déclenche
    // un flash rouge + screen shake. Décline naturellement avec dt.
    const hpNow = this.player.hp;
    if (this._lastPlayerHp !== null && hpNow < this._lastPlayerHp) {
      const lost = this._lastPlayerHp - hpNow;
      this._damageFlash = Math.min(1, this._damageFlash + lost / 30);
      this._shake = Math.min(10, this._shake + lost / 10);
    }
    this._lastPlayerHp = hpNow;
    this._damageFlash = Math.max(0, this._damageFlash - dt * 1.4);
    this._shake = Math.max(0, this._shake - dt * 18);
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
    const tSec = performance.now() / 1000;

    // Screen shake : décale toute la scène d'un petit offset aléatoire
    // pendant un coup. Annule à la fin du _draw via ctx.restore().
    ctx.save();
    if (this._shake > 0.1) {
      const sx = (Math.random() - 0.5) * this._shake;
      const sy = (Math.random() - 0.5) * this._shake;
      ctx.translate(sx, sy);
    }

    // === Décor de ville ===
    // Le CityScene gère lui-même un fallback si this.mission est null.
    this.cityScene.draw(ctx, this.mission, this.arena, tSec);

    // Overlay nuit (la mission peut être de jour, mais le cycle interne reste)
    if (this._isNight()) {
      ctx.fillStyle = "rgba(8,6,16,0.35)";
      ctx.fillRect(0, 0, this.arena.width, this.arena.height);
    }

    if (this.state !== STATE.PLAYING && this.state !== STATE.GAMEOVER && this.state !== STATE.PAUSED) {
      ctx.restore();
      return;
    }

    // Particules (impacts)
    for (const p of this.particles) {
      ctx.globalAlpha = Math.max(0, p.life * 2);
      ctx.fillStyle = p.color;
      ctx.fillRect(p.x - 1.5, p.y - 1.5, 3, 3);
    }
    ctx.globalAlpha = 1;

    // Zombies (avec animation basée sur time)
    for (const z of this.zombies) z.draw(ctx, tSec);

    // Defenses
    for (const d of this.defenses) d.draw(ctx);

    // Bullets : avec trail/glow pour effet "tracer brûlant"
    for (const b of this.bullets) {
      // Halo extérieur orange transparent
      ctx.fillStyle = "rgba(255,140,40,0.35)";
      ctx.beginPath();
      ctx.arc(b.x, b.y, b.r * 2.4, 0, Math.PI * 2);
      ctx.fill();
      // Trail derrière (3 cercles décroissants dans la direction opposée)
      const sp = Math.hypot(b.vx, b.vy) || 1;
      for (let i = 1; i <= 3; i++) {
        const tx = b.x - (b.vx / sp) * i * 4;
        const ty = b.y - (b.vy / sp) * i * 4;
        ctx.fillStyle = `rgba(255,215,107,${0.6 - i * 0.18})`;
        ctx.beginPath();
        ctx.arc(tx, ty, b.r * (1.0 - i * 0.2), 0, Math.PI * 2);
        ctx.fill();
      }
      // Cœur brillant
      ctx.fillStyle = "#fff6c8";
      ctx.beginPath();
      ctx.arc(b.x, b.y, b.r, 0, Math.PI * 2);
      ctx.fill();
    }

    // Joueur (avec animation)
    this.player.draw(ctx, tSec);

    // Preview defense
    if (this.state === STATE.PLAYING) this._drawDefensePreview(ctx);

    // Message de vague
    if (this.waveManager.messageTimer > 0) {
      ctx.save();
      const alpha = Math.min(1, this.waveManager.messageTimer);
      ctx.globalAlpha = alpha;
      // Fond foncé pour lisibilité par-dessus n'importe quel décor
      ctx.fillStyle = "rgba(0,0,0,0.55)";
      ctx.fillRect(0, this.arena.height / 2 - 80, this.arena.width, 70);
      ctx.fillStyle = "#ff6b35";
      ctx.font = "bold 42px Segoe UI, sans-serif";
      ctx.textAlign = "center";
      ctx.fillText(this.waveManager.message, this.arena.width / 2, this.arena.height / 2 - 40);
      ctx.restore();
    }

    // Restore le screen shake AVANT les effets full-screen (qui ne doivent
    // pas trembler avec la scène).
    ctx.restore();

    // ========================================================================
    // POST-PROCESSING fixe (ne tremble pas)
    // ========================================================================

    // Vignette permanente : assombrissement périphérique pour faire ressortir
    // le centre du gameplay
    const vignette = ctx.createRadialGradient(
      this.arena.width / 2, this.arena.height / 2, this.arena.height * 0.45,
      this.arena.width / 2, this.arena.height / 2, this.arena.height * 0.85
    );
    vignette.addColorStop(0, "rgba(0,0,0,0)");
    vignette.addColorStop(1, "rgba(0,0,0,0.45)");
    ctx.fillStyle = vignette;
    ctx.fillRect(0, 0, this.arena.width, this.arena.height);

    // Flash rouge plein écran sur dégâts
    if (this._damageFlash > 0.01) {
      ctx.fillStyle = `rgba(255,30,30,${this._damageFlash * 0.45})`;
      ctx.fillRect(0, 0, this.arena.width, this.arena.height);
    }

    // Mini-carte radar (par-dessus la vignette mais sous le HUD HTML)
    this.minimap.draw(ctx, this.arena, this.player, this.zombies, this.defenses, this.bullets);
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
