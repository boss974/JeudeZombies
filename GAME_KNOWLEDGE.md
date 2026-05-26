# GAME_KNOWLEDGE — Référence complète

> Document **canonique** du projet. Tout agent IA, contributeur ou outil doit lire
> ce fichier avant de modifier le code. Il fusionne, dans un seul endroit, ce qui
> est dispersé dans les autres .md (vision, design, technique, lore, sécurité).
>
> En cas de conflit avec un autre document, **ce fichier prévaut**. Les autres
> docs restent l'historique du raisonnement.

---

## 1. Vision en une phrase

Un **tower defense coopératif cartoon** sur l'île de **La Réunion**, où le joueur
défend les 24 communes contre des vagues de zombies réveillés par l'éruption du
Piton de la Fournaise. Public jeune, non-gore, accessible et émotionnellement
"chaleureux" sous l'apocalypse.

## 2. Pilier émotionnel

> "Chaque ville libérée illumine l'île un peu plus."

L'apocalypse n'est pas un gouffre. C'est une nuit dont on rallume les lampions
ville après ville. Le ton garde une note d'espoir, jamais de désespoir.

## 3. Identité audio-visuelle

### Palette officielle Réunion (V1.0)

Inspirée du drapeau non-officiel mais reconnu de La Réunion (volcan rayonnant)
et de l'écosystème tropical local.

| Rôle | Nom | Hex | RGB | Usage |
|---|---|---|---|---|
| Volcan | Orange Fournaise | `#ff6b35` | 255,107,53 | Titres, accents, lave, glow |
| Drapeau (rouge) | Rouge Flamboyant | `#e94e1b` | 233,78,27 | Boutons primaires, alertes |
| Drapeau (jaune) | Jaune Cannelle | `#f4b942` | 244,185,66 | Mission, panneaux, soleil |
| Drapeau (bleu) | Bleu Lagon | `#0099b8` | 0,153,184 | Eau, océan, surlignage |
| Tropical | Vert Émeraude | `#1c8b3e` | 28,139,62 | Forêt, vague nettoyée |
| Volcanique | Sable Noir | `#2d2d2d` | 45,45,45 | Backgrounds, ombres |
| Pluie | Bleu Pluie | `#5d8fa8` | 93,143,168 | États froids, info |
| Hibiscus | Rose Hibiscus | `#e91e63` | 233,30,99 | Cosmétique, fleurs |
| Or chaud | Or Lampions | `#ffe6a0` | 255,230,160 | Lumière ville libérée |
| Néon rouge | Néon Alerte | `#ff3030` | 255,48,48 | Ville zombie, danger |

### Atmosphères

| Aspect | Choix |
|---|---|
| Atmosphère ciel | Aube apocalyptique, ClockTime 5.5, fog 200-800 |
| Particules dominantes | Cendre orange, poussière volcanique, brume des cirques |
| Typo titres | GothamBold (Roblox) / "Segoe UI", system-ui (web) |
| Typo corps | Gotham (Roblox) / "Segoe UI" (web) |
| Forme zombies | Cartoon stylisé : cubes + sphères, jamais réaliste |

### Symboles iconiques Réunion

À placer dans le jeu pour ancrer l'identité visuelle :

- **Hibiscus** (fleur emblématique tropicale) — coloration ville libérée
- **Flamboyant** (arbre à fleurs rouges) — décor île
- **Palmier / cocotier** — pourtour côtier
- **Volcan en éruption** — Piton de la Fournaise, déjà présent
- **Vague océanique turquoise** — couleur eau
- **Sable noir** — plages volcaniques sud
- **Lampions créoles** — chaleur festive, sécurité

**Interdits visuels** : sang, démembrement, expressions de douleur, cris
réalistes excessifs, horreur psychologique.

## 4. Univers et lore

### Île

L'île de La Réunion (océan Indien, France) :

- Surface réelle : ~2512 km², ~63 km E-W × ~50 km N-S
- Échelle Roblox : 1 stud ≈ 80 m → île jouable 800 × 640 studs
- Centre du jeu : Cilaos (Y=0,0 logique, mais 0,0 monde Roblox)
- Pitons :
  - **Piton des Neiges** (centre, 3070 m) — éteint, sphère grise
  - **Piton de la Fournaise** (est, 2632 m) — actif, sphère rouge + cratère néon

