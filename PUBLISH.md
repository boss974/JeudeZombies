# PUBLISH — Guide de publication Roblox

> Procédure complète pour publier **L'Éveil de la Fournaise** sur Roblox.
> À lire et cocher entièrement avant le premier `Publish to Roblox`.
>
> Version : 1.0 — 26 mai 2026

---

## 1. Identité publication

| Champ | Valeur |
|---|---|
| Nom du jeu | **L'Éveil de la Fournaise** |
| Repo | https://github.com/boss974/JeudeZombies |
| Langue principale | Français |
| Pays studio | Réunion / France |
| Mode par défaut | Enfant (cartoon non-gore) |
| Mode adulte | Optionnel par joueur (>= 18 ans, voir `ADULT_MODE.md`) |

---

## 2. Description courte (slogan + accroche)

> **Sauve La Réunion vague par vague.** Tower defense coop cartoon sur l'île volcanique.

(78 caractères, à coller dans le champ "Subtitle" ou en accroche réseaux.)

---

## 3. Description longue Roblox (~150 mots)

Voici le texte à coller dans **Game Settings → Basic Info → Description** :

```
L'Éveil de la Fournaise — Un tower defense coopératif cartoon sur l'île de La Réunion.

Le Piton de la Fournaise est entré en éruption. Une étrange poussière orange a réveillé
les habitants en zombies cartoon. À toi de défendre les 24 communes, des plages de
Saint-Denis au cratère du volcan.

Traverse 7 actes scénarisés (Saint-Denis, Saint-Paul, Saint-Pierre, Saint-Benoît,
Cilaos, Plaine-des-Cafres, Piton-de-la-Fournaise) avec mini-boss et boss final, le
Roi-Cendre. Survis aux vagues de zombies Normal, Fast, Heavy, MiniBoss et Boss.

Joue en coop jusqu'à 6 amis, en français avec une touche de créole réunionnais.
Style cartoon non-gore, accessible dès 9 ans. Plonge dans une île tropicale unique :
volcan en éruption, cirques de Mafate / Salazie / Cilaos, lampions créoles,
hibiscus et palmiers.

Sauve La Réunion avec tes amis !

#Roblox #LaReunion #TowerDefense #Coop #ZombieGame
```

Mots-clés présents : *Réunion, zombies, tower defense, coop, créole, volcan,
cartoon, multi-joueur, île, vagues*.

---

## 4. Tags Roblox (max 10)

À coller dans **Game Settings → Basic Info → Genres / Subgenres / Tags** :

1. `Tower Defense`
2. `Coop`
3. `Zombies`
4. `Adventure`
5. `Strategy`
6. `Multiplayer`
7. `Cartoon`
8. `Survival`
9. `La Reunion`
10. `Volcano`

> Roblox limite à 10 tags. Mettre les plus génériques en premier (meilleur SEO).

---

## 5. Genre Roblox principal

Choisir dans **Game Settings → Basic Info → Genre** :

- **Genre principal** : `Strategy` (tower defense rentre ici)
- **Sous-genre 1** : `Survival`
- **Sous-genre 2** : `Adventure`

> Alternatives valides : `Battle` ou `Action` si la console donne ces options.
> Éviter `Shooter` seul (le jeu n'est pas un FPS pur) et `Town & City` (pas un
> rôle play ville).

---

## 6. Maturité (Maturity Settings)

| Cible | Maturité Roblox | Raison |
|---|---|---|
| **Défaut publication** | **Mild (9+)** | Mode enfant cartoon, non-gore, créole familier sans vulgarité |
| Si publication mode adulte | **Moderate (13+)** | Dialogues créoles plus piquants, mais pas de gore ni de contenu sexuel |
| Maturité 17+ | **NON recommandé** | Le jeu n'a pas de contenu 17+ ; éviter pour ne pas restreindre l'audience |

**À cocher dans Studio** :
- `File → Game Settings → Maturity & Compliance → Mild` (par défaut)
- `Violence` : `None / Mild` (silhouettes cartoon, pas de sang)
- `Crude Humor` : `None`
- `Strong Language` : `None` (créole familier sans gros mots)
- `Realistic Blood` : `None`
- `Romance` : `None`
- `Free Form User Creation` : `None` (pas de UGC, pas de chat custom)
- `Social Hangout` : `None`
- `Gambling` : `None`

> Réf. interne : voir `SAFETY_LEGAL_FRAMEWORK.md` et `ADULT_MODE.md`.

---

## 7. Étapes de publication

### Étape 1 — Préparer le `.rbxl`

```bash
# Depuis le repo
rojo build default.project.json -o JeuDeZombies.rbxl
```

> Le fichier `JeuDeZombies.rbxl` est déjà versionné à la racine du repo.

### Étape 2 — Ouvrir Roblox Studio

1. Lancer **Roblox Studio**
2. `File → Open from File` → choisir `JeuDeZombies.rbxl`
3. Vérifier que tout charge sans erreur dans la fenêtre Output

### Étape 3 — Premier publish (création de l'expérience)

