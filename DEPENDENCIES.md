# Stratégie de dépendances

## Principe

Économiser les tokens, le temps et les risques techniques.

On ajoute une dépendance seulement si elle apporte un vrai gain.

## Phase 1 - Roblox

Aucune dépendance externe.

Utiliser uniquement :

- Roblox Studio
- Luau
- ServerScriptService
- ReplicatedStorage
- StarterGui
- DataStoreService plus tard
- MarketplaceService plus tard

## Phase 2 - GitHub / Code propre

Ajouter Rojo seulement quand le projet Roblox devient assez gros.

But : synchroniser Roblox Studio avec GitHub.

## Phase 3 - Version web

Dépendances minimales proposées :

- Node.js
- Express
- Socket.IO pour le multijoueur
- Phaser.js si on part sur un jeu 2D web
- SQLite au début
- PostgreSQL plus tard

## À éviter au début

- Trop de frameworks
- Trop de modèles Roblox gratuits
- Scripts inconnus
- Assets non vérifiés
- Systèmes payants trop tôt

## Règle

Prototype d'abord. Dépendances ensuite.