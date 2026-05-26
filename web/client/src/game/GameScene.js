import { CONFIG } from "../../../shared/config.js";
import { DEFENSE_TYPE, PICKUP_TYPE, STATE, STORAGE_KEYS } from "../../../shared/constants.js";
import { CityScene } from "./CityScene.js";
import { Defense } from "./Defense.js";
import { GamepadInput, Input, pollFirstGamepad } from "./input.js";
import { Minimap } from "./Minimap.js";
import { Pickup } from "./Pickup.js";
import { Player } from "./Player.js";
import { WaveManager } from "./WaveManager.js";
import { Zombie } from "./Zombie.js";
import { computeBonuses, loadUpgrades } from "./Upgrades.js";

// Scène principale : boucle update/draw + collisions + score.
export class GameScene {
  constructor(canvas, hud) {
    this.canvas = canvas;
    this.ctx = canvas.getContext("2d");
    this.hud = hud;
    this.input = new Input(canvas);
    this.input2 = new GamepadInput();         // P2 si manette branchée
    this.player2 = null;                       // Player 2 instancié au reset si gamepad
    this.arena = { width: canvas.width, height: canvas.height };

    this.state = STATE.MENU;
    this.lastTime = 0;
    this.particles = [];
    this.bullets = [];
    this.zombies = [];
    this.defenses = [];
    this.pickups = [];                 // Pickup[] visibles au sol
    this.lavaTrails = [];              // flaques de lave laissées par le boss en phase 3
    this.bossRoarSlow = 0;             // worldTime jusqu'auquel le joueur est ralenti
    this.bossRoarMul = 0.45;           // multiplicateur de speed pendant le slow
    this.floaters = [];                // textes "+15" qui flottent vers le haut sur kill
    this.corpses  = [];                // zombies morts en fade-out
    this.shockwaves = [];              // anneaux d'onde de choc (exploder, roar, boss spawn)
    this.bossFlash = 0;                // alpha plein écran orange quand boss spawn
    this.weapon = "pistol";            // arme actuelle ("pistol"/"shotgun"/"volcano") - pour couleur trails
    this.weather = null;                // {type:"rain"|"ash"|"sun", particles:[]} initialisé au reset par mission
    this.paused = false;                // pause sur ESC
    // Buffs temporaires actifs (timestamps en sec depuis worldTime)
    this.buffs = { damage: 0, speed: 0, magnet: 0 };
    this.bonuses = computeBonuses(loadUpgrades());
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
    this.combo = 1;
    this.comboTimer = 0;

    this.bestScore = parseInt(localStorage.getItem(STORAGE_KEYS.BEST_SCORE) || "0", 10);

    this._loop = this._loop.bind(this);
    requestAnimationFrame(this._loop);
  }

  reset(options = {}) {
    this.player = new Player(this.arena.width / 2 - 30, this.arena.height / 2);
    // P2 actif uniquement si une manette est branchée. Sinon player2 = null (mode solo classique).
    if (pollFirstGamepad()) {
      this.player2 = new Player(this.arena.width / 2 + 30, this.arena.height / 2);
      this.player2.isPlayer2 = true;           // pour la palette de rendu distincte
      this.onCoopStart?.();
    } else {
      this.player2 = null;
    }
    this.difficulty = options.difficulty || 1;
    this.waveManager = new WaveManager(this.arena, this.difficulty);
    this.waveManager.start();
    this.bullets = [];
    this.zombies = [];
    this.defenses = [];
    this.pickups = [];
    this.lavaTrails = [];
    this.bossRoarSlow = 0;
    this.floaters = [];
    this.corpses = [];
    this.shockwaves = [];
    this.bossFlash = 0;
    this.particles = [];
    this.score = 0;
    this.coins = 24;
    this.worldTime = 0;
    this.combo = 1;
    this.comboTimer = 0;
    this.buffs = { damage: 0, speed: 0, magnet: 0 };
    // Compteurs cumulés de défenses placées (pour le coût croissant). Pas reset au kill,
    // c'est volontaire : plus tu places, plus la prochaine coûte cher.
    this._defensesPlaced = { turret: 0, barricade: 0 };
    this._lastStatus = "intermission";
    this.state = STATE.PLAYING;

    // Recharge les bonus d'upgrade et applique le bonus HP max au joueur
    this.bonuses = computeBonuses(loadUpgrades());
    if (this.bonuses.hpBonus > 0) {
      this.player.maxHp = (this.player.maxHp || CONFIG.player.maxHp) + this.bonuses.hpBonus;
      this.player.hp = this.player.maxHp;
    }
    // Météo dynamique par mission (pluie/cendres/soleil selon localisation Réunion)
    this._initWeather();
  }

