import { CONFIG } from "../../../shared/config.js";
import { ENEMY_TYPE } from "../../../shared/constants.js";
import { Zombie } from "./Zombie.js";

// Pilote les vagues : difficulté progressive, mini-boss et boss périodiques.
export class WaveManager {
  constructor(arena, difficulty = 1) {
    this.arena = arena;
    this.difficulty = Math.max(1, difficulty);
    this.wave = 0;
    this.toSpawn = 0;
    this.spawnTimer = 0;
    this.interWaveTimer = CONFIG.wave.interWaveDelay;
    this.status = "intermission";  // intermission | spawning | clearing
    this.message = "";
    this.messageTimer = 0;
  }

  start() {
    this.wave = 0;
    this.interWaveTimer = 1.0;
    this.status = "intermission";
    this._setMessage("Préparez-vous", 1.0);
  }

  _setMessage(text, time) {
    this.message = text;
    this.messageTimer = time;
  }

  _enemiesForWave(n) {
    const w = CONFIG.wave;
    const bonus = Math.floor((n - 1) / w.bonusEnemiesEveryN) * w.bonusEnemiesAmount;
    return Math.ceil((w.baseEnemies + w.enemiesPerWave * (n - 1) + bonus) * this.difficulty);
  }

  // Intervalle de spawn dans la vague : descend progressivement vers spawnIntervalMin
  // pour densifier les vagues tardives sans pour autant les rendre injouables.
  _spawnIntervalForWave(n) {
    const w = CONFIG.wave;
    const decay = Math.pow(1 - w.spawnIntervalDecay, Math.max(0, n - 1));
    return Math.max(w.spawnIntervalMin, w.spawnInterval * decay);
  }

  _pickType() {
    const w = this.wave;
    const cfg = CONFIG.wave;
    const r = Math.random();
    const shielded = w >= cfg.shieldedUnlockAt;
    const exploder = w >= cfg.exploderUnlockAt;
    const heavy    = w >= cfg.heavyUnlockAt;
    const fast     = w >= cfg.fastUnlockAt;

    // Distribution par paliers de difficulté. À la vague 9+ on a tous les types.
    if (shielded && r < 0.13) return ENEMY_TYPE.SHIELDED;
    if (exploder && r < 0.25) return ENEMY_TYPE.EXPLODER;
    if (heavy    && r < 0.40) return ENEMY_TYPE.HEAVY;
    if (fast     && r < 0.65) return ENEMY_TYPE.FAST;
    return ENEMY_TYPE.NORMAL;
  }

  _spawnPoint() {
    // Spawn juste hors arène, sur un bord aléatoire
    const side = Math.floor(Math.random() * 4);
    const pad = 30;
    const w = this.arena.width, h = this.arena.height;
    switch (side) {
      case 0: return { x: Math.random() * w, y: -pad };
      case 1: return { x: w + pad, y: Math.random() * h };
      case 2: return { x: Math.random() * w, y: h + pad };
      default:return { x: -pad, y: Math.random() * h };
    }
  }

  update(dt, zombies, isNight = false) {
    this.messageTimer = Math.max(0, this.messageTimer - dt);

    if (this.status === "intermission") {
      this.interWaveTimer -= dt;
      if (this.interWaveTimer <= 0) this._startNextWave();
      return null;
    }

    if (this.status === "spawning") {
      this.spawnTimer -= dt;
      if (this.spawnTimer <= 0 && this.toSpawn > 0) {
        const liveCount = zombies.filter(z => z.alive).length;
        if (liveCount < CONFIG.wave.maxActive) {
          const sp = this._spawnPoint();
          const type = this._pickWaveType();
          this.toSpawn--;
          this.spawnTimer = this._spawnIntervalForWave(this.wave);

          // Scaling de la vague : par wave + par mission difficulty, cappés.
          const w = CONFIG.wave;
          const speedMul = Math.min(
            w.maxSpeedMultiplier,
            (1 + (this.wave - 1) * w.speedScalingPerWave) * (1 + (this.difficulty - 1) * 0.18)
          );
          const hpMul = Math.min(
            w.maxHpMultiplier,
            (1 + (this.wave - 1) * w.hpScalingPerWave) * (1 + (this.difficulty - 1) * 0.22)
          );

          const zombie = new Zombie(sp.x, sp.y, type);
          zombie.speed *= speedMul;
          zombie.baseSpeed = zombie.speed;
          zombie.hp = Math.ceil(zombie.hp * hpMul);
          zombie.maxHp = zombie.hp;
          zombie.score = Math.ceil(zombie.score * this.difficulty);
          zombie.coins = Math.ceil(zombie.coins * Math.min(1.8, this.difficulty));
          if (isNight) {
            zombie.speed *= CONFIG.world.nightDifficultyMultiplier;
            zombie.baseSpeed = zombie.speed;
            zombie.hp = Math.ceil(zombie.hp * 1.12);
            zombie.maxHp = zombie.hp;
          }
          return zombie;
        }
        this.spawnTimer = 0.2;
      }
      if (this.toSpawn === 0) this.status = "clearing";
      return null;
    }

    if (this.status === "clearing") {
      const liveCount = zombies.filter(z => z.alive).length;
      if (liveCount === 0) {
        this.status = "intermission";
        this.interWaveTimer = CONFIG.wave.interWaveDelay;
        this._setMessage(`Vague ${this.wave} terminée !`, CONFIG.wave.interWaveDelay);
      }
    }
    return null;
  }

  _pickWaveType() {
    // Première spawn de la vague : sert pour boss/mini-boss
    if (this._pendingBoss) {
      this._pendingBoss = false;
      return ENEMY_TYPE.BOSS;
    }
    if (this._pendingMini) {
      this._pendingMini = false;
      return ENEMY_TYPE.MINIBOSS;
    }
    return this._pickType();
  }

  _startNextWave() {
    this.wave++;
    this.toSpawn = this._enemiesForWave(this.wave);
    this.spawnTimer = 0;
    this.status = "spawning";

    this._pendingBoss = this.wave % CONFIG.wave.bossEveryN === 0;
    this._pendingMini = !this._pendingBoss && this.wave % CONFIG.wave.miniBossEveryN === 0;

    if (this._pendingBoss)      this._setMessage(`BOSS - Vague ${this.wave}`, 2.0);
    else if (this._pendingMini) this._setMessage(`Mini-Boss - Vague ${this.wave}`, 2.0);
    else                        this._setMessage(`Vague ${this.wave}`, 1.6);
  }
}
