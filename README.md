# L'Éveil de la Fournaise — Tower defense cartoon La Réunion

> Le Piton de la Fournaise est entré en éruption. Une étrange poussière orange
> descend des nuages. Les habitants s'endorment puis se relèvent, les yeux vides.
> **Sauve les 24 communes. Réveille La Réunion.**

🌋 **Cartoon apocalypse non-gore** • **Public jeune** • **Multi-plateforme**
(PC, mobile, console via Roblox) • **Coop jusqu'à 6 joueurs**

---

## 🚀 Démarrage rapide

### Web (le plus simple pour tester)

```bash
npx http-server web -p 5180
# ouvrir http://localhost:5180/client/
```

**Touches** : ZQSD/flèches = bouger, souris = viser/tirer, `1`/`2` = tourelle
/barricade, `E` ou clic droit = poser défense, `SHIFT` = saut géant, `TAB` =
touches, `F1` = paramètres, `G` = galerie, `M` = mission.

### Roblox (le jeu principal)

```bash
rojo serve default.project.json
```

Puis Studio → ouvrir un place vide → installer plugin Rojo
(`rojo plugin install`) → cliquer **Connect** → **Play**.

Pour publier sur Roblox : suivre [`PUBLISH.md`](PUBLISH.md).

---

## 📚 Documentation organisée

### 🎯 Pour comprendre le projet (lecture obligatoire)

| Doc | À quoi ça sert |
|---|---|
| [`GAME_KNOWLEDGE.md`](GAME_KNOWLEDGE.md) | **Référence canonique** — la vérité du projet, à lire avant toute modification |
| [`CAHIER_DES_CHARGES.md`](CAHIER_DES_CHARGES.md) | **Contrat formel** — périmètre, contraintes, critères d'acceptation V1.0 |
| [`PRODUCT_VISION.md`](PRODUCT_VISION.md) | **Résumé exécutif** — promesse, piliers, boucle de jeu |

### 🎮 Pour comprendre le gameplay

| Doc | À quoi ça sert |
|---|---|
| [`STORY.md`](STORY.md) | Pitch + scénario 7 actes + lore créole |
| [`MISSIONS_DETAILLEES.md`](MISSIONS_DETAILLEES.md) | Histoire + lieux touristiques + objectifs par village |
| [`GAME_DESIGN.md`](GAME_DESIGN.md) | Boucle, modes, ennemis |
| [`MARKET_POSITIONING_TOWER_DEFENSE.md`](MARKET_POSITIONING_TOWER_DEFENSE.md) | Positionnement TD coop Roblox |

### 🛠️ Pour comprendre la tech

| Doc | À quoi ça sert |
|---|---|
| [`ARCHITECTURE.md`](ARCHITECTURE.md) | Structure technique (services, Remotes, Rojo) |
| [`MULTIPLAYER.md`](MULTIPLAYER.md) | Multijoueur Roblox (coop 6 joueurs natif) |
| [`MULTIPLATFORM_STRATEGY.md`](MULTIPLATFORM_STRATEGY.md) | Roadmap multi-supports (Roblox→Web→Godot mobile) |
| [`DEPENDENCIES.md`](DEPENDENCIES.md) | Stratégie dépendances (minimales) |

### 🎨 Pour comprendre le design

| Doc | À quoi ça sert |
|---|---|
| [`GAME_KNOWLEDGE.md §3`](GAME_KNOWLEDGE.md) | **Palette officielle Réunion** (canonique) |
| [`REUNION_VISUAL_IDENTITY.md`](REUNION_VISUAL_IDENTITY.md) | Règles d'application + idées skins thématiques |

### 💰 Pour comprendre la monétisation

| Doc | À quoi ça sert |
|---|---|
| [`MONETIZATION_STRATEGY.md`](MONETIZATION_STRATEGY.md) | Revenus Roblox (products, passes, subs, ads), KPIs |
| [`PURCHASE_STRATEGY.md`](PURCHASE_STRATEGY.md) | Stratégie achats côté développement (assets, etc.) |

