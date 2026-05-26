import { AudioManager } from "./audio/AudioManager.js";
import { GameScene } from "./game/GameScene.js";
import { getPlayerName, loadTopScores, recordScore, savePlayerName, clearTopScores } from "./profile/PlayerProfile.js";
import { CONFIG } from "../../shared/config.js";
import { DEFENSE_TYPE, STORAGE_KEYS } from "../../shared/constants.js";
import { STORY, randomLine, setAdultMode } from "../../shared/story.js";
import { UPGRADE_DATA, applyUpgrade, computeBonuses, loadUpgrades, resetUpgrades, rollUpgradeChoices } from "./game/Upgrades.js";
import { PICKUP_TYPE_DATA } from "./game/Pickup.js";

setAdultMode(CONFIG.adultMode);

const canvas = document.getElementById("game");
const introEl = document.getElementById("intro");
const menuEl = document.getElementById("menu");
const hudEl = document.getElementById("hud");
const gameover = document.getElementById("gameover");
const victory = document.getElementById("victory");
const dialog = document.getElementById("dialog");
const dialogText = document.getElementById("dialog-text");
const audioButton = document.getElementById("btn-audio");
const playerNameInput = document.getElementById("player-name");
const topScoresEl = document.getElementById("top-scores");

const audio = new AudioManager();
window.__audio = audio;

function refreshAudioButton() {
  audioButton.textContent = audio.enabled ? "SON ON" : "SON OFF";
  audioButton.classList.toggle("audio-off", !audio.enabled);
}

function userAudioStart() {
  audio.start();
  refreshAudioButton();
}

refreshAudioButton();
addEventListener("pointerdown", userAudioStart, { once: true });

const hud = {
  mission: document.getElementById("hud-mission"),
  wave: document.getElementById("hud-wave"),
  score: document.getElementById("hud-score"),
  coins: document.getElementById("hud-coins"),
  best: document.getElementById("hud-best"),
  hpFill: document.getElementById("hud-hp-fill"),
  hpFillP2: document.getElementById("hud-hp-fill-p2"),
  rowP2: document.getElementById("hud-row-p2"),
  phase: document.getElementById("hud-phase"),
  combo: document.getElementById("hud-combo"),
  pseudo: document.getElementById("hud-pseudo"),
  difficulty: document.getElementById("hud-difficulty"),
  buffs: document.getElementById("hud-buffs"),
  // Compteurs de défenses (nouveau)
  defCountTurret:    document.getElementById("def-count-turret"),
  defCountBarricade: document.getElementById("def-count-barricade"),
  defCostTurret:     document.getElementById("def-cost-turret"),
  defCostBarricade:  document.getElementById("def-cost-barricade")
};

const upgradeScreen = document.getElementById("upgrade-choice");
const upgradeCardsEl = document.getElementById("upgrade-cards");
const volMusicEl = document.getElementById("vol-music");
const volSfxEl = document.getElementById("vol-sfx");

function loadMissionIndex() {
  return parseInt(localStorage.getItem(STORAGE_KEYS.STORY_MISSION_INDEX) || "0", 10);
}

function saveMissionIndex(i) {
  localStorage.setItem(STORAGE_KEYS.STORY_MISSION_INDEX, String(i));
}

function currentMission() {
  return STORY.missions[Math.min(loadMissionIndex(), STORY.missions.length - 1)];
}

function currentDifficulty() {
  const missionIndex = loadMissionIndex();
  const topScorePressure = Math.min(0.5, (parseInt(localStorage.getItem(STORAGE_KEYS.BEST_SCORE) || "0", 10) / 5000));
  return 1 + missionIndex * 0.16 + topScorePressure;
}

function renderTopScores() {
  const scores = loadTopScores();
  topScoresEl.innerHTML = "";
  if (!scores.length) {
    const li = document.createElement("li");
    li.textContent = "Aucun record pour l'instant";
    topScoresEl.appendChild(li);
    return;
  }
  for (const s of scores) {
    const li = document.createElement("li");
    li.textContent = `${s.name} - ${s.score} pts - vague ${s.wave} - ${s.city}`;
    topScoresEl.appendChild(li);
  }
}

const scene = new GameScene(canvas, hud);
scene.mission = currentMission();
window.__scene = scene;