  /** Initialise les particules météo selon la mission active.
   * - stbenoit (Est) : pluie battante
   * - fournaise (cœur volcan) : pluie de cendres dense
   * - plaine (route du volcan) : cendres légères
   * - cilaos (cirque) : brume (overlay)
   * - sun (autres) : particules dorées rares
   */
  _initWeather() {
    const id = this.mission?.id || "stdenis";
    const W = this.arena.width;
    const H = this.arena.height;
    let type = "sun";
    if (id === "stbenoit") type = "rain";
    else if (id === "fournaise") type = "ash-heavy";
    else if (id === "plaine") type = "ash";
    else if (id === "cilaos") type = "mist";
    const counts = { rain: 120, "ash-heavy": 90, ash: 50, mist: 0, sun: 18 };
    const n = counts[type] || 0;
    const particles = [];
    for (let i = 0; i < n; i++) {
      particles.push(this._makeWeatherParticle(type, W, H, true));
    }
    this.weather = { type, particles };
  }

  _makeWeatherParticle(type, W, H, spawnAnywhere = false) {
    // spawnAnywhere = à l'init, on remplit l'écran. Sinon on respawn en haut.
    if (type === "rain") {
      return {
        x: Math.random() * W,
        y: spawnAnywhere ? Math.random() * H : -10,
        vx: -120,  // pluie oblique (vent d'Est)
        vy: 720 + Math.random() * 280,
        len: 14 + Math.random() * 8,
        alpha: 0.35 + Math.random() * 0.25
      };
    }
    if (type === "ash" || type === "ash-heavy") {
      const heavy = type === "ash-heavy";
      return {
        x: Math.random() * W,
        y: spawnAnywhere ? Math.random() * H : -10,
        vx: 30 + Math.random() * 40,  // dérive Sud-Est
        vy: 35 + Math.random() * 50,
        r: 1.2 + Math.random() * (heavy ? 2.5 : 1.5),
        wobble: Math.random() * Math.PI * 2,
        wobbleSpeed: 1.2 + Math.random(),
        color: heavy
          ? `rgba(40,30,25,${0.5 + Math.random() * 0.4})`
          : `rgba(80,70,65,${0.3 + Math.random() * 0.3})`
      };
    }
    // sun : poussière dorée
    return {
      x: Math.random() * W,
      y: spawnAnywhere ? Math.random() * H : -10,
      vx: 8 + Math.random() * 6,
      vy: 12 + Math.random() * 10,
      r: 1 + Math.random() * 1.5,
      alpha: 0.4 + Math.random() * 0.3,
      color: "#ffe6a0"
    };
  }

  start(options) { this.reset(options); }

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
    // Applique les multiplicateurs permanents (upgrades) + temporaires (pickups + roar boss)
    // AVANT l'update des joueurs.
    const speedBuff = this.buffs.speed > this.worldTime ? 1.3 : 1;
    const roarSlow  = this.bossRoarSlow > this.worldTime ? this.bossRoarMul : 1;
    const speedMul    = (this.bonuses?.speedMul || 1) * speedBuff * roarSlow;
    const fireRateMul = (this.bonuses?.fireRateMul || 1);
    this.player.speedMul = speedMul;
    this.player.fireRateMul = fireRateMul;
    if (this.player2) {
      this.player2.speedMul = speedMul;
      this.player2.fireRateMul = fireRateMul;
      // Met à jour la "souris virtuelle" du gamepad AVANT update (sinon aim à 1 frame retard)
      this.input2.updateFromGamepad({ x: this.player2.x, y: this.player2.y });
    }

    this.player.update(dt, this.input, this.arena);
    if (this.player2 && this.player2.alive) this.player2.update(dt, this.input2, this.arena);
    this.worldTime += dt;

    // Tir P1
    if (this.input.mouse.down && this.player.canFire()) {
      const b = this.player.fire();
      const dmgMul = (this.buffs.damage > this.worldTime) ? 1.5 : 1;
      b.damage = Math.round(b.damage * dmgMul + (this.bonuses?.damageBonus || 0));
      b.weapon = this.weapon;
      this.bullets.push(b);
      this.onPlayerFire?.();
      const now = performance.now();
      if (Math.random() < 0.15 && now - (this._lastShootLine || 0) > 3000) {
        this._lastShootLine = now;
        this.onPlayerShoot?.();
      }
    }
    // Tir P2 (manette) - utilise la même arme que P1 (cycle global)
    if (this.player2 && this.player2.alive && this.input2.mouse.down && this.player2.canFire()) {
      const b = this.player2.fire();
      const dmgMul = (this.buffs.damage > this.worldTime) ? 1.5 : 1;
      b.damage = Math.round(b.damage * dmgMul + (this.bonuses?.damageBonus || 0));
      b.weapon = this.weapon;
      this.bullets.push(b);
      this.onPlayerFire?.();
    }