### Cirques (creux entre montagnes)

- **Mafate** — inaccessible en voiture, nord-ouest
- **Salazie** — vert humide, nord, Voile de la Mariée
- **Cilaos** — sud, accessible par la Route aux 400 Virages

Tous les trois ont des **cascades** qui jouent un rôle ambiance + son.

### Plaines (axe central N-S)

- **Plaine des Palmistes** — forêt de tamarins
- **Plaine des Cafres** — porte du volcan

### Communes (24 villes officielles de La Réunion)

Coordonnées géographiques approximatives converties en (x, z) studs.
**Convention** : x positif = Est, z positif = Sud (Roblox standard).

| # | Ville | x | z | Zone | Couleur |
|---|---|---|---|---|---|
| 1 | Saint-Denis | 20 | -260 | Nord | Bright yellow |
| 2 | Sainte-Marie | 70 | -250 | Nord | Bright yellow |
| 3 | Sainte-Suzanne | 130 | -230 | Nord | Bright yellow |
| 4 | Saint-André | 190 | -180 | Est | Bright orange |
| 5 | Bras-Panon | 230 | -130 | Est | Bright orange |
| 6 | Saint-Benoît | 280 | -80 | Est | Bright orange |
| 7 | Sainte-Rose | 300 | 40 | Est | Bright orange |
| 8 | Saint-Philippe | 230 | 170 | Sud-Est | Bright red |
| 9 | Saint-Joseph | 130 | 230 | Sud | Bright red |
| 10 | Petite-Île | 70 | 240 | Sud | Bright red |
| 11 | Saint-Pierre | 0 | 240 | Sud | Bright red |
| 12 | Le Tampon | -10 | 170 | Sud | Bright red |
| 13 | Entre-Deux | -70 | 130 | Sud | Bright red |
| 14 | Saint-Louis | -90 | 210 | Sud | Bright red |
| 15 | L'Étang-Salé | -160 | 170 | Sud-Ouest | Lavender |
| 16 | Les Avirons | -210 | 130 | Sud-Ouest | Lavender |
| 17 | Saint-Leu | -270 | 60 | Ouest | Pastel blue |
| 18 | Trois-Bassins | -260 | 0 | Ouest | Pastel blue |
| 19 | Saint-Paul | -260 | -90 | Ouest | Pastel blue |
| 20 | La Possession | -180 | -190 | Nord-Ouest | Pastel blue |
| 21 | Le Port | -150 | -220 | Nord-Ouest | Pastel blue |
| 22 | Cilaos | -50 | -10 | Cirque (altitude) | White |
| 23 | Salazie | 0 | -90 | Cirque (altitude) | White |
| 24 | Mafate | -120 | -70 | Cirque (altitude) | White |
| - | Plaine-des-Cafres | 40 | 120 | Plaine | Cool yellow |
| - | Plaine-des-Palmistes | 140 | 0 | Plaine | Cool yellow |
| - | Piton-de-la-Fournaise | 180 | -20 | Volcan (Y=55) | (volcan) |

> Les villes 22-24 sont les **3 cirques** à altitude Y=38 (≈30m au-dessus
> du baseplate). Le Piton de la Fournaise est à Y=55.

## 5. Scénario — 7 actes

| Acte | Mission ID | Ville | Vagues | Récompense | Note |
|---|---|---|---|---|---|
| I | `stdenis` | Saint-Denis | 3 | +50 | Tutoriel |
| II | `stpaul` | Saint-Paul | 5 | +80 | |
| III | `stpierre` | Saint-Pierre | 7 | +120 | |
| IV | `stbenoit` | Saint-Benoît | 9 | +180 | |
| V | `cilaos` | Cilaos | 10 | +250 | Mini-boss |
| VI | `plaine` | Plaine-des-Cafres | 12 | +350 | |
| VII | `fournaise` | Piton-de-la-Fournaise | 15 | +1000 | Boss final : Roi-Cendre |

### Antagoniste final

**Le Roi-Cendre** — silhouette colossale au cratère Dolomieu. Il ne parle pas, il
regarde. Vaincu, la cendre se dissipe et l'aube revient (transition vers jour).

## 6. Mécaniques de gameplay

### Boucle principale

