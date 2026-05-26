// Constantes partagées entre client web et serveur futur.

export const STATE = {
  MENU: "menu",
  PLAYING: "playing",
  PAUSED: "paused",
  GAMEOVER: "gameover"
};

export const ENEMY_TYPE = {
  NORMAL: "normal",
  FAST: "fast",
  HEAVY: "heavy",
  MINIBOSS: "miniBoss",
  BOSS: "boss"
};

export const DEFENSE_TYPE = {
  TURRET: "turret",
  BARRICADE: "barricade"
};

export const STORAGE_KEYS = {
  BEST_SCORE: "zombies.bestScore",
  TOTAL_COINS: "zombies.totalCoins",
  STORY_MISSION_INDEX: "zombies.storyMission",
  STORY_INTRO_SEEN: "zombies.storyIntroSeen",
  PLAYER_NAME: "zombies.playerName",
  TOP_SCORES: "zombies.topScores",
  UPGRADES: "zombies.upgrades",
  AUDIO_VOLUME_MUSIC: "zombies.audioMusic",
  AUDIO_VOLUME_SFX: "zombies.audioSfx",
  AUDIO_MUTED: "zombies.audioMuted"
};

// 5 types de pickups droppés par les zombies (cf. PICKUP_DROPS dans Zombie.js)
export const PICKUP_TYPE = {
  HEAL:    "heal",     // +25 HP (vert)
  AMMO:    "ammo",     // buff dégâts x1.5 (bleu)
  SPEED:   "speed",    // buff vitesse x1.3 pendant 6s (violet)
  BOMB:    "bomb",     // détruit tous les zombies dans 120px (rouge)
  MAGNET:  "magnet"    // attire les pickups à 200px pendant 8s (or)
};

// Upgrades permanents proposés entre vagues (cf. UpgradeChoice.js)
export const UPGRADE_TYPE = {
  MAX_HP:        "max_hp",         // +20 HP max
  DAMAGE:        "damage",         // +5 dégâts balle
  FIRE_RATE:     "fire_rate",      // -10% cooldown
  TURRET_POWER:  "turret_power",   // +15 dégâts tourelle
  COIN_BONUS:    "coin_bonus",     // +20% coins par kill
  SPEED:         "speed_perm"      // +10% vitesse joueur permanent
};
