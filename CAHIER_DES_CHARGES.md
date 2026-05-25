# Cahier des Charges — L'Éveil de la Fournaise

> Document contractuel décrivant **ce qui doit être livré**, dans quelles
> conditions et avec quels critères d'acceptation. À tenir à jour à chaque
> évolution majeure du périmètre.
>
> Version : **1.0** — 25 mai 2026

---

## 1. Identité du projet

| Champ | Valeur |
|---|---|
| Nom du jeu | **L'Éveil de la Fournaise** |
| Genre | Tower defense coopératif, narratif, cartoon-apocalypse |
| Univers | Île de **La Réunion**, île française de l'océan Indien |
| Plateformes cibles | Roblox (principale), Web (prototype solo) |
| Public visé | Jeune (10-16 ans), accessible adultes |
| Langue principale | Français (+ touches de créole réunionnais) |
| Maître d'ouvrage | boss974 (Grondin Mickaël) |
| Maître d'œuvre | équipe IA assistée (Claude, agents spécialisés) |
| Repo | https://github.com/boss974/JeudeZombies |

## 2. Pitch en une phrase

> Défends les 24 communes de La Réunion contre des vagues de zombies réveillés
> par l'éruption du Piton de la Fournaise, et rallume l'île ville par ville.

## 3. Objectifs

### Objectifs business

1. Disposer d'un prototype Roblox jouable et **partageable** sous 1 mois.
2. Valider la boucle de gameplay avant tout investissement marketing.
3. Préparer une publication Roblox publique d'ici 3 mois.

### Objectifs gameplay

1. Boucle de jeu **lisible en moins de 30 secondes** par un nouveau joueur.
2. Sentiment de **progression visible** à chaque ville libérée.
3. **Rétention** : raison concrète de revenir le lendemain (mission quotidienne,
   classement, événement temporaire).

### Objectifs narratifs

1. Une histoire **complète** (7 actes, début-milieu-fin).
2. Un ton **chaleureux malgré l'apocalypse** (cf. pilier émotionnel).
3. Une identité visuelle **immédiatement reconnaissable** comme "Réunion".

## 4. Périmètre fonctionnel (MUST)

### MVP — V1.0 (publiable)

| Item | Détail | Statut |
|---|---|---|
| Carte de La Réunion | 800x640 studs, terrain voxel, 24 communes, 2 pitons, 3 cirques | ✅ Livré |
| Histoire 7 actes | Saint-Denis → Piton-de-la-Fournaise + boss final | ✅ Livré |
| Système de vagues | 5 types ennemis (Normal/Fast/Heavy/MiniBoss/Boss) | ✅ Livré |
| HUD | Mission, vague, score, coins, vie, best | ✅ Livré |
| Intro narrative | Plein écran avec lore animé | ✅ Livré |
| Dialogues contextuels | 9 catégories, hooks par ville | ✅ Livré |
| Cascades | 3 (Mafate, Salazie, Cilaos) avec particules + son | ✅ Livré |
| Sons | Ambiance (cascade, volcan), UI, zombies, victoire | ✅ Livré |
| Zombies stylisés | Cartoon non-gore, palette par type | ✅ Livré |
| Identité visuelle Réunion | Palette + éléments tropicaux (palmiers, drapeaux, hibiscus) | 🚧 En cours |
| Save/load progression | DataStore Roblox + localStorage web | ✅ Livré |
| Sécurité jeune public | Chat filtré, pas de gore, pas de données perso | ✅ Livré |

### Hors périmètre MVP — V2.0+

| Item | Pourquoi reporté |
|---|---|
| Placement d'unités défensives (tourelles, barricades) | Demande modélisation + balance, mieux après validation gameplay |
| Multijoueur Roblox coop | Ajoute complexité réseau, validation solo d'abord |
| Multijoueur web | Nécessite serveur Node.js, infrastructure |
| Mode endless | À ajouter après V1.0 |
| Événements temporaires | À ajouter après V1.0 |
| Battle pass cosmétique | Monétisation à valider après audience |
| Skins joueurs | Cosmétique secondaire |
| Voix-off intro | Audio coûteux, post-MVP |

## 5. Contraintes

### Contraintes techniques

1. **Pas de dépendance externe payante** au MVP. Tous les assets doivent
   être : créés en code, builtins Roblox, ou libres de droits avérés.
