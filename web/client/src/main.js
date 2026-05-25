import { GameScene } from "./game/GameScene.js";
import { STORAGE_KEYS } from "../../shared/constants.js";

const canvas = document.getElementById("game");
const menu = document.getElementById("menu");
const hudEl = document.getElementById("hud");
const gameover = document.getElementById("gameover");

const hud = {
  wave:   document.getElementById("hud-wave"),
  score:  document.getElementById("hud-score"),
  coins:  document.getElementById("hud-coins"),
  best:   document.getElementById("hud-best"),
  hpFill: document.getElementById("hud-hp-fill")
};

const scene = new GameScene(canvas, hud);
window.__scene = scene;  // debug hook

function showMenu() {
  menu.classList.remove("hidden");
  hudEl.classList.add("hidden");
  gameover.classList.add("hidden");
  document.getElementById("menu-best").textContent =
    localStorage.getItem(STORAGE_KEYS.BEST_SCORE) || "0";
}

function startGame() {
  menu.classList.add("hidden");
  gameover.classList.add("hidden");
  hudEl.classList.remove("hidden");
  scene.start();
}

scene.onGameOver = ({ wave, score, coins }) => {
  document.getElementById("go-wave").textContent = wave;
  document.getElementById("go-score").textContent = score;
  document.getElementById("go-coins").textContent = coins;
  hudEl.classList.add("hidden");
  gameover.classList.remove("hidden");
};

document.getElementById("btn-start").addEventListener("click", startGame);
document.getElementById("btn-restart").addEventListener("click", startGame);

showMenu();
