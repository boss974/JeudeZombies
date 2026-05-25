// Données narratives partagées web ↔ serveur futur.
// Synchronisé avec Story.lua (Roblox). Ton créole réunionnais familier
// mais JAMAIS vulgaire (public jeune, cf. SAFETY_LEGAL_FRAMEWORK.md).

export const STORY = {
  title: "L'Éveil de la Fournaise",
  subtitle: "Sauve La Réunion vague par vague",

  intro: [
    "Tout commence à l'aube, sur l'île de La Réunion.",
    "Le Piton de la Fournaise gronde depuis trois jours.",
    "Une étrange poussière orange descend des nuages.",
    "",
    "Les habitants tombent endormis... puis se relèvent, les yeux vides.",
    "Ils marchent, lentement, depuis la mer, vers nos villes.",
    "",
    "Tu es le dernier défenseur encore debout.",
    "Choisis ta ville, place tes défenses, et tiens bon.",
    "",
    "Chaque ville libérée illumine l'île un peu plus.",
    "Sauve les 24 communes. Réveille La Réunion."
  ],

  missions: [
    { id: "stdenis",   city: "Saint-Denis",            title: "Acte I — La Préfecture",          waves: 3,  reward: 50 },
    { id: "stpaul",    city: "Saint-Paul",             title: "Acte II — La Baie de l'Ouest",    waves: 5,  reward: 80 },
    { id: "stpierre",  city: "Saint-Pierre",           title: "Acte III — La Capitale du Sud",   waves: 7,  reward: 120 },
    { id: "stbenoit",  city: "Saint-Benoît",           title: "Acte IV — L'Est sous la Pluie",   waves: 9,  reward: 180 },
    { id: "cilaos",    city: "Cilaos",                 title: "Acte V — Le Cirque Englouti",     waves: 10, reward: 250,  miniBoss: true },
    { id: "plaine",    city: "Plaine-des-Cafres",      title: "Acte VI — Sur la Route du Volcan",waves: 12, reward: 350 },
    { id: "fournaise", city: "Piton-de-la-Fournaise",  title: "Acte VII — Le Cœur du Volcan",    waves: 15, reward: 1000, boss: true }
  ],

  lines: {
    waveStart: [
      "Ils arrivent...",
      "Encerclement en cours.",
      "Tenez la ligne !",
      "Une vague approche.",
      "Aller marmaille, prépare-toi !",
      "Atak don ! Ils sont là !",
      "Bondieu, regarde-moi tout ça..."
    ],
    waveCleared: [
      "Vague repoussée !",
      "Bien joué.",
      "Reprends ton souffle.",
      "Bondieu, on respire un peu.",
      "Sa zafer ! T'as géré.",
      "Kaze pa, t'es bon."
    ],
    bossWarning: [
      "Quelque chose de plus gros approche.",
      "Le sol tremble.",
      "Boss en vue !",
      "Aïe Bondieu, qui ça encore ?",
      "Allé marche done, gros bouchon !"
    ],
    cityCleared: [
      "Ville libérée !",
      "Une lumière revient.",
      "La Réunion respire un peu plus.",
      "La moukate ! On a réussi !",
      "Sa zafer, ville sauvée !"
    ],
    // ===== Blagues quand un zombie te touche =====
    playerHit: [
      "Aïe la moukate !",
      "Bondieu, ça pique !",
      "Allé marche done, sale bête !",
      "Tilamb, recule un peu !",
      "Mi sava casse vot tête !",
      "Wèèèye, mi té pa prêt !",
      "Ces moukatères ne lâchent pas..."
    ],
    lowHp: [
      "Il faut tenir...",
      "Mi-èm-a-ou, courage !",
      "Bondieu, garde-moi !",
      "Tilamb, reste debout !"
    ],
    // ===== Blagues quand tu tires =====
    playerShoot: [
      "Atak don !",
      "Allé marche done !",
      "La moukate !",
      "Mi sava casse vot tête !",
      "Tiens, prends ça !",
      "Bouge de là, sale bouchon !",
      "Sa zafer !",
      "Boom, tilamb !",
      "Wèèèye, à la porte !"
    ]
  }
};

export function randomLine(category) {
  const list = STORY.lines[category];
  if (!list || !list.length) return "";
  return list[Math.floor(Math.random() * list.length)];
}