2. **Toute logique sensible côté serveur** (anti-cheat).
3. **Idempotence** : aucun script qui construit le monde ne doit dupliquer.
4. **Rojo obligatoire** : la source de vérité reste GitHub, jamais Studio.
5. **Compatibilité Roblox** : codé en Luau 5.4, sans modules externes.
6. **Compatibilité web** : ES modules, fonctionne en file:// ou serveur statique
   (pas de bundler obligatoire).

### Contraintes éditoriales (sécurité)

1. **Aucun gore** : pas de sang, démembrement, cris réalistes.
2. **Aucun texte libre joueur** : pas de chat custom, pas de panneaux éditables.
3. **Aucune donnée personnelle** : seul UserId Roblox.
4. **Style cartoon** strict : silhouettes simples, couleurs franches.
5. **Pas de pay-to-win** : monétisation 100% cosmétique.
6. **Conformité** : Roblox Community Standards + Maturity Guidelines respectés.

### Contraintes de planning

| Phase | Échéance | Livrable |
|---|---|---|
| Phase 1 — Prototype | Atteint | Web jouable + skeleton Roblox |
| Phase 2 — Map + Story | Atteint | Île + 7 actes + cascades + sons + zombies |
| Phase 3 — Identité visuelle | T+1 semaine | Palette Réunion + décors tropicaux |
| Phase 4 — Tests + ajustements | T+2 semaines | Beta interne |
| Phase 5 — Publication Roblox | T+1 mois | Place publique |

### Contraintes budgétaires

| Phase | Budget |
|---|---|
| Phase 1-3 (proto + identité) | **0 €** (Claude + temps) |
| Phase 4 (icône, miniature) | Petit budget assets visuels Roblox |
| Phase 5 (publicité Roblox) | Conditionné à la rétention mesurée |

## 6. Identité visuelle — La Réunion

### Palette officielle

| Rôle | Nom | Hex | Usage |
|---|---|---|---|
| Volcan | Orange Fournaise | `#ff6b35` | Titres, accents, glow lave |
| Drapeau (rouge) | Rouge Flamboyant | `#e94e1b` | Boutons primaires, alertes |
| Drapeau (jaune) | Jaune Cannelle | `#f4b942` | Texte de mission, panneaux |
| Drapeau (bleu) | Bleu Lagon | `#0099b8` | Eau, océan, surlignage |
| Tropical | Vert Émeraude | `#1c8b3e` | Forêt, vague nettoyée |
| Volcanique | Sable Noir | `#2d2d2d` | Backgrounds, ombres |
| Pluie | Bleu Pluie | `#5d8fa8` | États froids, info |
| Hibiscus | Rose Hibiscus | `#e91e63` | Cosmétique, fleurs |

> Source du drapeau : drapeau **non officiel** mais reconnu de La Réunion
> (Volcan rayonnant) : disque jaune au-dessus de fond bleu et triangles rouges.

### Symboles à utiliser

- **Hibiscus** (fleur emblématique tropicale)
- **Flamboyant** (arbre à fleurs rouges)
- **Palmier / cocotier** (côte)
- **Volcan en éruption** (Piton de la Fournaise)
- **Vague océanique** (couleur turquoise)
- **Sable noir** (plages volcaniques)
- **Lampions créoles** (festif/sécurité)

### Typo

| Usage | Police |
|---|---|
| Titres web | "Segoe UI", system-ui, sans-serif — fallback |
| Corps web | "Segoe UI", system-ui |
| Titres Roblox | `Enum.Font.GothamBold` |
| Corps Roblox | `Enum.Font.Gotham` |

> À évaluer après V1.0 : adopter une police custom "tropicale" (Cookie, Pacifico
> ou similaire) via Google Fonts, sous réserve de licence et CDN.

## 7. Architecture livraison

```
JeudeZombies/
├── *.md (docs)              ↘ contrat + lore + tech
├── default.project.json      ↘ Rojo mapping
├── roblox/                   ↘ source Luau (Rojo-synced)
│   ├── ReplicatedStorage/Shared/  (Config, Constants, Remotes, Story)
│   ├── ServerScriptService/       (GameController, ReunionMap, TerrainBuilder,
│   │                              Waterfalls, SoundManager, Decorations)
│   ├── ServerScriptService/Services/  (Wave, Zombie, Reward, PlayerData,
│   │                                    Shop, Story, ZombieFactory)
│   └── StarterPlayer/StarterPlayerScripts/  (Client, StoryUI, SoundClient)
└── web/
    ├── client/  (index.html + src + assets)
    └── shared/  (config, constants, story)
```

