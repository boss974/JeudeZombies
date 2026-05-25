import { GameScene } from "./game/GameScene.js";
import { STORAGE_KEYS } from "../../shared/constants.js";
import { STORY, randomLine } from "../../shared/story.js";

const canvas    = document.getElementById("game");
const introEl   = document.getElementById("intro");
const menuEl    = document.getElementById("menu");
const hudEl     = document.getElementById("hud");
const gameover  = document.getElementById("gameover");
const victory   = document.getElementById("victory");
const dialog    = document.getElementById("dialog");
const dialogText = document.getElementById("dialog-text");

const hud = {
  mission: document.getElementById("hud-mission"),
  wave:    document.getElementById("hud-wave"),
  score:   document.getElementById("hud-score"),
  coins:   document.getElementById("hud-coins"),
  best:    document.getElementById("hud-best"),
  hpFill:  document.getElementById("hud-hp-fill")
};

// ============================================================================
// Story state
// ============================================================================
function loadMissionIndex() {
  return parseInt(localStorage.getItem(STORAGE_KEYS.STORY_MISSION_INDEX) || "0", 10);
}
function saveMissionIndex(i) {
  localStorage.setItem(STORAGE_KEYS.STORY_MISSION_INDEX, String(i));
}
function currentMission() {
  return STORY.missions[Math.min(loadMissionIndex(), STORY.missions.length - 1)];
}

// ============================================================================
// Scene
// ============================================================================
const scene = new GameScene(canvas, hud);
window.__scene = scene;

scene.onWaveStart = () => showDialog(randomLine("waveStart"), "default");
scene.onWaveCleared = (wave) => {
  showDialog(randomLine("waveCleared"), "good");
  const mission = currentMission();
  if (wave >= mission.waves) {
    scene.pause();
    showVictory(mission);
  }
};
scene.onBossWave = () => showDialog(randomLine("bossWarning"), "danger");

scene.onGameOver = ({ wave, score, coins }) => {
  document.getElementById("go-mission").textContent = currentMission().city;
  document.getElementById("go-wave").textContent = wave;
  document.getElementById("go-score").textContent = score;
  document.getElementById("go-coins").textContent = coins;
  hudEl.classList.add("hidden");
  hideDialog();
  gameover.classList.remove("hidden");
};

// ============================================================================
// Dialog
// ============================================================================
let dialogTimer = null;
function showDialog(text, kind = "default") {
  if (!text) return;
  dialogText.textContent = text;
  dialog.classList.remove("hidden");
  // restart animation
  dialog.style.animation = "none"; void dialog.offsetWidth; dialog.style.animation = "";
  dialog.style.borderColor = kind === "danger" ? "#ff3030"
                          : kind === "good"   ? "#6ed87a"
                          : "#c8552a";
  clearTimeout(dialogTimer);
  dialogTimer = setTimeout(hideDialog, 3500);
}
function hideDialog() {
  dialog.classList.add("hidden");
}

// ============================================================================
// Screens
// ============================================================================
function showIntro() {
  document.getElementById("intro-text").textContent = STORY.intro.join("\n");
  introEl.classList.remove("hidden");
}

function showMenu() {
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
  const mission = currentMission();
  introEl.classList.add("hidden");
  menuEl.classList.add("hidden");
  gameover.classList.add("hidden");
  victory.classList.add("hidden");
  hudEl.classList.remove("hidden");
  hud.mission.textContent = mission.city;
  scene.start();
  // Petit délai pour que l'intro de mission s'affiche après le démarrage
  setTimeout(() => showDialog(`${mission.title} — ${mission.city}`, "default"), 600);
}

function showVictory(mission) {
  document.getElementById("victory-city").textContent = mission.city;
  document.getElementById("victory-reward").textContent = `+${mission.reward} coins`;
  document.getElementById("victory-flavor").textContent = randomLine("cityCleared");
  hudEl.classList.add("hidden");
  hideDialog();
  victory.classList.remove("hidden");

  // Avance la mission
  const idx = loadMissionIndex();
  if (idx < STORY.missions.length - 1) saveMissionIndex(idx + 1);

  // Crédite les coins permanents
  const total = parseInt(localStorage.getItem(STORAGE_KEYS.TOTAL_COINS) || "0", 10);
  localStorage.setItem(STORAGE_KEYS.TOTAL_COINS, String(total + mission.reward));
}

// ============================================================================
// Bindings
// ============================================================================
document.getElementById("btn-intro-continue").addEventListener("click", () => {
  localStorage.setItem(STORAGE_KEYS.STORY_INTRO_SEEN, "1");
  showMenu();
});
document.getElementById("btn-start").addEventListener("click", startGame);
document.getElementById("btn-restart").addEventListener("click", startGame);
document.getElementById("btn-next-mission").addEventListener("click", showMenu);
document.getElementById("btn-reset-story").addEventListener("click", (e) => {
  e.preventDefault();
  localStorage.removeItem(STORAGE_KEYS.STORY_MISSION_INDEX);
  localStorage.removeItem(STORAGE_KEYS.STORY_INTRO_SEEN);
  showIntro();
});

// ============================================================================
// Boot
// ============================================================================
if (localStorage.getItem(STORAGE_KEYS.STORY_INTRO_SEEN) === "1") {
  showMenu();
} else {
  showIntro();
}