scene.onWaveStart = () => {
  audio.setMode("combat");
  audio.waveStart();
  showDialog(randomLine("waveStart"), "default");
};

scene.onWaveCleared = (wave) => {
  audio.setMode("ambient");
  audio.waveClear();
  showDialog(randomLine("waveCleared"), "good");
  const mission = currentMission();
  if (wave >= mission.waves) {
    scene.pause();
    showVictory(mission);
    return;
  }
  // Choix d'upgrade entre 2 vagues sur 3 (offre toutes les 2 vagues)
  if (wave > 0 && wave % 2 === 0) {
    setTimeout(() => showUpgradeChoice(), 800);
  }
};

scene.onPickup = (type) => {
  audio.zombieDown?.("normal");
  const data = PICKUP_TYPE_DATA[type];
  if (data) showDialog(`${data.icon} ${data.label}`, "good");
};

scene.onBossWave = () => {
  const isBoss = scene.waveManager?.wave % CONFIG.wave.bossEveryN === 0;
  audio.setMode(isBoss ? "boss" : "combat");
  audio.bossWarning(isBoss ? "boss" : "miniBoss");
  showDialog(randomLine("bossWarning"), "danger");
};

scene.onPlayerShoot = () => showDialog(randomLine("playerShoot"), "default");
scene.onPlayerFire = () => audio.shoot();
scene.onBulletHit = () => audio.hit();
scene.onZombieKilled = (type) => audio.zombieDown(type);
scene.onCombo = (combo) => audio.combo(combo);
scene.onPlayerHit = () => showDialog(randomLine("playerHit"), "danger");
scene.onPlayerDamaged = () => audio.playerHurt();
scene.onLowHp = () => showDialog(randomLine("lowHp"), "danger");
scene.onDefensePlaced = (name) => {
  audio.placeDefense(scene.selectedDefense);
  showDialog(`${name} posée. Sa zafer !`, "good");
};
scene.onNoCoins = () => {
  audio.noCoins();
  showDialog("Pas assez de coins, tilamb.", "danger");
};
scene.onDefenseLimitReached = (type, limit) => {
  audio.noCoins();
  const label = type === "turret" ? "tourelles" : "barricades";
  showDialog(`Max ${limit} ${label} atteint — détruis-en une ou attends la prochaine vague.`, "danger");
};
scene.onBossPhaseChange = (phase) => {
  if (phase === 2) {
    audio.bossWarning("boss");
    showDialog("⚠ PHASE 2 — Le boss spawn des minions et dash sur toi !", "danger");
  } else if (phase === 3) {
    audio.bossWarning("boss");
    showDialog("☢ PHASE 3 — Lave + cri assourdissant ! Cours, bat'carré !", "danger");
  }
};
scene.onBossDash = () => audio.bossDash?.();
scene.onBossRoar = () => {
  audio.bossRoar?.();
  showDialog("ROAAAR ! Tu es ralenti !", "danger");
};
scene.onExploderBoom = () => {
  audio.exploderBoom?.();
};
scene.onScorePopup = (gain) => {
  // Seulement un petit ping pour les gros gains (combo) pour ne pas saturer
  if (gain >= 25) audio.scorePopup?.();
};
scene.onCoopStart = () => {
  hud.rowP2?.classList.remove("hidden");
  showDialog("🎮 Coop activé ! Manette branchée = P2 (stick gauche bouge, stick droit vise, RT tire, LB pose défense).", "good");
};

scene.onGameOver = ({ wave, score, coins }) => {
  const result = recordScore({ name: playerNameInput.value, score, wave, coins, city: currentMission().city });
  document.getElementById("go-mission").textContent = currentMission().city;
  document.getElementById("go-wave").textContent = wave;
  document.getElementById("go-score").textContent = score;
  document.getElementById("go-coins").textContent = coins;
  document.getElementById("go-rank").textContent = result.rank > 0 ? `Top 10 local : rang #${result.rank}` : "Pas dans le Top 10";
  renderTopScores();
  hudEl.classList.add("hidden");
  hideDialog();
  audio.setMode("menu");
  audio.gameOver();
  gameover.classList.remove("hidden");
};