1. Joueur arrive sur le menu / lobby
2. Choisit (ou prend automatiquement) sa mission actuelle
3. Spawn dans la ville de la mission
4. Vagues de zombies de plus en plus difficiles
5. Joueur tire (web) / défend (Roblox TD futur)
6. À la fin de la mission : écran de victoire + récompense + ville suivante

### Types d'ennemis

| Type | Vie | Vitesse | Dégâts | Score | Coins | Couleur | Comportement |
|---|---|---|---|---|---|---|---|
| Normal | 50 | 70 / 8 | 10 | 10 | 1 | Vert moyen | Marche vers joueur |
| Fast | 30 | 130 / 14 | 8 | 15 | 2 | Vert clair | Course rapide |
| Heavy | 140 | 45 / 5 | 20 | 25 | 3 | Vert foncé | Lent, encaisse |
| MiniBoss | 350 | 60 / 7 | 35 | 80 | 12 | Rouge | Spawn tous les 5 |
| Boss | 900 | 55 / 6 | 50 | 250 | 40 | Rouge vif | Spawn tous les 10 |

> Première valeur = web (pixels/s), seconde = Roblox (studs/s). Source de vérité :
> `web/shared/config.js` (CONFIG.zombie) et `roblox/.../Config.lua` (Config.Zombie).

### Vagues

- Vague 1 : 6 zombies normaux uniquement
- Vague 2+ : possibilité de fast (50% à partir de la vague 2)
- Vague 4+ : possibilité de heavy (20%)
- Vague 5, 10, 15, 20… : mini-boss (en plus)
- Vague 10, 20, 30… : boss (à la place du mini-boss)
- Cap simultané : 25 (Roblox) / 40 (web)

### Économie

- Coins en match : convertibles en améliorations boutique (futur)
- Coins permanents : récompense de fin de mission (sauvegardé)
- Score : `score = somme(zombies tués) + 25 par vague nettoyée`

## 7. Architecture technique

### Arborescence repo

```
JeudeZombies/
├── default.project.json          Mapping Rojo → DataModel Roblox
├── roblox/                       Source Lua (synchronisée par Rojo)
│   ├── ReplicatedStorage/Shared/
│   │   ├── Config.lua            Constantes équilibrage
│   │   ├── Constants.lua         Identifiants partagés
│   │   ├── Remotes.lua           Bootstrap RemoteEvents
│   │   └── Story.lua             Données narratives
│   ├── ServerScriptService/
│   │   ├── GameController.server.lua  Entrée serveur
│   │   ├── ReunionMap.server.lua      Construction île
│   │   ├── TerrainBuilder.server.lua  Relief Roblox Terrain (à venir)
│   │   ├── Waterfalls.server.lua      Cascades cirques (à venir)
│   │   ├── SoundManager.server.lua    Audio (à venir)
│   │   └── Services/
│   │       ├── WaveService.lua
│   │       ├── ZombieService.lua
│   │       ├── RewardService.lua
│   │       ├── PlayerDataService.lua
│   │       ├── ShopService.lua
│   │       └── StoryService.lua
│   └── StarterPlayer/StarterPlayerScripts/
│       ├── ClientController.client.lua
│       └── StoryUI.client.lua
└── web/                          Prototype web HTML/Canvas/JS
    ├── client/
    │   ├── index.html
    │   └── src/
    │       ├── main.js
    │       ├── game/             GameScene, Player, Zombie, WaveManager, input
    │       └── ui/               style.css
    └── shared/                   config.js, constants.js, story.js
```

### Conventions de code

- **Lua** : noms de modules en `PascalCase.lua`, fichiers serveur en
  `*.server.lua`, fichiers client en `*.client.lua`. Indentation tab.
- **JS** : modules ES, indentation 2 espaces, classes en PascalCase, fonctions
  en camelCase, constantes en SCREAMING_SNAKE.
- **Commits** : Conventional Commits français, sujets sous 70 chars.
  Type `feat:` `fix:` `chore:` `docs:` `refactor:` `style:`.
- **Commentaires** : explicatifs ("pourquoi"), pas redondants ("ce qui"). Français.

### Règles serveur (sécurité)

