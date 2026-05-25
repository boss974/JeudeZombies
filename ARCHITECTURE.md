# Architecture - Jeu de Zombies

Le projet est séparé en plusieurs surfaces, mais doit garder un coeur de design
commun : missions, vagues, zombies, armes, défenses, économie et narration.

## 0. Direction cible

```txt
Design commun
  Missions touristiques
  Zombies / boss
  Armes / defenses
  Economie / upgrades
  Dialogues / blagues

Roblox
  Coop, publication rapide, serveur autoritaire

Web
  Prototype solo, equilibrage, demo partageable

Mobile natif futur
  Godot ou Unity apres validation du fun
```

## 1. Version Roblox

Technologie : Roblox Studio + Luau.

### Organisation Roblox

```txt
ServerScriptService/
  GameController.server.lua
  Services/
    WaveService.lua
    ZombieService.lua
    WeaponService.lua
    DefenseService.lua
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
- tirs et cooldowns
- placement et cout des defenses
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
      Defense.js
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
- armes
- defenses
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