## 8. Critères d'acceptation (V1.0)

### Roblox

- [ ] Le jeu démarre en moins de 5 secondes après Play
- [ ] L'intro s'affiche pour tout nouveau joueur
- [ ] Le joueur spawn à Saint-Denis (mission Acte I par défaut)
- [ ] Les vagues démarrent automatiquement quand un joueur est présent
- [ ] Au moins 3 zombies sont visibles à l'écran à la vague 1
- [ ] Le son de cascade est audible près d'un cirque
- [ ] Le HUD affiche mission, vague, score, coins, vie
- [ ] Les portails de ville sont nominatifs et lisibles
- [ ] L'ambiance est apocalyptique (aube orange)
- [ ] Aucun crash en 10 minutes de jeu

### Web

- [x] L'intro s'affiche au premier lancement (lore complet)
- [x] Le menu affiche la mission courante
- [x] Le HUD affiche tout (mission, vague, score, coins, vie, best)
- [x] Les dialogues s'affichent contextuellement
- [x] L'écran de victoire avance la mission
- [x] La progression est sauvegardée en localStorage
- [x] Le jeu fonctionne en file:// et via serveur statique

### Documentation

- [x] README clair avec démarrage rapide
- [x] STORY.md décrit tous les actes
- [x] GAME_KNOWLEDGE.md sert de référence unique
- [x] CAHIER_DES_CHARGES.md (ce fichier) à jour
- [x] SAFETY_LEGAL_FRAMEWORK.md respecté

## 9. Risques & mitigations

| Risque | Impact | Mitigation |
|---|---|---|
| Performances Roblox dégradées si > 25 zombies | Lag, gameplay cassé | Cap `MaxActive = 25` dans Config, configurable |
| Dépendance à des assets non vérifiés | Refus de modération Roblox | Uniquement `rbxasset://` builtins + code procédural |
| Sécurité enfants (chat, harcèlement) | Bannissement Roblox | Chat filtré standard, pas de chat custom |
| Désintérêt joueur (manque de fun) | Faible rétention | Valider la boucle avant d'investir |
| Dépendance à Rojo CLI | Bloque les contributions externes | Toujours générer un `.rbxl` build dans le repo (option) |
| Atterissage du joueur dans l'eau | Frustration | Murs invisibles côtiers à confirmer |

## 10. Gouvernance

### Décisions de design

Toute évolution majeure du **périmètre** doit :

1. Être justifiée par un objectif (cf. §3)
2. Être consignée dans `GAME_KNOWLEDGE.md` (§7 conventions)
3. Mettre à jour ce CDC (version +0.1)
4. Faire l'objet d'un commit explicite (`docs: maj CDC vX.Y`)

### Contributions IA

Tout agent IA travaillant sur ce projet doit :

1. **Lire `GAME_KNOWLEDGE.md`** avant toute action
2. **Respecter ce CDC** (en particulier §5 contraintes et §6 identité)
3. Ne pas commiter directement — toujours laisser le maître d'œuvre humain
   valider
4. Documenter ce qui a été livré dans un rapport synthétique

## 11. Annexes

- [`README.md`](README.md) — démarrage rapide
- [`GAME_KNOWLEDGE.md`](GAME_KNOWLEDGE.md) — référence canonique
- [`STORY.md`](STORY.md) — scénario complet
- [`GAME_DESIGN.md`](GAME_DESIGN.md) — boucle gameplay
- [`ARCHITECTURE.md`](ARCHITECTURE.md) — structure technique
- [`SAFETY_LEGAL_FRAMEWORK.md`](SAFETY_LEGAL_FRAMEWORK.md) — règles sécurité
- [`MARKET_POSITIONING_TOWER_DEFENSE.md`](MARKET_POSITIONING_TOWER_DEFENSE.md)
- [`DEPENDENCIES.md`](DEPENDENCIES.md) — stratégie dépendances
- [`PURCHASE_STRATEGY.md`](PURCHASE_STRATEGY.md) — stratégie achats
- [`ROADMAP.md`](ROADMAP.md) — étapes V0.1 → V1.0
- [`CLAUDE_BRIEF.md`](CLAUDE_BRIEF.md) — brief IA initial

## 12. Signatures

| Rôle | Signataire | Date |
|---|---|---|
| Maître d'ouvrage | boss974 | 2026-05-25 |
| Maître d'œuvre | Claude (Anthropic) | 2026-05-25 |
| Version | 1.0 | initial |