1. `File → Publish to Roblox As...`
2. Choisir `Create new game`
3. Remplir :
   - **Name** : `L'Éveil de la Fournaise`
   - **Description** : (coller le texte de la section 3)
   - **Creator** : Toi (boss974) ou un Group si tu en as un
   - **Genre** : `Strategy`
4. Cliquer **Create**

### Étape 4 — Configurer Place Settings

`Home → Game Settings → Places → Start Place` :

- **Place Name** : `L'Éveil de la Fournaise`
- **Place Description** : (même description courte)
- **Max Players** : `6` (cohérent avec `Config.Multiplayer.MaxPlayers`)
- **Allow copying** : `OFF` (protège ton code)
- **Server Fill** : `Default`

### Étape 5 — Configurer Experience Settings

`Home → Game Settings → Basic Info` :

- **Name** : `L'Éveil de la Fournaise`
- **Description** : (texte section 3)
- **Genre** : `Strategy` + sous-genres
- **Tags** : (les 10 de la section 4)
- **Devices supportés** : voir étape 6
- **Playable** : `OFF` au début (publication soft)

`Game Settings → Permissions` :

- **Playability** : commencer en **Private** pour tester, passer en **Public** ensuite

`Game Settings → Avatar` :

- **Avatar Type** : `Player Choice`
- **Animation** : `Player Choice`
- **Collision** : `Inner box` (standard)

`Game Settings → Monetization` :

- Désactivé au lancement (pas de Game Pass, pas de Developer Product)
- À activer après validation rétention (cf. `MONETIZATION_STRATEGY.md`)

### Étape 6 — Devices supportés

`Game Settings → Basic Info → Devices` cocher :

- [x] **Computer** (PC/Mac)
- [x] **Phone** (iOS / Android)
- [x] **Tablet** (iPad)
- [x] **Console** (Xbox) — optionnel, à activer après tests manette

> Note : VR non recommandé pour le MVP (pas optimisé).

### Étape 7 — Uploader l'icône et la miniature

Roblox accepte **PNG / JPG** uniquement. Convertir les SVG en PNG :

```bash
# Option 1 — Inkscape (installé sur le poste)
inkscape assets/icon.svg --export-type=png --export-filename=assets/icon.png --export-width=512
inkscape assets/thumbnail.svg --export-type=png --export-filename=assets/thumbnail.png --export-width=1280

# Option 2 — ImageMagick
magick assets/icon.svg -resize 512x512 assets/icon.png
magick assets/thumbnail.svg -resize 1280x720 assets/thumbnail.png

# Option 3 — En ligne : svgomg.firebaseapp.com puis cloudconvert.com (SVG → PNG)
```

Dans Studio :

