# Multijoueur — état et configuration

## Statut : ✅ ACTIF par défaut

Roblox est nativement multijoueur : chaque "place" publique est une expérience
en ligne où plusieurs joueurs rejoignent la même instance de serveur. Notre
jeu n'a besoin d'aucune configuration supplémentaire pour permettre le coop.

## Paramètres

Dans `roblox/ReplicatedStorage/Shared/Config.lua` :

```lua
Config.Multiplayer = {
    MaxPlayers = 6,         -- coop jusqu'à 6
    PvpEnabled = false,     -- pas de PvP (coop pur)
}
```

Pour modifier la limite réelle, il faut aussi configurer la **MaxPlayers** dans
Game Settings de Studio (File → Game Settings → Basic Info → Max Players).
Le Config.lua est utilisé par certains services internes (matchmaking custom
plus tard), pas par Roblox directement.

## Ce qui marche déjà en multi

| Feature | État |
|---|---|
| Plusieurs joueurs sur la même map | ✅ natif Roblox |
| Chacun a son personnage indépendant | ✅ |
| Chacun gère son inventaire (armes, ammo, coins) | ✅ via PlayerDataService |
| Sauvegarde DataStore par UserId | ✅ |
| Chat Roblox filtré | ✅ TextChatService |
| Vagues partagées (tous les joueurs combattent les mêmes zombies) | ✅ WaveService global |
| Récompenses individualisées | ✅ RewardService.GiveKillReward |
| Téléport portails par joueur | ✅ |
| Pickups partagés (premier arrivé = premier servi) | ✅ scan toutes les 0.2s |

## Test en multi local

Studio supporte le **Local Multiplayer Testing** :

1. Test → Local Server → choisir 2 ou plus de joueurs
2. Le moteur lance N fenêtres clients + 1 serveur
3. Tester les interactions cross-player

## Limites actuelles

- Pas de matchmaking custom (lobby/queue) — les joueurs rejoignent une instance
  Roblox standard
- Pas de "salons privés" avec code (à coder via TeleportService.ReserveServer)
- Pas de classement temps-réel inter-joueurs (DataStore non temps-réel)
- Pas de voix (à activer via VoiceChatService Roblox quand publié)

## PvP

`Config.Multiplayer.PvpEnabled = false`. Pour activer du PvP :

1. Modifier `WeaponService.shoot()` pour permettre le tir entre joueurs
2. Ajouter une catégorie de dommage cross-player
3. Ajouter une UI "Teams" via Players.Teams
4. Considérer les enjeux toxicité / abus

Non recommandé pour le MVP cartoon-coop.

## Roadmap multijoueur

| # | Item | Priorité |
|---|---|---|
| 1 | Validation natif Roblox multi en jeu | ✅ |
| 2 | Lobby pré-mission (vote ville) | ⏳ V1.1 |
| 3 | Salons privés avec code | ⏳ V1.2 |
| 4 | Classement temps-réel par mission | ⏳ V1.3 |
| 5 | Voix cross-player (VoiceChatService) | ⏳ V2.0 |
| 6 | Tournois / événements temporaires | ⏳ V2.0 |
