// Upgrades.js
// Upgrades permanents proposés entre les vagues. Le joueur choisit 1 carte
// parmi 3 tirées au sort. Persistés en localStorage (UPGRADES) pour rester
// entre les missions.

import { STORAGE_KEYS, UPGRADE_TYPE } from "../../../shared/constants.js";

export const UPGRADE_DATA = {
  [UPGRADE_TYPE.MAX_HP]: {
    id: UPGRADE_TYPE.MAX_HP,
    title: "Cœur Solide",
    desc: "+20 HP maximum",
    icon: "♥",
    color: "#e94e1b",
    maxStacks: 5,
  },
  [UPGRADE_TYPE.DAMAGE]: {
    id: UPGRADE_TYPE.DAMAGE,
    title: "Balles Lourdes",
    desc: "+5 dégâts par balle",
    icon: "⚔",
    color: "#ff6b35",
    maxStacks: 5,
  },
  [UPGRADE_TYPE.FIRE_RATE]: {
    id: UPGRADE_TYPE.FIRE_RATE,
    title: "Doigt Rapide",
    desc: "-10% cooldown de tir",
    icon: "⚡",
    color: "#f4b942",
    maxStacks: 5,
  },
  [UPGRADE_TYPE.TURRET_POWER]: {
    id: UPGRADE_TYPE.TURRET_POWER,
    title: "Tourelle Renforcée",
    desc: "+15 dégâts tourelles",
    icon: "T",
    color: "#1c8b3e",
    maxStacks: 5,
  },
  [UPGRADE_TYPE.COIN_BONUS]: {
    id: UPGRADE_TYPE.COIN_BONUS,
    title: "Magnétisme Doré",
    desc: "+20% coins par kill",
    icon: "$",
    color: "#ffe6a0",
    maxStacks: 5,
  },
  [UPGRADE_TYPE.SPEED]: {
    id: UPGRADE_TYPE.SPEED,
    title: "Pieds Légers",
    desc: "+10% vitesse de déplacement",
    icon: "»",
    color: "#0099b8",
    maxStacks: 5,
  },
};

/** Charge les upgrades persistés. Retourne { [type]: stackCount }. */
export function loadUpgrades() {
  try {
    const raw = localStorage.getItem(STORAGE_KEYS.UPGRADES);
    if (!raw) return {};
    const parsed = JSON.parse(raw);
    return typeof parsed === "object" && parsed !== null ? parsed : {};
  } catch (_) {
    return {};
  }
}

export function saveUpgrades(upgrades) {
  try {
    localStorage.setItem(STORAGE_KEYS.UPGRADES, JSON.stringify(upgrades));
  } catch (_) { /* localStorage full */ }
}

export function resetUpgrades() {
  try { localStorage.removeItem(STORAGE_KEYS.UPGRADES); } catch (_) {}
}

/** Pioche 3 upgrades distincts. Évite ceux déjà au max. */
export function rollUpgradeChoices(currentUpgrades = {}) {
  const pool = Object.values(UPGRADE_DATA).filter(u => {
    const stacks = currentUpgrades[u.id] || 0;
    return stacks < u.maxStacks;
  });
  // Si plus rien à upgrader, on retourne quand même les 3 premiers (pour ne pas crash)
  if (pool.length === 0) return Object.values(UPGRADE_DATA).slice(0, 3);
  if (pool.length <= 3) return pool;
  // Shuffle Fisher-Yates puis prend 3
  const shuffled = [...pool];
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
  }
  return shuffled.slice(0, 3);
}

/** Applique les upgrades sur les stats du joueur/jeu. Retourne {hp, dmg, fireMul, turretBonus, coinMul, speedMul}. */
export function computeBonuses(upgrades = {}) {
  return {
    hpBonus:        (upgrades[UPGRADE_TYPE.MAX_HP]        || 0) * 20,
    damageBonus:    (upgrades[UPGRADE_TYPE.DAMAGE]        || 0) * 5,
    fireRateMul:    Math.pow(0.90, upgrades[UPGRADE_TYPE.FIRE_RATE] || 0),
    turretBonus:    (upgrades[UPGRADE_TYPE.TURRET_POWER]  || 0) * 15,
    coinMul:        1 + (upgrades[UPGRADE_TYPE.COIN_BONUS]|| 0) * 0.20,
    speedMul:       1 + (upgrades[UPGRADE_TYPE.SPEED]     || 0) * 0.10,
  };
}

export function applyUpgrade(upgrades, upgradeId) {
  const data = UPGRADE_DATA[upgradeId];
  if (!data) return upgrades;
  const newUpgrades = { ...upgrades };
  const current = newUpgrades[upgradeId] || 0;
  if (current >= data.maxStacks) return upgrades;
  newUpgrades[upgradeId] = current + 1;
  saveUpgrades(newUpgrades);
  return newUpgrades;
}
