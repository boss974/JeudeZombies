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
  TOP_SCORES: "zombies.topScores"
};
