# Architecture - Jeu de Zombies

Le projet est séparé en deux produits partageant la même logique de gameplay.

## 1. Version Roblox

Technologie : Roblox Studio + Luau.

### Organisation Roblox

```txt
ServerScriptService/
  GameController.server.lua
  Services/
    WaveService.lua
    ZombieService.lua
    RewardService.lua
    PlayerDataService.lua
    ShopService.lua

ReplicatedStorage/
  Shared/
    Config.lua
    Constants.lua
    Remotes.lua

StarterPlayer/
  StarterPlayerScripts/
    ClientController.client.lua

StarterGui/
  GameUI
```

### Règle serveur

Tout ce qui est important reste côté serveur :

- spawn zombies
- dégâts
- score
- coins
- sauvegarde
- achats
- récompenses

Le client ne sert qu'à afficher l'interface et envoyer des demandes contrôlées.

## 2. Version Web / Online

Technologies proposées :

- Frontend : HTML, CSS, JavaScript ou React
- Jeu 2D : Phaser.js possible plus tard
- Backend : Node.js
- Multijoueur : WebSocket / Socket.IO
- Base de données : PostgreSQL ou SQLite au départ

### Organisation web

```txt
web/
  client/
    index.html
    src/
      main.js
      game/
        GameScene.js
        Player.js
        Zombie.js
        WaveManager.js
      ui/
        hud.js
        menu.js

  server/
    index.js
    services/
      MatchService.js
      PlayerService.js
      WaveService.js
      ScoreService.js

  shared/
    config.js
    constants.js
```

## 3. Logique commune

Les deux versions doivent partager les mêmes concepts :

- vague
- zombie
- joueur
- score
- coins
- boss
- progression

## 4. Sécurité

Pour Roblox comme pour le web :

- ne jamais faire confiance au client
- valider les actions côté serveur
- limiter les spawns
- éviter les boucles infinies
- protéger les achats
- sauvegarder progressivement

## 5. Objectif technique

Avoir une base simple, lisible, évolutive et compréhensible par un développeur humain ou une IA.