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
    {
      id: "stdenis", city: "Saint-Denis", title: "Acte I — La Préfecture",
      waves: 3, reward: 50, reward_item: "Photo du Barachois",
      history: "Chef-lieu depuis 1738. Le Barachois était l'abri à pirogues des premiers colons.",
      activities: ["Photo coucher de soleil Barachois", "Jardin de l'État", "Marché de Saint-Denis"],
      objectives: [
        { id: "visit_mairie",    text: "Réveille la Préfecture (Mairie)" },
        { id: "photo_barachois", text: "Photo du Barachois" },
        { id: "wave_1",          text: "Survis à la Vague 1" },
        { id: "wave_2",          text: "Survis à la Vague 2" },
        { id: "wave_3",          text: "Survis à la Vague 3" },
        { id: "return",          text: "Retour à la Cathédrale" }
      ]
    },
    {
      id: "stpaul", city: "Saint-Paul", title: "Acte II — La Baie de l'Ouest",
      waves: 5, reward: 80, reward_item: "Pièce d'or de La Buse",
      history: "1ère capitale (jusqu'en 1738). Site du débarquement français 1665. Tombe de La Buse, pirate exécuté 1730.",
      activities: ["Tombe de La Buse", "Marché Forain", "Étang St-Paul", "Baignade lagon noir"],
      objectives: [
        { id: "grotte",       text: "Découvre la Grotte des Premiers Français" },
        { id: "photo_marche", text: "Photo du Marché Forain" },
        { id: "wave_5",       text: "Survis aux 5 vagues" },
        { id: "treasure",     text: "Cherche le trésor de La Buse (cimetière)" },
        { id: "return",       text: "Libère la Mairie" }
      ]
    },
    {
      id: "stpierre", city: "Saint-Pierre", title: "Acte III — La Capitale du Sud",
      waves: 7, reward: 120, reward_item: "Vinyle Maxime Laope (séga)",
      history: "2e ville la plus peuplée. Port commercial. Marché du samedi mythique (créoles, indiens, chinois).",
      activities: ["Photo bassin sunset", "Soirée séga", "Marché du samedi", "Baignade lagon"],
      objectives: [
        { id: "inspect_port", text: "Inspection du port (bassin)" },
        { id: "photo_marche", text: "Photo du marché créole" },
        { id: "wave_7",       text: "Survis aux 7 vagues" },
        { id: "visit_terre",  text: "Visite Terre Sainte" },
        { id: "return",       text: "Retour à l'église" }
      ]
    },
    {
      id: "stbenoit", city: "Saint-Benoît", title: "Acte IV — L'Est sous la Pluie",
      waves: 9, reward: 180, reward_item: "Gousse de vanille Bourbon",
      history: "Capitale de l'Est. Côte au vent, climat très humide. Vanille Bourbon, forte communauté tamoule.",
      activities: ["Cascade Niagara", "Vanilleraie Roulof", "Anse des Cascades", "Promenade sous la pluie"],
      objectives: [
        { id: "reach_niagara", text: "Atteins la Cascade Niagara" },
        { id: "photo_niagara", text: "Photo de la cascade" },
        { id: "wave_9",        text: "Survis aux 9 vagues" },
        { id: "vanille",       text: "Visite la Vanilleraie (3 gousses)" },
        { id: "return",        text: "Retour Mairie sous la pluie" }
      ]
    },
    {
      id: "cilaos", city: "Cilaos", title: "Acte V — Le Cirque Englouti",
      waves: 10, reward: 250, miniBoss: true, reward_item: "Bouteille Cilaos Vins",
      history: "Cirque (caldeira). Nom tamoul Tsilaosa = lieu qu'on ne quitte pas. Route aux 400 virages. Seul terroir viticole d'outremer FR.",
      activities: ["Roche Merveilleuse 360°", "Eaux thermales", "Vin de Cilaos", "Broderie artisanale"],
      objectives: [
        { id: "reach_roche", text: "Atteins la Roche Merveilleuse" },
        { id: "photo_pano",  text: "Photo panoramique" },
        { id: "wave_10",     text: "Survis aux 10 vagues" },
        { id: "cave",        text: "Visite Cilaos Vins (1 bouteille)" },
        { id: "miniboss",    text: "MINI-BOSS de la Roche Merveilleuse" },
        { id: "return",      text: "Retour à l'église" }
      ]
    },
    {
      id: "plaine", city: "Plaine-des-Cafres", title: "Acte VI — Sur la Route du Volcan",
      waves: 12, reward: 350, reward_item: "Cendre de la Fournaise",
      history: "Plateau 1500m. Cafres = Africains arrivés à l'île. Élevage bovin. Climat froid.",
      activities: ["Cité du Volcan", "Photo vache normande", "27e km", "Plaine des Sables (martien)"],
      objectives: [
        { id: "cite_vol",     text: "Visite la Cité du Volcan" },
        { id: "photo_27km",   text: "Photo du 27e km" },
        { id: "wave_12",      text: "Survis aux 12 vagues" },
        { id: "photo_sables", text: "Photo Plaine des Sables" },
        { id: "bellecombe",   text: "Atteins le Pas de Bellecombe" }
      ]
    },
    {
      id: "fournaise", city: "Piton-de-la-Fournaise", title: "Acte VII — Le Cœur du Volcan",
      waves: 15, reward: 1000, boss: true, reward_item: "Photo finale de l'aube réunionnaise",
      history: "Volcan actif (2632m). 1 éruption/an depuis 60s. Coulée 2007 jusqu'à la mer. UNESCO.",
      activities: ["Photo cratère Dolomieu", "Marche Plaine des Sables", "Coulée 2007 + océan", "Notre-Dame des Laves (1977)"],
      objectives: [
        { id: "bellecombe",   text: "Pas de Bellecombe (entrée)" },
        { id: "sables",       text: "Traverse la Plaine des Sables" },
        { id: "wave_15",      text: "Survis aux 15 vagues" },
        { id: "nd_laves",     text: "Visite Notre-Dame des Laves" },
        { id: "boss_final",   text: "BOSS FINAL : Le Roi-Cendre" },
        { id: "photo_dolomieu", text: "Photo de la victoire au cratère" }
      ]
    }
  ],

  // Mode adulte = ton "familier créole" : plus piquant que le mode enfant,
  // mais SANS gros mots vulgaires cassants (pas de "putain", "merde", etc.).
  adultLines: {
    playerHit: [
      "Aïe la moukate !",
      "Bondieu, ça fait mal !",
      "Tcho dehors, sale bête !",
      "Mi sava casser vot tête !",
      "Eh moukatère, recule donc !",
      "Allé marche, lâche-moi !",
      "Bondieu, ça suffit là !",
      "Hé là, doucement bonpèr !"
    ],
    playerShoot: [
      "Atak don !",
      "Allé tcho dehors !",
      "Mi sava casser vot tête !",
      "Sale moukatère !",
      "Bouge de là, marmaille !",
      "Allé marche, sa zafer !",
      "Bondieu, prends ça !",
      "Tcho dehors gros bouchon !",
      "Adieu sale bête !",
      "Hop, à la porte !"
    ],
    bossWarning: [
      "Bondieu, c'est quoi ce truc ?!",
      "Eh, ce gros bouchon va m'avoir.",
      "Sa zafer, ça sent pas bon là...",
      "Bondieu, garde-moi !",
      "Aïe Bondieu, mi té pa prêt pour ça !"
    ],
    lowHp: [
      "Aïe, mi sava tomber...",
      "Bondieu, soigne-moi vite !",
      "Pitié, garde-moi debout !",
      "Mi-èm-a-ou, ne me lâche pas !",
      "Bondieu, c'est moukate quoi..."
    ]
  },

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
  // Lazy import pour éviter une dépendance cyclique avec config.js : on lit
  // STORY.adultModeReader (injecté plus bas) ou window pour récupérer le flag.
  let isAdult = false;
  try {
    // Préférence : valeur stockée dans STORY.adultModeOverride si on l'a poussée
    if (typeof STORY.adultModeOverride === "boolean") isAdult = STORY.adultModeOverride;
  } catch (_) {}

  if (isAdult && STORY.adultLines && STORY.adultLines[category]) {
    const list = STORY.adultLines[category];
    if (list && list.length) return list[Math.floor(Math.random() * list.length)];
  }
  const list = STORY.lines[category];
  if (!list || !list.length) return "";
  return list[Math.floor(Math.random() * list.length)];
}

// Permet à main.js de pousser le flag CONFIG.adultMode dans STORY sans
// dépendance cyclique entre les modules shared/.
export function setAdultMode(active) {
  STORY.adultModeOverride = !!active;
}