let dialogTimer = null;
function showDialog(text, kind = "default") {
  if (!text) return;
  dialogText.textContent = text;
  dialog.classList.remove("hidden");
  dialog.style.animation = "none";
  void dialog.offsetWidth;
  dialog.style.animation = "";
  dialog.style.borderColor = kind === "danger" ? "#ff3030"
    : kind === "good" ? "#6ed87a"
    : "#c8552a";
  clearTimeout(dialogTimer);
  dialogTimer = setTimeout(hideDialog, 3500);
}

function hideDialog() {
  dialog.classList.add("hidden");
}

function showIntro() {
  audio.setMode("menu");
  document.getElementById("intro-text").textContent = STORY.intro.join("\n");
  introEl.classList.remove("hidden");
}

function showMenu() {
  audio.setMode("ambient");
  const mission = currentMission();
  introEl.classList.add("hidden");
  menuEl.classList.remove("hidden");
  hudEl.classList.add("hidden");
  gameover.classList.add("hidden");
  victory.classList.add("hidden");
  hideDialog();
  document.getElementById("menu-mission-title").textContent = mission.title;
  document.getElementById("menu-mission-city").textContent = mission.city;
  document.getElementById("menu-best").textContent = localStorage.getItem(STORAGE_KEYS.BEST_SCORE) || "0";
  playerNameInput.value = getPlayerName();
  renderTopScores();
}

function startGame() {
  userAudioStart();
  audio.setMode("combat");
  audio.startGame();
  const playerName = savePlayerName(playerNameInput.value);
  playerNameInput.value = playerName;
  const mission = currentMission();
  introEl.classList.add("hidden");
  menuEl.classList.add("hidden");
  gameover.classList.add("hidden");
  victory.classList.add("hidden");
  hudEl.classList.remove("hidden");
  hud.mission.textContent = mission.city;
  scene.mission = mission;
  scene.start({ difficulty: currentDifficulty() });
  setTimeout(() => showDialog(`${mission.title} - ${mission.city}`, "default"), 600);
}

function showVictory(mission) {
  audio.setMode("ambient");
  audio.victory();
  document.getElementById("victory-city").textContent = mission.city;
  document.getElementById("victory-reward").textContent = `+${mission.reward} coins`;
  document.getElementById("victory-flavor").textContent = randomLine("cityCleared");
  hudEl.classList.add("hidden");
  hideDialog();
  victory.classList.remove("hidden");

  const idx = loadMissionIndex();
  if (idx < STORY.missions.length - 1) saveMissionIndex(idx + 1);

  const total = parseInt(localStorage.getItem(STORAGE_KEYS.TOTAL_COINS) || "0", 10);
  localStorage.setItem(STORAGE_KEYS.TOTAL_COINS, String(total + mission.reward));
}

// ============================================================================
// Choix d'upgrade entre vagues
// ============================================================================
function showUpgradeChoice() {
  const currentUpgrades = loadUpgrades();
  const choices = rollUpgradeChoices(currentUpgrades);
  upgradeCardsEl.innerHTML = "";
  for (const ch of choices) {
    const stacks = currentUpgrades[ch.id] || 0;
    const card = document.createElement("button");
    card.className = "upgrade-card";
    card.style.borderColor = ch.color;
    card.innerHTML = `
      <div class="upgrade-icon" style="color:${ch.color}">${ch.icon}</div>
      <div class="upgrade-title">${ch.title}</div>
      <div class="upgrade-desc">${ch.desc}</div>
      <div class="upgrade-stacks">Niveau ${stacks}/${ch.maxStacks}</div>
    `;
    card.addEventListener("click", () => {
      audio.click?.();
      applyUpgrade(currentUpgrades, ch.id);
      upgradeScreen.classList.add("hidden");
      // Recharge immédiatement les bonus sur la scène en cours (sans attendre reset)
      scene.bonuses = computeBonuses(loadUpgrades());
      // Applique le bonus HP max au joueur live (les autres bonus sont lus par frame)
      if (scene.player && scene.bonuses?.hpBonus > 0) {
        const newMax = (CONFIG.player.maxHp || 100) + scene.bonuses.hpBonus;
        if (newMax > scene.player.maxHp) {
          const gained = newMax - scene.player.maxHp;
          scene.player.maxHp = newMax;
          scene.player.hp = Math.min(newMax, scene.player.hp + gained);
        }
      }
      showDialog(`${ch.icon} ${ch.title} appliquée !`, "good");
    });
    upgradeCardsEl.appendChild(card);
  }
  upgradeScreen.classList.remove("hidden");
}

