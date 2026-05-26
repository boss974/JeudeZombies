// Config commun pour web et serveur futur.
// Garde les valeurs simples : facile à relire et équilibrer.

export const CONFIG = {
  // Mode adulte (+18) — bascule les dialogues vers STORY.adultLines.
  // Voir ADULT_MODE.md pour les implications et les limites maintenues.
  adultMode: true,

  brand: {
    colors: {
      bleuLagon: "#0099b8",
      jauneSoleil: "#f4b942",
      rougeFlamboyant: "#e94e1b",
      orangeFournaise: "#ff6b35",
      vertTropical: "#1c8b3e",
      sableNoir: "#2d2d2d",
      roseHibiscus: "#e91e63"
    }
  },

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
      baseCost: 18,              // coût première tourelle
      costMul: 1.45,             // chaque tourelle suivante coûte +45%
      baseLimit: 3,              // max tourelles à la vague 1
      limitPerWaves: 3,          // +1 tourelle débloquée toutes les N vagues
      maxLimit: 8,               // cap absolu
      radius: 16,
      range: 190,
      fireRate: 0.55,
      damage: 20,
      bulletSpeed: 430,
      color: "#f4b942"
    },
    barricade: {
      label: "Barricade",
      baseCost: 10,
      costMul: 1.25,             // +25% par barricade posée
      baseLimit: 5,
      limitPerWaves: 2,
      maxLimit: 10,
      radius: 24,
      hp: 260,
      color: "#8a5a2b"
    }
  },

  zombie: {
    normal:   { radius: 14, speed: 70,  hp: 50,  damage: 10, score: 10,  coins: 1,  color: "#5a8a4a" },
    fast:     { radius: 11, speed: 130, hp: 30,  damage: 8,  score: 15,  coins: 2,  color: "#8acb6a" },
    heavy:    { radius: 20, speed: 45,  hp: 140, damage: 20, score: 25,  coins: 3,  color: "#3a5a2a" },
    // Exploder : sprinter orange qui explose à la mort ET au contact (AOE 80px, 30 dmg).
    // Conseil : tirer de loin, ne pas s'en approcher en mêlée.
    exploder: { radius: 13, speed: 110, hp: 35,  damage: 5,  score: 22,  coins: 3,  color: "#ff7a2a",
                aoeRadius: 80, aoeDamage: 30 },
    // Shielded : porte un bouclier frontal. Tir de face = 50% des dégâts seulement.
    // Doit être contourné ou hit par une tourelle latérale.
    shielded: { radius: 18, speed: 60,  hp: 200, damage: 18, score: 35,  coins: 4,  color: "#5a7a9a",
                shieldReduction: 0.55, shieldArc: Math.PI * 0.65 },
    miniBoss: { radius: 28, speed: 60,  hp: 350, damage: 35, score: 80,  coins: 12, color: "#a23030" },
    boss:     { radius: 40, speed: 55,  hp: 900, damage: 50, score: 250, coins: 40, color: "#d92020" }
  },

  // Boss : 3 phases avec patterns spécifiques (gérés dans Zombie.js + GameScene.js)
  boss: {
    phaseThresholds: { phase2: 0.66, phase3: 0.33 },
    dash: {
      cooldown: 5.0,             // toutes les 5s
      duration: 1.0,             // x2 speed pendant 1s
      speedMultiplier: 2.2
    },
    spawn: {
      cooldown: 8.0,             // phase 2 : spawn 2 minions toutes les 8s
      cooldownPhase3: 3.0,       // phase 3 : 1 minion toutes les 3s
      minionType: "fast"
    },
    roar: {
      cooldown: 12.0,            // phase 3 uniquement
      radius: 200,
      slowDuration: 2.0,
      slowMultiplier: 0.45       // joueur ralenti à 45%
    },
    lavaTrail: {
      // Phase 3 : flaque de lave chaque 0.4s sous le boss
      interval: 0.4,
      radius: 22,
      life: 4.0,
      damagePerSec: 18
    }
  },

  wave: {
    baseEnemies: 6,
    enemiesPerWave: 3,             // ajoutés par vague
    bonusEnemiesEveryN: 3,         // +2 ennemis additionnels toutes les 3 vagues
    bonusEnemiesAmount: 2,
    interWaveDelay: 3.0,           // pause entre vagues
    spawnInterval: 0.7,            // délai entre spawns
    spawnIntervalMin: 0.32,        // plancher (anti-impossible)
    spawnIntervalDecay: 0.035,     // -3.5% par vague
    miniBossEveryN: 5,
    bossEveryN: 10,
    fastUnlockAt: 2,
    heavyUnlockAt: 4,
    exploderUnlockAt: 7,
    shieldedUnlockAt: 9,
    maxActive: 50,                 // cap simultané (anti-lag)
    // Scaling par vague (multiplie par (1 + N * scale))
    hpScalingPerWave: 0.20,        // +20% HP par wave (cap dans WaveManager)
    speedScalingPerWave: 0.045,    // +4.5% speed par wave
    maxSpeedMultiplier: 1.7,       // cap dur (sinon devient injouable)
    maxHpMultiplier: 5.0           // cap dur HP scaling
  },

  world: {
    dayNightSeconds: 120,
    nightDifficultyMultiplier: 1.22
  },

  monetization: {
    // Prototype web: pas de paiement reel ici. Sert a tester l'economie.
    coinPacks: [
      { id: "tiCoins", label: "Ti Pack Coins", coins: 250 },
      { id: "grosCoins", label: "Gros Pack Coins", coins: 1200 }
    ],
    rewardedAd: { label: "Regarder une pub volontaire", coins: 35 },
    supporter: { label: "Supporter Fournaise", dailyCoins: 150 }
  },

  scoring: {
    waveClearBonus: 25
  }
};
