# Histoire — L'Éveil de la Fournaise

## Pitch

> Le Piton de la Fournaise est entré en éruption. Une étrange poussière orange
> descend des nuages. Les habitants de La Réunion s'endorment puis se relèvent,
> les yeux vides. Ils marchent depuis la mer vers les villes.
>
> Tu es le dernier défenseur encore debout. Sauve les 24 communes,
> ville par ville, et réveille La Réunion.

## Ton

Cartoon apocalypse. **Pas de gore**, pas de violence réaliste, pas d'horreur
psychologique. Compatible public jeune (cf. `SAFETY_LEGAL_FRAMEWORK.md`).

L'ambiance s'inspire d'une éruption volcanique fantastique : poussière orange,
silhouettes lentes, lumières qui se rallument quand une ville est sauvée.

## Univers

L'île de La Réunion est représentée à l'échelle Roblox (~800 studs).
Les 24 villes principales sont placées à leurs coordonnées GPS approximatives.
Les 2 pitons (Neiges et Fournaise) dominent le centre.

Chaque ville a :

- une **plateforme d'entrée** colorée (portail à 2 piliers)
- un **panneau** flottant avec son nom + une ligne de lore
- une **lumière** qui s'allume lors de sa libération

## Progression narrative (7 actes)

| # | Acte | Ville | Vagues | Récompense | Note |
|---|------|-------|--------|------------|------|
| I  | La Préfecture          | Saint-Denis            | 3  | +50   | Tutoriel |
| II | La Baie de l'Ouest     | Saint-Paul             | 5  | +80   | |
| III| La Capitale du Sud     | Saint-Pierre           | 7  | +120  | |
| IV | L'Est sous la Pluie    | Saint-Benoît           | 9  | +180  | |
| V  | Le Cirque Englouti     | Cilaos                 | 10 | +250  | Mini-boss |
| VI | Sur la Route du Volcan | Plaine-des-Cafres      | 12 | +350  | |
| VII| Le Cœur du Volcan      | Piton-de-la-Fournaise  | 15 | +1000 | Boss final |

## Antagoniste

**Le Roi-Cendre** — silhouette colossale au cratère Dolomieu. Il ne parle
pas, il regarde. Vaincu, la cendre se dissipe et l'aube revient.

## Mécanique narrative en jeu

### Web (prototype solo)

- **Intro plein écran** au premier lancement (haze orange animé)
- **HUD mission** affiche la ville en cours
- **Dialogues** s'affichent en bas d'écran :
  - vague qui démarre, vague nettoyée, boss imminent, ville libérée
- **Écran de victoire** entre missions, avec progression sauvegardée
  dans `localStorage` (clé `zombies.storyMission`)
- Lien "Réinitialiser l'histoire" dans le menu

### Roblox

- `Story.lua` (`ReplicatedStorage.Shared`) — données partagées
- `StoryService.lua` (`ServerScriptService.Services`) — état serveur
  (joueur courant, mission, événements vague/boss)
- `StoryUI.client.lua` (`StarterPlayerScripts`) — intro plein écran +
  HUD de dialogue
- `ReunionMap.server.lua` — construit l'île, lit `Story.CityLore` pour
  les panneaux de villes

## Règles de sécurité respectées

- ✅ Pas de chat custom (chat Roblox filtré uniquement)
- ✅ Pas de texte libre joueur (panneaux figés, noms en dur)
- ✅ Pas de gore, pas de cris, pas de sang
- ✅ Pas de données personnelles collectées
- ✅ Style cartoon apocalypse "cendre orange" plutôt que "horreur"

## Extension future

- Voix-off pour l'intro (audio Roblox)
- Cinématique de transition entre actes
- Lore complémentaire à débloquer (cartes, archives)
- Mode endless après l'Acte VII
- Événement temporaire "Tempête tropicale" (vague spéciale)
