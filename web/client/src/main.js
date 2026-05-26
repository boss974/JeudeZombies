import { AudioManager } from "./audio/AudioManager.js";
import { GameScene } from "./game/GameScene.js";
import { CONFIG } from "../../shared/config.js";
import { DEFENSE_TYPE, STORAGE_KEYS } from "../../shared/constants.js";
import { STORY, randomLine, setAdultMode } from "../../shared/story.js";

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
  phase: document.getElementById("hud-phase"),
  combo: document.getElementById("hud-combo")
};

function loadMissionIndex() {
  return parseInt(localStorage.getItem(STORAGE_KEYS.STORY_MISSION_INDEX) || "0", 10);
}

function saveMissionIndex(i) {
  localStorage.setItem(STORAGE_KEYS.STORY_MISSION_INDEX, String(i));
}

function currentMission() {
  return STORY.missions[Math.min(loadMissionIndex(), STORY.missions.length - 1)];
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
  }
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

scene.onGameOver = ({ wave, score, coins }) => {
  document.getElementById("go-mission").textContent = currentMission().city;
  document.getElementById("go-wave").textContent = wave;
  document.getElementById("go-score").textContent = score;
  document.getElementById("go-coins").textContent = coins;
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
}

function startGame() {
  userAudioStart();
  audio.setMode("combat");
  audio.startGame();
  const mission = currentMission();
  introEl.classList.add("hidden");
  menuEl.classList.add("hidden");
  gameover.classList.add("hidden");
  victory.classList.add("hidden");
  hudEl.classList.remove("hidden");
  hud.mission.textContent = mission.city;
  scene.mission = mission;
  scene.start();
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
    showDialog(`Arme sonore : ${label}`, "default");
  }
});

if (localStorage.getItem(STORAGE_KEYS.STORY_INTRO_SEEN) === "1") {
  showMenu();
} else {
  showIntro();
}
