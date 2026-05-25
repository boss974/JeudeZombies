import { CONFIG } from "../../../shared/config.js";
import { ENEMY_TYPE } from "../../../shared/constants.js";
import { Zombie } from "./Zombie.js";

// Pilote les vagues : difficulté progressive, mini-boss et boss périodiques.
export class WaveManager {
  constructor(arena) {
    this.arena = arena;
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
    return CONFIG.wave.baseEnemies + CONFIG.wave.enemiesPerWave * (n - 1);
  }

  _pickType() {
    const w = this.wave;
    const r = Math.random();
    const heavyUnlocked = w >= CONFIG.wave.heavyUnlockAt;
    const fastUnlocked  = w >= CONFIG.wave.fastUnlockAt;

    if (heavyUnlocked && r < 0.2) return ENEMY_TYPE.HEAVY;
    if (fastUnlocked  && r < 0.5) return ENEMY_TYPE.FAST;
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
          this.spawnTimer = CONFIG.wave.spawnInterval;
          const zombie = new Zombie(sp.x, sp.y, type);
          if (isNight) {
            zombie.speed *= CONFIG.world.nightDifficultyMultiplier;
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