    // Pose de défense P1 (clic droit ou E)
    if (this.input.consumeRightClick() || this.input.consumeKey("KeyE")) {
      this._tryPlaceDefense(this.input.mouse.x, this.input.mouse.y);
    }
    // Pose de défense P2 (LB)
    if (this.player2 && this.player2.alive && (this.input2.consumeRightClick() || this.input2.consumeKey("KeyE"))) {
      this._tryPlaceDefense(this.input2.mouse.x, this.input2.mouse.y);
    }

    // Vague
    const spawned = this.waveManager.update(dt, this.zombies, this._isNight());
    if (spawned) {
      // Boss : câble les callbacks pour les patterns spéciaux (dash/spawn/roar/lava)
      if (spawned.type === "boss") {
        this._wireBossCallbacks(spawned);
        // Effets dramatiques au spawn boss : flash plein écran + shockwave
        this.bossFlash = 1;
        this.shockwaves.push({
          x: spawned.x, y: spawned.y,
          r: 0, maxR: 280, life: 0.8, maxLife: 0.8,
          color: "rgba(255, 30, 30, 0.7)"
        });
        this._shake = Math.min(16, this._shake + 8);
      }
      this.zombies.push(spawned);
    }

    for (const d of this.defenses) d.update(dt, this.zombies, this.bullets);

    // Bullets
    for (const b of this.bullets) {
      b.x += b.vx * dt;
      b.y += b.vy * dt;
      b.life -= dt;
    }

    // Zombies (ciblent le joueur le plus proche s'il y a P2)
    for (const z of this.zombies) {
      const target = this._nearestPlayerTo(z);
      z.update(dt, target);
    }

    // Exploders qui se sont auto-détruits au contact du joueur pendant z.update()
    for (const z of this.zombies) {
      if (!z.alive && z._shouldExplode) {
        this._explodeExploder(z);
        z._shouldExplode = false;
      }
    }

    // Collisions balles -> zombies (passe fromX/fromY pour le shielded shield check)
    for (const b of this.bullets) {
      if (b.life <= 0) continue;
      for (const z of this.zombies) {
        if (!z.alive) continue;
        const dx = z.x - b.x, dy = z.y - b.y;
        if (dx * dx + dy * dy <= (z.r + b.r) * (z.r + b.r)) {
          // Origine de la balle ≈ b.x - vx*petit (la balle vient d'avant ce frame).
          // Pour le shielded check, on utilise un point en arrière de la balle.
          const back = 6;
          const sp = Math.hypot(b.vx, b.vy) || 1;
          const fromX = b.x - (b.vx / sp) * back;
          const fromY = b.y - (b.vy / sp) * back;
          z.damage_take(b.damage, fromX, fromY);
          b.life = 0;
          this.onBulletHit?.();
          this._spawnHitParticles(b.x, b.y, z.color);
          if (!z.alive) {
            // Exploder : AOE à la mort
            if (z._shouldExplode) this._explodeExploder(z);
            this._registerKill(z);
            this.onZombieKilled?.(z.type);
            this._spawnHitParticles(z.x, z.y, z.color, 14);
            // Drop éventuel de pickup
            const dropType = Pickup.maybeDropFor(z);
            if (dropType) {
              this.pickups.push(new Pickup(z.x, z.y, dropType));
            }
          }
          break;
        }
      }
    }

    // Lava trails : décompte de vie + dégâts aux joueur(s) qui marchent dedans
    for (const lt of this.lavaTrails) {
      lt.life -= dt;
      if (lt.life <= 0) continue;
      const players = [this.player, this.player2].filter(p => p && p.alive);
      for (const tp of players) {
        const dx = tp.x - lt.x, dy = tp.y - lt.y;
        if (dx * dx + dy * dy <= lt.r * lt.r && tp.invuln <= 0) {
          const dmg = lt.dps * dt;
          tp.hp -= dmg;
          if (tp.hp <= 0) { tp.hp = 0; tp.alive = false; }
        }
      }
    }
    this.lavaTrails = this.lavaTrails.filter(lt => lt.life > 0);

    // Pickups : update + ramassage (chaque pickup va vers le joueur le plus proche)
    const magnetActive = this.buffs.magnet > this.worldTime;
    for (const p of this.pickups) {
      const target = this._nearestPlayerTo(p);
      p.update(dt, target, magnetActive);
      // Essaye le ramassage avec chaque joueur vivant
      const players = [this.player, this.player2].filter(pl => pl && pl.alive);
      for (const pl of players) {
        if (p.tryPickup(pl)) {
          this._applyPickup(p.type, pl);
          break;
        }
      }
    }
    this.pickups = this.pickups.filter(p => p.alive);
    // Décompte des buffs (uniquement visuel ; les check sont par worldTime)