- **Tout** ce qui touche dégâts/score/coins/spawn/sauvegarde est calculé serveur.
- Le client n'envoie que des **intentions** (input), jamais des résultats.
- Aucun chat custom : on utilise uniquement le TextChatService Roblox filtré.
- Aucun texte libre joueur (panneaux, noms d'équipes, etc).
- Aucune donnée personnelle collectée (UserId Roblox seulement).

## 8. Identifiants techniques

### RemoteEvents (Constants.RemoteName)

| Nom | Direction | Payload |
|---|---|---|
| `WaveUpdate` | server→client | `(wave:int, status:string)` OU `(text:string, kind:string)` (dialogues) |
| `ScoreUpdate` | server→client | `(score, coins, best)` |
| `PlayerData` | server↔client | snapshot complet `data` |
| `BuyUpgrade` | client→server | `(upgradeName:string)` |
| `StartGame` | client→server | (futur) |
| `GameOver` | server→client | `payload` |

### Storage keys (localStorage web)

| Clé | Type | Description |
|---|---|---|
| `zombies.bestScore` | int | Meilleur score |
| `zombies.totalCoins` | int | Coins cumulés toutes parties |
| `zombies.storyMission` | int | Index mission en cours (0..6) |
| `zombies.storyIntroSeen` | "1" | Flag intro vue |

### Attributs Roblox (sur les modèles)

| Attribut | Type | Sur quoi | Usage |
|---|---|---|---|
| `CityName` | string | Model des villes | Identifier la ville |
| `ZombieType` | string | Rig zombie | "Normal"/"Fast"/etc |
| `Damage` | number | Rig zombie | Dégâts au contact |
| `LastDamageBy` | string | Rig zombie | Username du dernier tireur |
| `LastHitTime` | number | Rig zombie | Anti-spam dégâts contact |

## 9. Assets audio (rbxasset:// built-ins Roblox)

Ces assets sont **garantis** existants sur tous les clients Roblox sans dépendre
d'un upload utilisateur. À utiliser en priorité pour le prototype.

| Asset | Usage suggéré |
|---|---|
| `rbxasset://sounds/impact_water.mp3` | Cascade (loop, faible volume) |
| `rbxasset://sounds/electronicpingshort.wav` | UI click, notification |
| `rbxasset://sounds/uuhhh.mp3` | Zombie pleurnichant (faible volume) |
| `rbxasset://sounds/short_falling_into_water.mp3` | Zombie qui tombe à la mer |
| `rbxasset://sounds/clickfast.wav` | Tir / impact balle |
| `rbxasset://sounds/action_jump.mp3` | Skip dialogue |
| `rbxasset://sounds/button.wav` | Validation menu |
| `rbxasset://sounds/snap.mp3` | Spawn zombie (transient) |

> Pour la musique d'ambiance, on laisse un slot `MusicAssetId` dans Config.lua
> à remplir avec un asset Roblox vérifié.

## 10. Terrain et géographie

### Pourquoi Roblox Terrain (et pas que des Parts)

Roblox propose un service **Terrain** natif (`game.Workspace.Terrain`) qui :

- Supporte heightmap, biomes (Grass, Rock, Snow, Water…), grottes
- Se rend efficacement (LOD intégré)
- Permet l'érosion visuelle et les bords naturels
- Accepte `:FillBall`, `:FillCylinder`, `:WriteVoxels`, `:PasteRegion`

C'est **la bonne abstraction** pour faire un relief crédible de La Réunion.

### Plan d'implémentation

`TerrainBuilder.server.lua` exécuté **avant** `ReunionMap.server.lua` :

1. Effacer le terrain existant.
2. **Mer** : `Terrain:FillBlock` énorme à Y=-2, matériau Water.
3. **Île de base** : `Terrain:FillCylinder` ovale (X 800, Z 640) à Y=0..8,
   matériau Grass.
4. **Piton des Neiges** : `Terrain:FillBall` rayon 60 à (`-40, 30, -40`),
   matériau Rock + cap de neige (Snow) au sommet.
5. **Piton de la Fournaise** : `Terrain:FillBall` rayon 50 à (`180, 25, -20`),
   matériau Basalt. Cratère = `Terrain:FillCylinder` inversé (extraction).
6. **3 cirques** : extractions `Terrain:FillCylinder` avec
   `Material.Air` → forment des creux dans la montagne centrale.
7. **Routes** : conservées en Parts asphalt par-dessus le terrain.

`ReunionMap.server.lua` est mis à jour pour :

- Ne plus créer le baseplate Part énorme (le Terrain le remplace).
- Garder les portails de villes, le réseau routier, les murs invisibles.
- Repositionner les villes en Y selon la hauteur du terrain à leur xz.

### Cascades

3 cirques → 3 cascades. Chaque cascade combine :

- **Émetteur de particules eau** (sprite blanc, vitesse vers bas, vie courte)
- **Brume** (sprite gris transparent au sol, longue vie)
- **Lumière humide** (PointLight bleu pâle, faible intensité)
- **Son** (rbxasset://sounds/impact_water.mp3 loopé, MaxDistance 80)

Implémenté dans `Waterfalls.server.lua`.

## 11. Système d'histoire — détails

### Structure d'une mission (`Story.Missions[i]`)

```lua
{
  id       = "stdenis",                -- unique
  city     = "Saint-Denis",            -- match Story.CityLore
  title    = "Acte I — La Préfecture",
  brief    = "La capitale du Nord. Apprends les bases.",
  lore     = "Saint-Denis se réveille dans le brouillard...",
  waves    = 3,                        -- nb de vagues à survivre
  reward   = 50,                       -- coins permanents
  unlocked = true,                     -- (mission 1 seulement)
  miniBoss = false,                    -- optionnel
  boss     = false,                    -- optionnel
}
```

### Dialogues catégorisés (`Story.Lines[category]`)

Le runtime tire au sort une ligne quand un événement déclenche la catégorie.

Catégories actuelles :

- `waveStart` : début de vague
- `waveCleared` : vague nettoyée
- `bossWarning` : vague boss imminente
- `cityCleared` : mission accomplie

Catégories à ajouter (voir §13) :

- `playerHit` : joueur a pris un coup
- `lowHp` : joueur à <25% HP
- `firstZombieKill` : premier kill de la session
- `mafateApproach` : entrée dans Mafate (lieu spécifique)
- `volcanoRumble` : ambiance Piton (boucle aléatoire)
- `nightFall` : transition jour→nuit (visuel ClockTime)

### Format dialogue côté wire

Le Remote `WaveUpdate` est polymorphe :

- Signal vague : `r:FireAllClients(wave:int, status:string)` avec status
  ∈ {"start", "cleared"}.
- Signal dialogue narratif : `r:FireClient(player, text:string, kind:string)`
  avec kind ∈ {"dialog", "waveStart", "waveCleared", "bossWarning",
  "cityCleared", "missionStart", "playerHit", "lowHp"}.

Le client distingue par `typeof(arg1)` : "number"→vague, "string"→dialogue.

## 12. Garde-fous de design

### À NE PAS faire (interdits absolus)

1. **Pas de gore** : pas de sang, pas de blessures visibles, pas de cris.
2. **Pas de chat custom** : on n'écrit jamais de système de chat parallèle.
3. **Pas de texte libre joueur** : pas de noms personnalisés, pas de panneaux
   éditables, pas d'image upload.
4. **Pas de pay-to-win** : la monétisation reste cosmétique.
5. **Pas de violence réaliste** : les zombies sont des silhouettes, pas des
   cadavres animés.
6. **Pas de données perso** : aucune collecte hors UserId Roblox.
7. **Pas de scripts inconnus** : on n'importe pas de modules de free model
   non audités.

### À toujours faire

1. **Tout valider côté serveur** : aucune confiance dans le client.
2. **Idempotence** : un script qui construit du contenu (map, sons…) doit
   pouvoir être relancé sans dupliquer.
3. **Variables nommées** : éviter les `Vector3.new(40, 2, 0)` magiques sans
   nom. Préférer une table de positions nommées.
4. **`pcall` autour des DataStores** : tolérer les pannes Roblox.
5. **Logs préfixés** : `print("[ServiceName] message")` pour repérer la source.

## 13. Roadmap d'amélioration

### Phase 1-2 (livré)

| # | Item | Statut |
|---|---|---|
| 1 | Knowledge base GAME_KNOWLEDGE.md | ✅ |
| 2 | TerrainBuilder.server.lua (relief Roblox Terrain) | ✅ |
| 3 | Waterfalls.server.lua (3 cascades Mafate/Salazie/Cilaos) | ✅ |
| 4 | Dialogues étendus (Story.Lines + CityHooks + adultLines) | ✅ |
| 5 | Zombies stylés (ZombieFactory cartoon par type) | ✅ |
| 6 | SoundManager.server.lua + audio web procédural | ✅ |
| 7 | Map enrichie : route littoral + NRL + cases créoles + boutiks | ✅ |
| 8 | Mobile : MobileControls + haptic + auto-aim + tutoriel | ✅ |
| 9 | Settings joueur (pseudo + date naissance + mode adulte ≥18) | ✅ |

### Phase 3 missions (livré commit e52cf0b)

| # | Item | Statut |
|---|---|---|
| 10 | MISSIONS_DETAILLEES.md (histoire + POI + objectifs 7 villages) | ✅ |
| 11 | MissionService.lua (validation serveur objectifs séquentiels) | ✅ |
| 12 | PointsOfInterest.server.lua (markers néon physiques) | ✅ |
| 13 | PhotoAction.client.lua (touche E = photo flash + son) | ✅ |
| 14 | MissionHUD.client.lua (liste objectifs cochés) | ✅ |
| 15 | Achievements.lua (16 succès bronze/silver/gold/platinum) | ✅ |
| 16 | CollectionService.lua (souvenirs + photos + stats persistants) | ✅ |
| 17 | GalleryUI.client.lua (3 onglets, touche G) | ✅ |

### Phase 4 (à venir)

| # | Item | Statut |
|---|---|---|
| 18 | Boss final Roi-Cendre (modèle géant) | ⏳ |
| 19 | PNJ vivants (silhouettes habitants dans les villes) | ⏳ |
| 20 | Tests Studio multi-joueur + device mobile | ⏳ |
| 21 | Publication Roblox (place publique) | ⏳ |
| 22 | Portage Godot mobile (après validation Roblox) | ⏳ |

## 14. Commandes utiles

```bash
# Build le place file pour test sans Rojo serve
rojo build default.project.json -o JeuDeZombies.rbxl

# Lancer rojo serve pour synchro live
rojo serve default.project.json

# Lancer le web localement
npx http-server web -p 5180

# Voir l'état git + push
git status && git push origin main
```

## 15. Glossaire (français créole utile pour le ton)

### Expressions courantes (utilisables en jeu)

- **Bondieu !** — exclamation, équivalent "oh là là" / "mince"
- **La moukate** — la moquerie, l'embrouille (ironique)
- **Allé marche done !** — allez avance / dégage (ferme, pas vulgaire)
- **Atak don !** — vas-y attaque ! (encouragement)
- **Sa zafer !** — c'est l'affaire / oui carrément (approbation)
- **Kaze pa** — "casse pas", ne te fais pas de souci
- **Mi-èm-a-ou** — je t'aime
- **Mi sava casse vot tête !** — je vais te casser la tête (taquin)
- **Sa mèm i di !** — c'est exactement ça !
- **Wèèèye !** — interjection de surprise
- **Tilamb** — petit-fils, ado (terme affectueux)
- **Marmaille** — enfants, jeunes (à utiliser dans les dialogues)
- **Boucan** — bruit, foin (registre familier)

### Géographie

- **Cirque** — caldeira d'effondrement (Mafate, Salazie, Cilaos)
- **Rempart** — paroi quasi-verticale d'un cirque
- **Bassin** — point d'eau, souvent en cascade
- **Ravine** — vallée encaissée creusée par une rivière
- **Boutik** — petit commerce de quartier

### Street food

- **Samoussa** — triangle indien frit aux légumes ou viande
- **Bouchon** — ravioli vapeur chinois (origine hakka)
- **Carry frites** — frites au massalé (épices)
- **Bonbon piment** — beignet pimenté de lentilles
- **Limonade Cot / Royal Bourbon** — boissons locales

### Filtrage

**Interdit** : expressions vulgaires explicites (insultes sexuelles,
scatologiques). Le ton créole reste **familier mais respectueux** pour
préserver l'accessibilité au public jeune (cf. SAFETY_LEGAL_FRAMEWORK.md).

Le ton créole est utilisé dans les dialogues pour donner couleur locale,
pas systématique.