### 🔒 Pour la sécurité et la publication

| Doc | À quoi ça sert |
|---|---|
| [`SAFETY_LEGAL_FRAMEWORK.md`](SAFETY_LEGAL_FRAMEWORK.md) | Règles sécurité jeune public (chat, gore, données) |
| [`ADULT_MODE.md`](ADULT_MODE.md) | Mode +18 par joueur (validation âge serveur) |
| [`PUBLISH.md`](PUBLISH.md) | Procédure complète publication Roblox (22 étapes) |
| [`assets/`](assets/) | Icône SVG + miniature SVG + social cards |

### 🗺️ Pour piloter

| Doc | À quoi ça sert |
|---|---|
| [`ROADMAP.md`](ROADMAP.md) | Étapes V0.1 → V1.0 |
| [`CLAUDE_BRIEF.md`](CLAUDE_BRIEF.md) | Brief IA initial (historique) |

---

## ✅ État actuel (V0.x)

### Livré

- ✅ Architecture propre (Rojo + ES modules)
- ✅ Prototype web solo jouable (canvas 2D, post-process, audio procédural)
- ✅ Prototype Roblox jouable (terrain voxel, 24 communes, vagues)
- ✅ Système de vagues partagé (config commune)
- ✅ Histoire 7 actes + dialogues créoles (mode adulte adouci dispo)
- ✅ Première boucle tower defense : barricades + tourelles
- ✅ Map La Réunion avec relief, cascades, lave, pluie est, cycle jour/nuit
- ✅ Patrimoine : cases créoles, boutiks, lieux de culte, route NRL, street food
- ✅ Stand street food (samoussa, bouchon, frites, limonade)
- ✅ Mobile : MobileControls + auto-aim + haptic + tutoriel
- ✅ Settings joueur : pseudo + date naissance + mode adulte par joueur (≥18)
- ✅ Missions séquentielles : POI physiques + photo + validation serveur
- ✅ Collection : 16 achievements + souvenirs persistants + galerie touche G
- ✅ Multiplayer natif Roblox (coop jusqu'à 6)
- ✅ Assets publication (icône + miniature + PUBLISH.md + social cards)
- ✅ Audio procédural (web) + sons rbxasset (Roblox)
- ✅ Leaderboard web + difficulté qui scale

### En attente

- ⏳ Tests Studio multi-joueur + device mobile (à faire avant publication)
- ⏳ Publication Roblox (place publique) — voir [`PUBLISH.md`](PUBLISH.md)
- ⏳ Boss final "Roi-Cendre" — modèle géant unique pour l'Acte VII
- ⏳ PNJ vivants dans les villes (silhouettes habitants)
- ⏳ Portage Godot mobile (après validation Roblox)

---

## 📐 Méthode et règles

1. **GAME_KNOWLEDGE.md est la source de vérité**. En cas de conflit avec un
   autre document, ce fichier prévaut.
2. **CAHIER_DES_CHARGES.md est le contrat**. Toute évolution majeure du
   périmètre doit y être consignée.
3. **Aucun gore, aucun chat custom, aucun pay-to-win**. Cf.
   [`SAFETY_LEGAL_FRAMEWORK.md`](SAFETY_LEGAL_FRAMEWORK.md).
4. **Tout serveur-autoritaire** côté Roblox. Le client ne décide rien de
   sensible (dégâts, score, coins, sauvegarde).
5. **Commits conventionnels en français** (`feat:`, `fix:`, `chore:`,
   `docs:`). Messages courts, descriptifs, qui expliquent le **pourquoi**.
6. **Le projet doit rester lisible** par n'importe quel humain ou IA qui
   reprend la suite. Commentaires en français, structure claire.

## 🤝 Crédits

Projet conçu et piloté par **boss974** (Grondin Mickaël, La Réunion).
Implémentation et docs : assistance IA multi-agents (Claude, ChatGPT, Codex).