1. `Create → Experiences → [ton expérience] → Configure → Thumbnails`
2. Upload **icône** (`assets/icon.png`, 512×512)
3. Upload **miniature** (`assets/thumbnail.png`, 1280×720) — possibilité d'en mettre jusqu'à 10
4. Cocher la miniature principale (celle qui s'affichera)

### Étape 8 — Tester en local multijoueur

`Test → Local Server → 2 Players` (ou plus) :

- Vérifier que les 2 fenêtres clients se connectent
- Vérifier le spawn de chacun à Saint-Denis
- Vérifier que les zombies sont partagés (visibles par les 2 joueurs)
- Vérifier le HUD individuel (mission, vague, score, coins, vie)

### Étape 9 — Tester sur device émulation

`Test → Device → iPhone` puis `iPad` puis `Galaxy` :

- Vérifier que SettingsUI (premier écran pseudo + date de naissance) est lisible
- Vérifier que les boutons sont assez grands pour les doigts
- Vérifier que le HUD ne déborde pas en portrait/paysage

### Étape 10 — Activer Public

Une fois tous les tests passés :

1. `Game Settings → Permissions → Playability` → **Public**
2. Cliquer `Save`
3. Le jeu est en ligne. URL de l'expérience visible en haut à droite de Studio.

### Étape 11 — Partager le lien

URL au format : `https://www.roblox.com/games/<ID>/L-Eveil-de-la-Fournaise`

Coller dans :
- Discord
- Reddit `/r/Roblox` ou `/r/LaReunion`
- WhatsApp (groupe famille / amis)
- Twitter / X avec hashtags (cf. `assets/social-card.md`)

---

## 8. Checklist pré-publication

Cocher chaque ligne avant de passer en **Public** :

### Tests jeu

- [ ] Lancement local : le jeu démarre en moins de 5s
- [ ] **Tester en local Multiplayer (2 joueurs)** via `Test → Local Server`
- [ ] **Tester sur Device émulation iPhone** (`Test → Device → iPhone X`)
- [ ] **Tester sur Device émulation iPad** (`Test → Device → iPad`)
- [ ] **Vérifier que SettingsUI ne bloque pas** (commit `c94062d` : pseudo + date naissance, le serveur valide l'âge)
- [ ] **Vérifier que les zombies spawnent** (activer Debug HUD via touche `F3` ou Console : observer compteur > 0 à la vague 1)
- [ ] **Vérifier le cycle jour/nuit** (atmosphère ClockTime 5.5, fog 200-800 visible)
- [ ] **Activer/désactiver le mode adulte** selon cible audience (`Config.AdultMode = false` par défaut)
- [ ] Vérifier que les 3 cascades font du son (Mafate, Salazie, Cilaos)
- [ ] Vérifier la victoire de l'Acte I (Saint-Denis, 3 vagues) → passage Acte II
- [ ] Aucun crash en 10 minutes de jeu continu

### Tests publication

- [ ] **Lire les Roblox Community Standards** : https://en.help.roblox.com/hc/en-us/articles/203313410
- [ ] Lire les **Experience Guidelines** : https://create.roblox.com/docs/production/publishing/experience-guidelines
- [ ] Confirmer que le contenu correspond à la maturité déclarée (Mild 9+)
- [ ] Confirmer qu'aucun asset n'est issu d'une free model non auditée (cf. `GAME_KNOWLEDGE.md §12`)
- [ ] Confirmer qu'aucun chat custom n'est implémenté (seul `TextChatService` Roblox)
- [ ] Confirmer qu'aucune donnée personnelle n'est collectée (UserId Roblox seulement)
- [ ] Icône uploadée et validée par Roblox (pas de "pending review")
- [ ] Miniature uploadée et validée par Roblox

### Tests qualité

- [ ] Nom du jeu sans faute (`L'Éveil de la Fournaise` avec accent É et apostrophe)
- [ ] Description orthographiée correctement
- [ ] Tags pertinents (cf. section 4)
- [ ] Genre correctement sélectionné (Strategy)
- [ ] Devices supportés cochés (PC + Phone + Tablet minimum)

---

## 9. Métriques à suivre post-publication

| Métrique | Outil | Seuil cible J+30 |
|---|---|---|
| **DAU** (Daily Active Users) | Creator Dashboard → Analytics | > 50 joueurs/jour |
| **Rétention J1** | Analytics → Retention | > 25 % |
| **Rétention J7** | Analytics → Retention | > 10 % |
| **Durée moyenne session** | Analytics → Engagement | > 5 min |
| **Ville la plus jouée** | Logs serveur custom (à coder) | (insight produit) |
| **Taux complétion Acte I** | DataStore custom (à coder) | > 60 % |
| **Taux passage Acte II** | DataStore | > 30 % |
| **Crash rate** | Output Studio + logs | < 1 % |
| **Avis / votes Roblox** | Page expérience | > 70 % positifs |

---

## 10. Plan de promotion soft

> Pas de pub payée au lancement. On valide la boucle gameplay avant tout
> investissement marketing (cf. `CAHIER_DES_CHARGES.md §3`).

### Semaine 1 (lancement)

1. **Discord** : poster dans serveurs Réunion + Roblox francophones
   - Texte court (cf. `assets/social-card.md`)
   - Capture d'écran de la miniature
   - Lien Roblox
2. **WhatsApp** : groupe famille + groupe amis (boss974)
   - Message direct avec lien
3. **Reddit** : `/r/Reunion`, `/r/LaReunion`, `/r/roblox`
   - Post avec contexte ("Jeu Roblox solo dev sur La Réunion")
4. **Twitter / X** : tweet avec hashtags (cf. `assets/social-card.md`)

### Semaine 2-4

5. Demander **feedback aux premiers joueurs** via le serveur Discord du jeu (à créer si besoin)
6. Itérer sur les retours (équilibrage vagues, lisibilité HUD)
7. Publier 1 **devlog vidéo** sur YouTube ou TikTok (capture Studio + commentaire) — optionnel
8. Contacter 1-2 **streameurs Roblox français** petits (< 5k followers) pour test du jeu

### Mois 2

9. Activer la **monétisation cosmétique** si rétention J7 > 10 %
10. Lancer la **première mise à jour** : nouvel acte ou événement temporaire (Tempête tropicale)
11. Demander à figurer dans la rubrique **Sponsored / Featured** Roblox (paiement par clic)

---

## 11. Liens utiles

- **Roblox Community Standards** : https://en.help.roblox.com/hc/en-us/articles/203313410
- **Experience Guidelines** : https://create.roblox.com/docs/production/publishing/experience-guidelines
- **Creator Dashboard** : https://create.roblox.com/dashboard
- **Maturity & Compliance** : https://create.roblox.com/docs/production/publishing/maturity
- **Roblox Tags Best Practices** : https://create.roblox.com/docs/production/publishing/tagging

---

## 12. Suivi post-publication

| Date | Action | Auteur | Note |
|---|---|---|---|
| (à remplir) | Première publication Public | boss974 | URL : ... |
| (à remplir) | Patch 1.0.1 | boss974 | (correctifs) |

---

> **Important** : Ce document est versionné dans le repo. Toute modification de
> la procédure doit être consignée par commit (`docs: maj PUBLISH.md ...`).