    // Collisions zombies -> joueur(s)
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
      // Teste contre chaque joueur vivant
      const targets = [this.player, this.player2].filter(p => p && p.alive);
      for (const tp of targets) {
        const dx = z.x - tp.x, dy = z.y - tp.y;
        const rr = (z.r + tp.r) * (z.r + tp.r);
        if (dx * dx + dy * dy <= rr && z.touchCooldown <= 0) {
          if (tp.hit(z.damage)) {
            z.touchCooldown = 0.5;
            this.onPlayerDamaged?.();
            const now = performance.now();
            if (now - (this._lastHitLine || 0) > 2000) {
              this._lastHitLine = now;
              this.onPlayerHit?.();
              if (tp.hp / (tp.maxHp || CONFIG.player.maxHp) < 0.25) {
                setTimeout(() => this.onLowHp?.(), 300);
              }
            }
            break;  // un seul joueur touché par frame par ce zombie
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

    this.comboTimer = Math.max(0, this.comboTimer - dt);
    if (this.comboTimer <= 0 && this.combo !== 1) {
      this.combo = 1;
      this.onCombo?.(this.combo);
    }

    // Particules
    for (const p of this.particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.life -= dt;
    }

    // Floaters (textes "+15") montent et fadent
    for (const f of this.floaters) {
      f.y += f.vy * dt;
      f.life -= dt;
    }
    this.floaters = this.floaters.filter(f => f.life > 0);

    // Corpses fade out
    for (const c of this.corpses) c.life -= dt;
    this.corpses = this.corpses.filter(c => c.life > 0);

    // Shockwaves expansion
    for (const sw of this.shockwaves) {
      sw.life -= dt;
      const t = 1 - (sw.life / sw.maxLife);  // 0 → 1
      sw.r = sw.maxR * t;
    }
    this.shockwaves = this.shockwaves.filter(sw => sw.life > 0);

    // Boss flash décroissant
    this.bossFlash = Math.max(0, this.bossFlash - dt * 1.4);

    // Météo : update positions, recyclage des particules sorties d'écran
    if (this.weather && this.weather.particles.length > 0) {
      const W = this.arena.width, H = this.arena.height;
      const type = this.weather.type;
      for (const p of this.weather.particles) {
        p.x += p.vx * dt;
        p.y += p.vy * dt;
        if (type === "ash" || type === "ash-heavy") {
          p.wobble += p.wobbleSpeed * dt;
          p.x += Math.sin(p.wobble) * 8 * dt;
        }
        // Recycle quand sort
        if (p.y > H + 20 || p.x < -30 || p.x > W + 30) {
          Object.assign(p, this._makeWeatherParticle(type, W, H, false));
        }
      }
    }

    // Nettoyage
    this.bullets = this.bullets.filter(b => b.life > 0
      && b.x > -10 && b.x < this.arena.width + 10
      && b.y > -10 && b.y < this.arena.height + 10);
    this.zombies = this.zombies.filter(z => z.alive);
    this.defenses = this.defenses.filter(d => d.alive);
    this.particles = this.particles.filter(p => p.life > 0);

    // Game over : si coop, attendre que les DEUX joueurs soient morts
    const allDead = !this.player.alive && (!this.player2 || !this.player2.alive);
    if (allDead) {
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
    const maxHp1 = this.player.maxHp || CONFIG.player.maxHp;
    this.hud.hpFill.style.width = `${(this.player.hp / maxHp1) * 100}%`;
    if (this.hud.phase) this.hud.phase.textContent = this._isNight() ? "Nuit" : "Jour";
    if (this.hud.combo) this.hud.combo.textContent = `x${this.combo}`;
    // Barre P2 (toggle visibilité de la row via attribut sur le scene)
    if (this.hud.hpFillP2) {
      if (this.player2) {
        const maxHp2 = this.player2.maxHp || CONFIG.player.maxHp;
        const w = Math.max(0, (this.player2.hp / maxHp2) * 100);
        this.hud.hpFillP2.style.width = `${w}%`;
      }
    }
  }

  _registerKill(zombie) {
    this.combo = Math.min(5, this.combo + 1);
    this.comboTimer = 3.5;
    const scoreGain = Math.round(zombie.score * this.combo);
    this.score += scoreGain;
    const coinBase = zombie.coins + (this.combo >= 3 ? 1 : 0) + (this.combo >= 5 ? 1 : 0);
    const coinGain = Math.round(coinBase * (this.bonuses?.coinMul || 1));
    this.coins += coinGain;
    this.onCombo?.(this.combo);
    // Popup "+XX" qui monte au-dessus du zombie tué (en jaune si combo >= 3)
    const isComboFlare = this.combo >= 3;
    this.floaters.push({
      x: zombie.x,
      y: zombie.y - zombie.r - 4,
      vy: -38,
      life: 1.1,
      text: `+${scoreGain}`,
      color: isComboFlare ? "#ffe6a0" : "#f4b942",
      size: isComboFlare ? 18 : 15
    });
    if (coinGain > 0) {
      this.floaters.push({
        x: zombie.x + 18,
        y: zombie.y - zombie.r - 4,
        vy: -28,
        life: 0.95,
        text: `+${coinGain}¢`,
        color: "#ffb84a",
        size: 12
      });
    }
    // Corpse fade : un "fantôme" qui s'estompe sur 0.5s à l'emplacement
    this.corpses.push({
      x: zombie.x, y: zombie.y, r: zombie.r,
      color: zombie.color, life: 0.5, maxLife: 0.5
    });
    this.onScorePopup?.(scoreGain);
  }

  /** Applique l'effet d'un pickup ramassé (heal/ammo/speed/bomb/magnet). */
  _applyPickup(type, picker = this.player) {
    if (type === "heal") {
      const maxHp = picker.maxHp || CONFIG.player.maxHp;
      picker.hp = Math.min(maxHp, picker.hp + 25);
    } else if (type === "ammo") {
      this.buffs.damage = this.worldTime + 8;     // 8s de buff dégâts (partagé)
    } else if (type === "speed") {
      this.buffs.speed = this.worldTime + 6;       // 6s de buff vitesse (partagé)
    } else if (type === "bomb") {
      // Détruit tous les zombies dans 120px du joueur qui a ramassé
      for (const z of this.zombies) {
        if (!z.alive) continue;
        const dx = z.x - picker.x, dy = z.y - picker.y;
        if (dx * dx + dy * dy <= 120 * 120) {
          z.damage_take(9999);
          if (!z.alive) {
            this._registerKill(z);
            this._spawnHitParticles(z.x, z.y, "#ff6b35", 18);
          }
        }
      }
      this.onZombieKilled?.("bomb");
    } else if (type === "magnet") {
      this.buffs.magnet = this.worldTime + 8;
    }
    this.onPickup?.(type);
  }

  setSelectedDefense(type) {
    if (CONFIG.defense[type]) this.selectedDefense = type;
  }

  /** Nombre actuel de défenses ALIVE d'un type donné (les détruites libèrent un slot). */
  currentDefenseCount(type) {
    return this.defenses.filter(d => d.type === type && d.alive).length;
  }

  /** Limite courante de défenses d'un type, qui augmente avec les vagues. */
  currentDefenseLimit(type) {
    const cfg = CONFIG.defense[type];
    if (!cfg) return 0;
    const wave = this.waveManager?.wave || 1;
    const extra = Math.floor((wave - 1) / Math.max(1, cfg.limitPerWaves));
    return Math.min(cfg.maxLimit, cfg.baseLimit + extra);
  }

  /** Coût courant de la PROCHAINE défense placée (croît exponentiellement). */
  currentDefenseCost(type) {
    const cfg = CONFIG.defense[type];
    if (!cfg) return 0;
    const placed = this._defensesPlaced?.[type] || 0;
    return Math.ceil(cfg.baseCost * Math.pow(cfg.costMul || 1, placed));
  }

  _tryPlaceDefense(x, y) {
    if (this.state !== STATE.PLAYING) return false;
    const type = this.selectedDefense;
    const cfg = CONFIG.defense[type];
    if (!cfg) return false;
    // Limite atteinte ?
    if (this.currentDefenseCount(type) >= this.currentDefenseLimit(type)) {
      this.onDefenseLimitReached?.(type, this.currentDefenseLimit(type));
      return false;
    }
    const cost = this.currentDefenseCost(type);
    if (this.coins < cost) {
      this.onNoCoins?.();
      return false;
    }
    const tooCloseToPlayer = Math.hypot(x - this.player.x, y - this.player.y) < 52;
    const blocked = this.defenses.some(d => Math.hypot(x - d.x, y - d.y) < d.r + cfg.radius + 12);
    if (tooCloseToPlayer || blocked) return false;
    this.coins -= cost;
    this.defenses.push(new Defense(x, y, type));
    this._defensesPlaced[type] = (this._defensesPlaced[type] || 0) + 1;
    this.onDefensePlaced?.(cfg.label);
    this._refreshHud();
    return true;
  }

  /** Câble les callbacks d'un boss qui vient de spawn pour ses patterns. */
  _wireBossCallbacks(boss) {
    boss.onPhaseChange = (phase) => {
      this.onBossPhaseChange?.(phase);
    };
    boss.onDash = () => {
      this.onBossDash?.();
    };
    boss.onSpawnMinion = (mx, my, minionType) => {
      const minion = new Zombie(mx, my, minionType);
      // Hérite du scaling de la vague pour rester challenging
      const sm = (1 + (this.waveManager.wave - 1) * CONFIG.wave.speedScalingPerWave);
      const hm = (1 + (this.waveManager.wave - 1) * CONFIG.wave.hpScalingPerWave);
      minion.speed *= sm;
      minion.baseSpeed = minion.speed;
      minion.hp = Math.ceil(minion.hp * hm);
      minion.maxHp = minion.hp;
      this.zombies.push(minion);
    };
    boss.onRoar = (rx, ry, radius, slowDur, slowMul) => {
      const players = [this.player, this.player2].filter(p => p && p.alive);
      for (const tp of players) {
        const dx = tp.x - rx, dy = tp.y - ry;
        if (dx * dx + dy * dy <= radius * radius) {
          this.bossRoarSlow = this.worldTime + slowDur;
          this.bossRoarMul = slowMul;
          break;
        }
      }
      this.onBossRoar?.(rx, ry, radius);
      this._spawnRoarRing(rx, ry, radius);
    };
    boss.onLavaTrail = (lx, ly, lr, life, dps) => {
      this.lavaTrails.push({ x: lx, y: ly, r: lr, maxLife: life, life, dps });
    };
  }

  /** Applique l'AOE d'un exploder mort sur le(s) joueur(s) + zombies voisins. */
  _explodeExploder(z) {
    const r = z.aoeRadius || 80;
    const dmg = z.aoeDamage || 30;
    // Dommage à chaque joueur dans le rayon
    const players = [this.player, this.player2].filter(p => p && p.alive);
    for (const tp of players) {
      const dx = tp.x - z.x;
      const dy = tp.y - z.y;
      if (dx * dx + dy * dy <= r * r) {
        tp.hit(dmg);
        this.onPlayerDamaged?.();
      }
    }
    // Dommage friendly-fire aux autres zombies (sans loop infini d'AOE chain)
    for (const other of this.zombies) {
      if (!other.alive || other === z) continue;
      const ex = other.x - z.x;
      const ey = other.y - z.y;
      if (ex * ex + ey * ey <= r * r) {
        other.damage_take(dmg * 0.6);
        if (!other.alive && other.type !== "exploder") {
          this._registerKill(other);
        }
      }
    }
    // Particules en gerbe + onde de choc visuelle
    this._spawnHitParticles(z.x, z.y, "#ff7a2a", 24);
    this.shockwaves.push({
      x: z.x, y: z.y,
      r: 0, maxR: r, life: 0.45, maxLife: 0.45,
      color: "rgba(255, 140, 40, 0.85)"
    });
    this._shake = Math.min(14, this._shake + 6);
    this.onExploderBoom?.(z.x, z.y, r);
  }

  /** Spawn une "onde" de particules visuelle pour le roar du boss. */
  _spawnRoarRing(x, y, radius) {
    const N = 28;
    for (let i = 0; i < N; i++) {
      const a = (i / N) * Math.PI * 2;
      const s = 280 + Math.random() * 60;
      this.particles.push({
        x, y,
        vx: Math.cos(a) * s,
        vy: Math.sin(a) * s,
        life: 0.6,
        color: "#ff6b35"
      });
    }
    this._shake = Math.min(14, this._shake + 5);
  }

  /** Rendu des particules météo (pluie, cendres, soleil) + brume optionnelle. */
  _drawWeather(ctx) {
    if (!this.weather) return;
    const type = this.weather.type;
    if (type === "mist") {
      // Brume légère grise sur tout l'écran (cirque de Cilaos)
      const grd = ctx.createLinearGradient(0, 0, 0, this.arena.height);
      grd.addColorStop(0, "rgba(220,225,230,0.18)");
      grd.addColorStop(0.5, "rgba(200,210,215,0.10)");
      grd.addColorStop(1, "rgba(170,180,190,0.05)");
      ctx.fillStyle = grd;
      ctx.fillRect(0, 0, this.arena.width, this.arena.height);
      return;
    }
    if (type === "rain") {
      // Pluie : traits obliques bleu-blanc transparents
      ctx.strokeStyle = "rgba(170,210,235,0.55)";
      ctx.lineWidth = 1.5;
      ctx.beginPath();
      for (const p of this.weather.particles) {
        // Trajet : de (x, y) vers (x + vx*0.02, y + vy*0.02) → orientation du trait
        ctx.moveTo(p.x, p.y);
        ctx.lineTo(p.x - p.len * 0.18, p.y + p.len);
      }
      ctx.stroke();
      // Voile bleuté général
      ctx.fillStyle = "rgba(80,110,140,0.07)";
      ctx.fillRect(0, 0, this.arena.width, this.arena.height);
      return;
    }
    if (type === "ash" || type === "ash-heavy") {
      // Cendres : petits cercles gris-marron qui dérivent
      for (const p of this.weather.particles) {
        ctx.fillStyle = p.color;
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
        ctx.fill();
      }
      if (type === "ash-heavy") {
        // Voile rougeâtre pour le cœur du volcan
        ctx.fillStyle = "rgba(80,30,15,0.12)";
        ctx.fillRect(0, 0, this.arena.width, this.arena.height);
      }
      return;
    }
    if (type === "sun") {
      // Poussière dorée volante (peu nombreuse, brillante)
      for (const p of this.weather.particles) {
        ctx.fillStyle = `rgba(255,230,160,${p.alpha})`;
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
        ctx.fill();
      }
      return;
    }
  }

  /** Renvoie le joueur vivant le plus proche d'une entité (pour zombies + pickups). */
  _nearestPlayerTo(entity) {
    const a = this.player;
    const b = this.player2;
    if (!b || !b.alive) return a;
    if (!a.alive) return b;
    const dxa = a.x - entity.x, dya = a.y - entity.y;
    const dxb = b.x - entity.x, dyb = b.y - entity.y;
    return (dxa * dxa + dya * dya) <= (dxb * dxb + dyb * dyb) ? a : b;
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

    // Corpses : zombies morts qui s'estompent (sous les zombies vivants)
    for (const c of this.corpses) {
      const alpha = c.life / c.maxLife;
      ctx.globalAlpha = alpha * 0.55;
      ctx.fillStyle = c.color;
      ctx.beginPath();
      ctx.arc(c.x, c.y + (1 - alpha) * 6, c.r * (0.9 + (1 - alpha) * 0.3), 0, Math.PI * 2);
      ctx.fill();
      // Halo gris au sol
      ctx.fillStyle = `rgba(40, 20, 10, ${alpha * 0.4})`;
      ctx.beginPath();
      ctx.ellipse(c.x, c.y + 4, c.r * 1.2, c.r * 0.4, 0, 0, Math.PI * 2);
      ctx.fill();
    }
    ctx.globalAlpha = 1;

    // Lava trails (sous les particules pour que les impacts les recouvrent)
    for (const lt of this.lavaTrails) {
      const lifeRatio = Math.max(0, lt.life / lt.maxLife);
      const alpha = 0.35 + lifeRatio * 0.45;
      // Cœur jaune-orange
      const grad = ctx.createRadialGradient(lt.x, lt.y, 2, lt.x, lt.y, lt.r);
      grad.addColorStop(0, `rgba(255,230,120,${alpha})`);
      grad.addColorStop(0.5, `rgba(255,140,40,${alpha * 0.85})`);
      grad.addColorStop(1, `rgba(180,40,10,0)`);
      ctx.fillStyle = grad;
      ctx.beginPath();
      ctx.arc(lt.x, lt.y, lt.r, 0, Math.PI * 2);
      ctx.fill();
      // Cratère central
      ctx.fillStyle = `rgba(255,80,20,${alpha * 0.55})`;
      ctx.beginPath();
      ctx.arc(lt.x, lt.y, lt.r * 0.4, 0, Math.PI * 2);
      ctx.fill();
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

    // Pickups (entre zombies et joueur pour visibilité)
    for (const p of this.pickups) p.draw(ctx);

    // Bullets : trail/glow palette par arme
    // Palette : halo extérieur (rgba), trail intermédiaire (rgba), cœur brillant (solide)
    const BULLET_FX = {
      pistol:   { halo: "rgba(255,140,40,0.35)",  trail: "255,215,107", core: "#fff6c8" },  // jaune doré
      shotgun:  { halo: "rgba(255,60,60,0.40)",   trail: "255,120,80",  core: "#ffe1d0" },  // rouge flamboyant
      volcano:  { halo: "rgba(255,80,20,0.50)",   trail: "255,170,40",  core: "#fff0a0" },  // orange volcan
      turret:   { halo: "rgba(244,185,66,0.32)",  trail: "244,185,66",  core: "#fff2b8" },  // cannelle pâle
    };
    for (const b of this.bullets) {
      const fx = BULLET_FX[b.weapon] || BULLET_FX.pistol;
      // Halo extérieur
      ctx.fillStyle = fx.halo;
      ctx.beginPath();
      ctx.arc(b.x, b.y, b.r * 2.4, 0, Math.PI * 2);
      ctx.fill();
      // Trail (3 cercles décroissants dans la direction opposée)
      const sp = Math.hypot(b.vx, b.vy) || 1;
      for (let i = 1; i <= 3; i++) {
        const tx = b.x - (b.vx / sp) * i * 4;
        const ty = b.y - (b.vy / sp) * i * 4;
        ctx.fillStyle = `rgba(${fx.trail},${0.6 - i * 0.18})`;
        ctx.beginPath();
        ctx.arc(tx, ty, b.r * (1.0 - i * 0.2), 0, Math.PI * 2);
        ctx.fill();
      }
      // Cœur brillant
      ctx.fillStyle = fx.core;
      ctx.beginPath();
      ctx.arc(b.x, b.y, b.r, 0, Math.PI * 2);
      ctx.fill();
    }

    // Météo dynamique par mission (entre décor et sprites pour profondeur)
    this._drawWeather(ctx);

    // Joueur(s) (P2 sous P1 pour pas masquer le curseur de P1)
    if (this.player2 && this.player2.alive) this.player2.draw(ctx, tSec);
    this.player.draw(ctx, tSec);

    // Marqueur "P1/P2" au-dessus des joueurs en coop (lisibilité)
    if (this.player2) {
      ctx.font = "bold 11px Segoe UI, sans-serif";
      ctx.textAlign = "center";
      if (this.player.alive) {
        ctx.fillStyle = "rgba(0,0,0,0.7)";
        ctx.fillText("P1", this.player.x + 1, this.player.y - this.player.r - 9);
        ctx.fillStyle = "#0099b8";
        ctx.fillText("P1", this.player.x, this.player.y - this.player.r - 10);
      }
      if (this.player2.alive) {
        ctx.fillStyle = "rgba(0,0,0,0.7)";
        ctx.fillText("P2", this.player2.x + 1, this.player2.y - this.player2.r - 9);
        ctx.fillStyle = "#e91e63";
        ctx.fillText("P2", this.player2.x, this.player2.y - this.player2.r - 10);
      }
      ctx.textAlign = "start";
    }

    // Shockwaves : anneaux qui s'élargissent (explosion exploder, spawn boss, etc.)
    for (const sw of this.shockwaves) {
      const t = 1 - (sw.life / sw.maxLife);  // 0 → 1
      const alpha = (1 - t) * 0.85;
      ctx.strokeStyle = sw.color.replace(/[\d.]+\)$/, `${alpha})`);
      ctx.lineWidth = 4 + (1 - t) * 3;
      ctx.beginPath();
      ctx.arc(sw.x, sw.y, sw.r, 0, Math.PI * 2);
      ctx.stroke();
      // Anneau secondaire intérieur
      if (sw.r > 30) {
        ctx.lineWidth = 2;
        ctx.beginPath();
        ctx.arc(sw.x, sw.y, sw.r * 0.7, 0, Math.PI * 2);
        ctx.stroke();
      }
    }

    // Floaters "+15" au-dessus de tout le décor (mais sous le HUD)
    ctx.textAlign = "center";
    ctx.font = "bold 16px Segoe UI, sans-serif";
    for (const f of this.floaters) {
      const alpha = Math.min(1, f.life * 1.2);
      ctx.globalAlpha = alpha;
      ctx.fillStyle = "rgba(0,0,0,0.65)";
      ctx.font = `bold ${f.size + 2}px Segoe UI, sans-serif`;
      ctx.fillText(f.text, f.x + 1, f.y + 1);  // ombre
      ctx.fillStyle = f.color;
      ctx.font = `bold ${f.size}px Segoe UI, sans-serif`;
      ctx.fillText(f.text, f.x, f.y);
    }
    ctx.globalAlpha = 1;
    ctx.textAlign = "start";

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
    // Flash orange plein écran au spawn du boss (effet "warning")
    if (this.bossFlash > 0.01) {
      ctx.fillStyle = `rgba(255,107,53,${this.bossFlash * 0.42})`;
      ctx.fillRect(0, 0, this.arena.width, this.arena.height);
    }

    // Barre de vie du boss (par-dessus la vignette, fixe en haut du canvas)
    const boss = this.zombies.find(z => z.alive && z.type === "boss");
    if (boss) {
      const w = this.arena.width * 0.6;
      const h = 18;
      const x = (this.arena.width - w) / 2;
      const y = 18;
      // Fond
      ctx.fillStyle = "rgba(0,0,0,0.75)";
      ctx.fillRect(x - 3, y - 3, w + 6, h + 6);
      // Cadre
      ctx.strokeStyle = "#b8902c";
      ctx.lineWidth = 2;
      ctx.strokeRect(x - 3, y - 3, w + 6, h + 6);
      // Remplissage HP : gradient selon phase
      const ratio = Math.max(0, boss.hp / boss.maxHp);
      const phaseColor = boss.phase === 3 ? "#ff3030"
                       : boss.phase === 2 ? "#ff8c2a"
                                          : "#f4b942";
      ctx.fillStyle = phaseColor;
      ctx.fillRect(x, y, w * ratio, h);
      // Label
      ctx.fillStyle = "#ffe6a0";
      ctx.font = "bold 14px Segoe UI, sans-serif";
      ctx.textAlign = "center";
      ctx.fillText(`BOSS — Phase ${boss.phase}/3   ${Math.ceil(boss.hp)} / ${boss.maxHp}`, this.arena.width / 2, y + 13);
      ctx.textAlign = "start";
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
