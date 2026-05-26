# Mode Adulte (+18) — Choix par joueur

## Nouveauté V1.x : mode adulte INDIVIDUEL

Depuis la version courante, le mode adulte n'est plus un flag global mais
**un choix par joueur**, sécurisé par une **validation d'âge serveur**.

### Comment ça marche

1. À la première connexion, le joueur voit l'**écran SettingsUI**
2. Il saisit son **pseudo**, sa **date de naissance**, et choisit son mode
3. Le serveur **calcule l'âge** et applique :
   - **Âge < 13** : refusé, message d'erreur
   - **13 ≤ âge < 18** : mode enfant **forcé** (checkbox adulte verrouillée)
   - **Âge ≥ 18** : le joueur peut cocher "mode adulte" s'il le souhaite
4. Le choix est **sauvegardé dans DataStore** par UserId (persistant)
5. Les dialogues du jeu sont **filtrés par joueur** : un joueur adulte voit
   "Crève !", un joueur enfant voit "Allé marche done !" — sur la même partie

## Avertissement

Ce mode est **désactivé par défaut**.

Le projet de base est cadré **public jeune cartoon non-gore** (cf.
`SAFETY_LEGAL_FRAMEWORK.md` et `GAME_KNOWLEDGE.md §12`). Cela permet :

- Publication facile sur Roblox (catégorie 9+ ou 13+)
- Audience large
- Pas de modération supplémentaire

Le **mode adulte est une option locale** pour un public 18+ qui veut une
expérience plus mordante. Il **ne peut pas être activé pour une publication
publique sur Roblox sans passer l'âge-gating officiel 17+** (Roblox Maturity
Settings) et risque de bannissement si le contenu enfreint les Community
Standards.

> Cas d'usage prévu : jouer en local entre adultes, ou publier dans une
> expérience clairement réservée 17+ avec consentement explicite.

## Ce que change le mode adulte

| Aspect | Mode standard | Mode adulte |
|---|---|---|
| Dialogues | Créole familial (Bondieu, marmaille, moukate) | Créole familier vulgaire autorisé |
| Particules zombies | Pas de sang | Particules rouges au hit |
| Sons zombies | `uuhhh.mp3` doux | Pitch + bas, plus grave |
| Boss | Silhouette | Silhouette + cris intensifiés |
| Cris joueur | "Aïe", "Bondieu" | Réplique adulte |
| Caissons de loot | Bois sage | Identique |

**Ce qui ne change PAS** (limites fixes même en +18) :

- Pas de démembrement / gore réaliste
- Pas de chat custom non filtré (toujours TextChat Roblox)
- Pas de contenu sexuel
- Pas de discrimination
- Pas d'incitation au mal réel
- Pas de noms personnalisés libres

## Activer le mode

Dans `roblox/ReplicatedStorage/Shared/Config.lua` :

```lua
Config.AdultMode = true   -- défaut: false
```

Et dans `web/shared/config.js` :

```js
CONFIG.adultMode = true;  // défaut: false
```

Recharge le jeu : le runtime lit ce flag et bascule les textes.

## Lignes adultes (Story.AdultLines)

Ajoutées dans `roblox/ReplicatedStorage/Shared/Story.lua`. Catégories :

- `playerHitAdult` : prises de coups (créole vulgaire — "merde", "aïe ta race")
- `playerShootAtAdult` : tirs (insultes au zombie)
- `bossWarningAdult` : annonce boss plus intense
- `lowHpAdult` : appels au secours plus crus

Le code utilise `Config.AdultMode and "playerHitAdult" or "playerHit"` pour
choisir la catégorie. Le pipeline `Story.PickLine` reste inchangé.

## Pour publier sur Roblox en mode adulte légal

1. Activer le **système de Maturité 17+** dans Studio (Settings → Maturity)
2. Configurer **Restricted Content** dans Game Settings
3. S'assurer que le contenu reste dans les bornes des Community Standards
   même 17+ (pas de gore explicite, pas de contenu sexuel)
4. Ajouter un splash screen d'avertissement à l'intro
5. Restreindre le matchmaking aux comptes vérifiés 17+

**Ce projet ne fournit PAS l'âge-gating automatique** : c'est au mainteneur
de configurer la maturité officielle Roblox avant publication publique.

## Désactiver complètement

Pour retirer tout code "adulte" du repo, supprimer :

- `Story.AdultLines` (table dans Story.lua)
- `Story.PickLineAdult` (fonction)
- Le flag `Config.AdultMode`
- `Pickups.SpawnBloodParticles` (effet sang stylisé)
- Ce fichier (`ADULT_MODE.md`)

Le jeu retombe en mode standard sans cassure.
