import { STORAGE_KEYS } from "../../../shared/constants.js";

export function getPlayerName() {
  return localStorage.getItem(STORAGE_KEYS.PLAYER_NAME) || "";
}

export function savePlayerName(name) {
  const clean = sanitizeName(name);
  localStorage.setItem(STORAGE_KEYS.PLAYER_NAME, clean);
  return clean;
}

export function sanitizeName(name) {
  const clean = String(name || "")
    .replace(/[^\wÀ-ÿ -]/g, "")
    .trim()
    .slice(0, 18);
  return clean || "Survivant";
}

export function loadTopScores() {
  try {
    const scores = JSON.parse(localStorage.getItem(STORAGE_KEYS.TOP_SCORES) || "[]");
    return Array.isArray(scores) ? scores.slice(0, 10) : [];
  } catch (_) {
    return [];
  }
}

export function clearTopScores() {
  try { localStorage.removeItem(STORAGE_KEYS.TOP_SCORES); } catch (_) {}
}

export function recordScore(entry) {
  const scores = loadTopScores();
  const next = {
    name: sanitizeName(entry.name),
    score: Math.max(0, Math.floor(entry.score || 0)),
    wave: Math.max(0, Math.floor(entry.wave || 0)),
    city: String(entry.city || "Inconnue").slice(0, 32),
    coins: Math.max(0, Math.floor(entry.coins || 0)),
    date: new Date().toISOString()
  };
  scores.push(next);
  scores.sort((a, b) => b.score - a.score || b.wave - a.wave || b.coins - a.coins);
  const top = scores.slice(0, 10);
  localStorage.setItem(STORAGE_KEYS.TOP_SCORES, JSON.stringify(top));
  return { entry: next, rank: top.findIndex((s) => s === next) + 1, scores: top };
}
