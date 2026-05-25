// Config commun pour web et serveur futur.
// Garde les valeurs simples : facile à relire et équilibrer.

export const CONFIG = {
  arena: {
    width: 960,
    height: 540,
    padding: 16
  },

  player: {
    radius: 14,
    speed: 220,           // pixels par seconde
    maxHp: 100,
    fireRate: 0.18,       // secondes entre tirs
    bulletSpeed: 520,
    bulletDamage: 25,
    bulletLifetime: 1.2,
    invulnAfterHit: 0.5
  },

  defense: {
    turret: {
      label: "Tourelle",
      cost: 18,
      radius: 16,
      range: 190,
      fireRate: 0.55,
      damage: 20,
      bulletSpeed: 430,
      color: "#f4b942"
    },
    barricade: {
      label: "Barricade",
      cost: 10,
      radius: 24,
      hp: 260,
      color: "#8a5a2b"
    }
  },

  zombie: {
    normal:  { radius: 14, speed: 70,  hp: 50,  damage: 10, score: 10, coins: 1, color: "#5a8a4a" },
    fast:    { radius: 11, speed: 130, hp: 30,  damage: 8,  score: 15, coins: 2, color: "#8acb6a" },
    heavy:   { radius: 20, speed: 45,  hp: 140, damage: 20, score: 25, coins: 3, color: "#3a5a2a" },
    miniBoss:{ radius: 28, speed: 60,  hp: 350, damage: 35, score: 80, coins: 12, color: "#a23030" },
    boss:    { radius: 40, speed: 55,  hp: 900, damage: 50, score: 250, coins: 40, color: "#d92020" }
  },

  wave: {
    baseEnemies: 6,
    enemiesPerWave: 3,         // ajoutés par vague
    interWaveDelay: 2.5,       // pause entre vagues (secondes)
    spawnInterval: 0.7,        // délai entre spawns dans une vague
    miniBossEveryN: 5,
    bossEveryN: 10,
    fastUnlockAt: 2,
    heavyUnlockAt: 4,
    maxActive: 40              // cap simultané (anti-lag)
  },

  world: {
    dayNightSeconds: 120,
    nightDifficultyMultiplier: 1.22
  },

  scoring: {
    waveClearBonus: 25
  }
};