document.getElementById("btn-skip-upgrade").addEventListener("click", () => {
  audio.click?.();
  upgradeScreen.classList.add("hidden");
});

// Boutons effacement
document.getElementById("btn-clear-scores").addEventListener("click", (e) => {
  e.preventDefault();
  audio.click?.();
  clearTopScores();
  renderTopScores();
  showDialog("Top 10 effacé.", "default");
});
document.getElementById("btn-reset-upgrades").addEventListener("click", (e) => {
  e.preventDefault();
  audio.click?.();
  resetUpgrades();
  showDialog("Upgrades remis à zéro.", "default");
});

// Volume sliders (mute persistant + 2 canaux séparés)
function loadVolumes() {
  const m = parseInt(localStorage.getItem(STORAGE_KEYS.AUDIO_VOLUME_MUSIC) || "60", 10);
  const s = parseInt(localStorage.getItem(STORAGE_KEYS.AUDIO_VOLUME_SFX) || "80", 10);
  if (volMusicEl) volMusicEl.value = m;
  if (volSfxEl) volSfxEl.value = s;
  audio.setMusicVolume?.(m / 100);
  audio.setSfxVolume?.(s / 100);
}
loadVolumes();
volMusicEl?.addEventListener("input", () => {
  const v = parseInt(volMusicEl.value, 10);
  localStorage.setItem(STORAGE_KEYS.AUDIO_VOLUME_MUSIC, String(v));
  audio.setMusicVolume?.(v / 100);
});
volSfxEl?.addEventListener("input", () => {
  const v = parseInt(volSfxEl.value, 10);
  localStorage.setItem(STORAGE_KEYS.AUDIO_VOLUME_SFX, String(v));
  audio.setSfxVolume?.(v / 100);
});

// Mise à jour HUD en boucle (pseudo, difficulté, buffs, défenses)
setInterval(() => {
  if (hudEl.classList.contains("hidden")) return;
  if (hud.pseudo) hud.pseudo.textContent = getPlayerName() || "Joueur";
  if (hud.difficulty) hud.difficulty.textContent = `x${(scene.difficulty || 1).toFixed(2)}`;
  // Toggle de la barre P2 selon présence de player2
  if (hud.rowP2) {
    if (scene.player2) hud.rowP2.classList.remove("hidden");
    else hud.rowP2.classList.add("hidden");
  }
  if (hud.buffs && scene.buffs) {
    const t = scene.worldTime || 0;
    const list = [];
    if (scene.buffs.damage > t) list.push(`⚡${Math.ceil(scene.buffs.damage - t)}s`);
    if (scene.buffs.speed > t) list.push(`»${Math.ceil(scene.buffs.speed - t)}s`);
    if (scene.buffs.magnet > t) list.push(`U${Math.ceil(scene.buffs.magnet - t)}s`);
    if (scene.bossRoarSlow > t) list.push(`SLOW ${Math.ceil(scene.bossRoarSlow - t)}s`);
    hud.buffs.textContent = list.length ? list.join(" ") : "—";
  }
  // Compteurs / coûts de défense
  if (scene.currentDefenseCount && scene.waveManager) {
    const tNow = scene.currentDefenseCount("turret");
    const tMax = scene.currentDefenseLimit("turret");
    const tCost = scene.currentDefenseCost("turret");
    if (hud.defCountTurret) {
      hud.defCountTurret.textContent = `${tNow}/${tMax}`;
      hud.defCountTurret.classList.toggle("full", tNow >= tMax);
    }
    if (hud.defCostTurret) {
      hud.defCostTurret.textContent = `${tCost} ¢`;
      hud.defCostTurret.classList.toggle("too-expensive", (scene.coins || 0) < tCost);
    }
    const bNow = scene.currentDefenseCount("barricade");
    const bMax = scene.currentDefenseLimit("barricade");
    const bCost = scene.currentDefenseCost("barricade");
    if (hud.defCountBarricade) {
      hud.defCountBarricade.textContent = `${bNow}/${bMax}`;
      hud.defCountBarricade.classList.toggle("full", bNow >= bMax);
    }
    if (hud.defCostBarricade) {
      hud.defCostBarricade.textContent = `${bCost} ¢`;
      hud.defCostBarricade.classList.toggle("too-expensive", (scene.coins || 0) < bCost);
    }
  }
}, 250);

