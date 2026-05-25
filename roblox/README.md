# Skeleton Roblox

Squelette de scripts Luau prêt à être importé dans Roblox Studio, ou synchronisé via Rojo plus tard.

## Arborescence à reproduire dans Studio

```
ReplicatedStorage/
  Shared/                    <- Folder
    Config           (ModuleScript)
    Constants        (ModuleScript)
    Remotes          (ModuleScript)

ServerScriptService/
  GameController     (Script)            -- depuis GameController.server.lua
  Services/                  <- Folder
    WaveService      (ModuleScript)
    ZombieService    (ModuleScript)
    RewardService    (ModuleScript)
    PlayerDataService(ModuleScript)
    ShopService      (ModuleScript)

StarterPlayer/
  StarterPlayerScripts/
    ClientController (LocalScript)       -- depuis ClientController.client.lua

StarterGui/
  GameUI             (ScreenGui)         -- à créer dans Studio
    WaveLabel        (TextLabel)
    ScoreLabel       (TextLabel)
    CoinsLabel       (TextLabel)
    BestLabel        (TextLabel)
    GameOverPanel    (Frame, Visible=false)
```

## Étapes rapides

1. Ouvrir Roblox Studio sur un place vide.
2. Créer la hiérarchie ci-dessus (clic droit > Insert Object).
3. Coller le contenu de chaque `.lua` correspondant.
4. Créer `Workspace.Arena.ZombieSpawns` avec quelques Parts (anchored) marquant les points de spawn.
5. Lancer "Play" : la vague 1 démarre automatiquement quand un joueur est présent.

## Quand passer à Rojo

Quand le projet dépasse ~15 fichiers, installer Rojo et utiliser `default.project.json` pour synchroniser ce dossier directement vers Studio (cf. `DEPENDENCIES.md`).
