# Strategie multi-supports

> Stratégie de portage Roblox → Web → Mobile natif. Voir aussi
> [`MULTIPLAYER.md`](MULTIPLAYER.md) (coop Roblox actif),
> [`PUBLISH.md`](PUBLISH.md) (procédure publication Roblox),
> [`MOBILE`](roblox/StarterPlayer/StarterPlayerScripts/MobileControls.client.lua)
> (contrôles tactiles déjà implémentés).

## Priorite

1. **Roblox** : meilleur support maintenant. Rapide a tester, multijoueur natif,
   publication simple, public adapte.
2. **Web** : prototype lisible pour equilibrage, demo partageable, terrain
   d'experimentation sans Roblox Studio.
3. **Mobile natif Android/iPhone** : apres validation du gameplay. Ne pas
   commencer trop tot.

## Play Store et iPhone

Roblox permet deja de jouer sur mobile via l'application Roblox, donc la premiere
publication mobile peut etre indirecte : publier le jeu Roblox et verifier qu'il
est bon sur telephone.

Pour gagner de l'argent sur mobile natif, il faudra respecter les achats integres
Apple/Google : les pieces, boosts, abonnements et contenus numeriques passent
par les systemes officiels de chaque store.

Pour une vraie app Play Store / iPhone ensuite, deux options :

- **Godot 4** : recommande pour ce projet. Open source, export Android/iOS,
  excellent pour 2D/3D stylisee, code GDScript simple.
- **Unity** : plus lourd, mais tres solide si le jeu devient commercial avec
  beaucoup d'assets, pubs, analytics et achats integres.

Recommendation actuelle : **Roblox -> Web -> Godot mobile**.

## Monétisation par support

- **Roblox** : developer products, passes, abonnements, pubs immersives et pubs
  récompensées volontaires.
- **Web** : demo gratuite, collecte de feedback, éventuellement sponsor local ou
  page vitrine, mais pas prioritaire pour le revenu.
- **Godot mobile** : IAP Apple/Google, rewarded ads, battle pass cosmetique,
  analytics propre.

## Architecture portable

Garder les elements suivants en fichiers simples et synchronisables :

- configs zombies, vagues, armes, defenses;
- liste des missions et lieux touristiques;
- dialogues et blagues;
- economie : coins, couts, recompenses;
- regles de progression.

Chaque support implemente son rendu et son reseau, mais respecte ces donnees.

## Attention Apple / Google

Pour publier une app native :

- compte Google Play Developer requis;
- compte Apple Developer requis pour iPhone;
- politique enfants/famille a respecter si cible jeune;
- pas de gore;
- achats integres uniquement quand le jeu est deja fun sans payer;
- textes, icones, screenshots et politique de confidentialite obligatoires.