document.getElementById("btn-intro-continue").addEventListener("click", () => {
  audio.click();
  localStorage.setItem(STORAGE_KEYS.STORY_INTRO_SEEN, "1");
  showMenu();
});
document.getElementById("btn-start").addEventListener("click", startGame);
document.getElementById("btn-restart").addEventListener("click", startGame);
document.getElementById("btn-next-mission").addEventListener("click", () => {
  audio.click();
  showMenu();
});
document.getElementById("btn-reset-story").addEventListener("click", (e) => {
  e.preventDefault();
  audio.click();
  localStorage.removeItem(STORAGE_KEYS.STORY_MISSION_INDEX);
  localStorage.removeItem(STORAGE_KEYS.STORY_INTRO_SEEN);
  showIntro();
});
audioButton.addEventListener("click", (e) => {
  e.stopPropagation();
  audio.setEnabled(!audio.enabled);
  audio.click();
  refreshAudioButton();
});

document.getElementById("btn-defense-turret").addEventListener("click", () => {
  audio.selectDefense(DEFENSE_TYPE.TURRET);
  scene.setSelectedDefense(DEFENSE_TYPE.TURRET);
  showDialog("Tourelle sélectionnée : clic droit pour poser.", "default");
});
document.getElementById("btn-defense-barricade").addEventListener("click", () => {
  audio.selectDefense(DEFENSE_TYPE.BARRICADE);
  scene.setSelectedDefense(DEFENSE_TYPE.BARRICADE);
  showDialog("Barricade sélectionnée : clic droit pour poser.", "default");
});
addEventListener("keydown", (e) => {
  if (e.code === "Digit1") {
    audio.selectDefense(DEFENSE_TYPE.TURRET);
    scene.setSelectedDefense(DEFENSE_TYPE.TURRET);
  }
  if (e.code === "Digit2") {
    audio.selectDefense(DEFENSE_TYPE.BARRICADE);
    scene.setSelectedDefense(DEFENSE_TYPE.BARRICADE);
  }
  if (e.code === "KeyQ") {
    const weapon = audio.cycleWeapon();
    const label = weapon === "shotgun" ? "Fusil lourd" : weapon === "volcano" ? "Canon Fournaise" : "Pistolet";
    showDialog(`Arme : ${label}`, "default");
    scene.weapon = weapon;  // sync pour la couleur des trails
  }
  // Pause menu ESC : toggle in-game, ouvre/ferme l'overlay
  if (e.code === "Escape") {
    if (gameover.classList.contains("hidden") === false) return;  // pas en game over
    if (menu.classList.contains("hidden") === false) return;       // pas en menu
    togglePauseMenu();
  }
});

// === Pause Menu ===
const pauseOverlay = document.getElementById("pause-menu");
function togglePauseMenu() {
  if (!pauseOverlay) return;
  if (pauseOverlay.classList.contains("hidden")) {
    pauseOverlay.classList.remove("hidden");
    scene.pause?.();
    audio.setMode?.("menu");
  } else {
    pauseOverlay.classList.add("hidden");
    scene.resume?.();
    audio.setMode?.("game");
  }
}
document.getElementById("btn-pause-resume")?.addEventListener("click", () => togglePauseMenu());
document.getElementById("btn-pause-restart")?.addEventListener("click", () => {
  pauseOverlay.classList.add("hidden");
  scene.start({ difficulty: scene.difficulty });
  audio.setMode?.("game");
});
document.getElementById("btn-pause-menu")?.addEventListener("click", () => {
  pauseOverlay.classList.add("hidden");
  scene.pause?.();
  hudEl.classList.add("hidden");
  audio.setMode?.("menu");
  showMenu();
});

if (localStorage.getItem(STORAGE_KEYS.STORY_INTRO_SEEN) === "1") {
  showMenu();
} else {
  showIntro();
}
