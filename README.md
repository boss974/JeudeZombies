# L'Éveil de la Fournaise — Jeu de Zombies

Tower defense coopératif cartoon, sur l'île de La Réunion. Tu défends les
villes vague par vague pendant que le Piton de la Fournaise libère sa cendre.

> Le Piton de la Fournaise est entré en éruption. Une étrange poussière orange
> descend des nuages. Les habitants s'endorment puis se relèvent, les yeux vides.
> Sauve les 24 communes. Réveille La Réunion.

Le ton est **cartoon apocalypse non-gore**, pensé pour un public jeune
(cf. `SAFETY_LEGAL_FRAMEWORK.md`).

## Deux versions

| Version | État | Comment lancer |
|---|---|---|
| **Web solo** | ✅ Jouable | Servir `web/` en HTTP, ouvrir `/client/` |
| **Roblox**   | ✅ Squelette + carte | Rojo serve → connecter le plugin Studio |

## Démarrage rapide

### Version web

```bash
npx http-server web -p 5180
# ouvrir http://localhost:5180/client/
```

ZQSD ou flèches pour bouger, souris pour viser et tirer.

### Version Roblox

```bash
rojo serve default.project.json
```

Puis dans Roblox Studio : ouvrir un place vide, installer le plugin Rojo
(`rojo plugin install`), cliquer **Connect**. Le jeu se charge avec :

- la carte de La Réunion (île + 2 pitons + 24 villes + océan)
- les services serveur (vagues, zombies, récompenses, sauvegarde)
- l'UI client (intro + dialogues narratifs)

Presser **Play** pour tester.

## Histoire

L'histoire complète et la progression des 7 actes sont décrites dans
[`STORY.md`](STORY.md).

## Architecture

```
web/                       Prototype web solo (HTML/Canvas/JS)
  client/                  Front : index.html + assets
  shared/                  Config + constants + story (réutilisé serveur futur)

roblox/                    Projet Roblox synchronisé via Rojo
  ReplicatedStorage/Shared Config, Constants, Remotes, Story
  ServerScriptService      GameController + Services (Wave/Zombie/...)
                           + ReunionMap (la carte)
  StarterPlayer/Scripts    ClientController, StoryUI

default.project.json       Mapping Rojo
```

Détails dans [`ARCHITECTURE.md`](ARCHITECTURE.md).

## Documents

- [`ARCHITECTURE.md`](ARCHITECTURE.md) — structure technique
- [`GAME_DESIGN.md`](GAME_DESIGN.md) — boucle, modes, ennemis
- [`STORY.md`](STORY.md) — scénario et lore
- [`MARKET_POSITIONING_TOWER_DEFENSE.md`](MARKET_POSITIONING_TOWER_DEFENSE.md) — direction tower defense coop
- [`SAFETY_LEGAL_FRAMEWORK.md`](SAFETY_LEGAL_FRAMEWORK.md) — règles sécurité jeune public
- [`DEPENDENCIES.md`](DEPENDENCIES.md) — stratégie dépendances
- [`PURCHASE_STRATEGY.md`](PURCHASE_STRATEGY.md) — stratégie achats
- [`ROADMAP.md`](ROADMAP.md) — étapes V0.1 → V1.0
- [`CLAUDE_BRIEF.md`](CLAUDE_BRIEF.md) — brief IA

## Priorités

1. ✅ Architecture propre
2. ✅ Prototype web solo jouable
3. ✅ Prototype Roblox jouable (squelette + map)
4. ✅ Système de vagues partagé
5. ✅ Histoire et narration (intro + dialogues + lore)
6. ⏳ Tower defense : placement d'unités
7. ⏳ Progression et sauvegarde inter-sessions Roblox (DataStore en place)
8. ⏳ Multijoueur web (Socket.IO)
9. ⏳ Monétisation cosmétique Roblox
10. ⏳ Version publique

## Méthode

Le projet doit rester clair pour être repris par plusieurs IA ou développeurs
(ChatGPT, Claude, Codex, Roblox Studio, GitHub). Chaque fichier est commenté
simplement, avec une logique facile à relire.
