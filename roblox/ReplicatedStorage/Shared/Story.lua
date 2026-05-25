-- Story.lua
-- Données narratives partagées entre serveur et client.
-- Ton : cartoon apocalypse, non-gore, accessible aux enfants
-- (cf. SAFETY_LEGAL_FRAMEWORK.md).

local Story = {}

Story.Title = "L'Éveil de la Fournaise"
Story.Subtitle = "Sauve La Réunion vague par vague"

-- ============================================================================
-- INTRO (texte affiché au premier lancement)
-- ============================================================================
Story.Intro = {
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
	"Sauve les 24 communes. Réveille La Réunion.",
}

-- ============================================================================
-- MISSIONS (progression dans l'ordre du scénario)
-- ============================================================================
Story.Missions = {
	{
		id = "stdenis",
		city = "Saint-Denis",
		title = "Acte I — La Préfecture",
		brief = "La capitale du Nord. Apprends les bases.",
		lore  = "Saint-Denis se réveille dans le brouillard. C'est ici que tout commence.",
		waves = 3,
		reward = 50,
		unlocked = true,
	},
	{
		id = "stpaul",
		city = "Saint-Paul",
		title = "Acte II — La Baie de l'Ouest",
		brief = "Défends la plus longue plage de l'île.",
		lore  = "Le sable de Saint-Paul est devenu noir. Les vagues amènent autre chose que des coquillages.",
		waves = 5,
		reward = 80,
	},
	{
		id = "stpierre",
		city = "Saint-Pierre",
		title = "Acte III — La Capitale du Sud",
		brief = "Tiens le centre-ville. Les zombies remontent du port.",
		lore  = "Le marché du samedi est vide. Seuls résonnent les pas trainants.",
		waves = 7,
		reward = 120,
	},
	{
		id = "stbenoit",
		city = "Saint-Benoît",
		title = "Acte IV — L'Est sous la Pluie",
		brief = "La forêt de Bébour cache des nids.",
		lore  = "L'humidité du Grand-Est nourrit la nuée. Les arbres bruissent sans vent.",
		waves = 9,
		reward = 180,
	},
	{
		id = "cilaos",
		city = "Cilaos",
		title = "Acte V — Le Cirque Englouti",
		brief = "1200m d'altitude. Premier mini-boss.",
		lore  = "Les remparts protègent le cirque, mais une silhouette géante descend de la Roche Merveilleuse.",
		waves = 10,
		reward = 250,
		miniBoss = true,
	},
	{
		id = "plaine",
		city = "Plaine-des-Cafres",
		title = "Acte VI — Sur la Route du Volcan",
		brief = "L'air sent le soufre. La route monte.",
		lore  = "Les vaches ont fui. Sur la N3, seuls bougent les zombies.",
		waves = 12,
		reward = 350,
	},
	{
		id = "fournaise",
		city = "Piton-de-la-Fournaise",
		title = "Acte VII — Le Cœur du Volcan",
		brief = "Le boss final. Éteins la nuée orange.",
		lore  = "Au bord du cratère Dolomieu, le Roi-Cendre attend. Il faut le faire taire.",
		waves = 15,
		reward = 1000,
		boss = true,
	},
}

-- ============================================================================
-- LORE par ville (panneau d'info, hors-mission)
-- ============================================================================
Story.CityLore = {
	["Saint-Denis"]            = "Préfecture. Le Barachois, théâtre du premier réveil.",
	["Sainte-Marie"]           = "Aéroport Roland-Garros, désormais silencieux.",
	["Sainte-Suzanne"]         = "Cascade Niagara. L'eau coule encore, le reste non.",
	["Saint-Andre"]            = "Champs de canne. Plus de coupe cette saison.",
	["Bras-Panon"]             = "Vanille bleue de Provence. L'odeur masque la cendre.",
	["Saint-Benoit"]           = "Embouchure de la Rivière des Marsouins. Calme inquiétant.",
	["Sainte-Rose"]            = "Notre-Dame des Laves a tenu en 1977. Tiendra-t-elle encore ?",
	["Saint-Philippe"]         = "Cap Méchant. Les vagues frappent. Eux aussi.",
	["Saint-Joseph"]           = "Manapany-les-Bains. Le bassin se vide étrangement vite.",
	["Petite-Ile"]             = "Le rocher au large. Refuge possible si tu nages vite.",
	["Saint-Pierre"]           = "Front de mer, terrasses fermées, lumières clignotantes.",
	["Le Tampon"]              = "Capitale des géraniums. Les pétales tombent en cendre.",
	["Entre-Deux"]             = "Village créole. Les volets battent seuls.",
	["Saint-Louis"]            = "Pont de la Rivière. Pas de demi-tour.",
	["L'Etang-Sale"]           = "Plage de sable noir. Couleur prédictive.",
	["Les Avirons"]            = "Tévelave, dernier village avant la montagne.",
	["Saint-Leu"]              = "Spot de surf. Quelque chose surfe les vagues aussi.",
	["Trois-Bassins"]          = "Souffleur d'eau. Aujourd'hui c'est un soupir.",
	["Saint-Paul"]             = "Tombe du pirate La Buse. Il faudrait son trésor.",
	["La Possession"]          = "Route du Littoral, l'entrée Nord, à protéger en priorité.",
	["Le Port"]                = "Marine marchande figée. Les conteneurs craquent.",
	["Cilaos"]                 = "Cirque accessible par la Route aux 400 Virages.",
	["Salazie"]                = "Cirque vert. Le Voile de la Mariée pleure sans vent.",
	["Mafate"]                 = "Cirque sans route. Seuls les courageux y entrent.",
	["Plaine-des-Cafres"]      = "Bourg-Murat, porte du volcan. Tu sens déjà la chaleur.",
	["Plaine-des-Palmistes"]   = "Forêt de tamarins. Les troncs anciens ont vu pire.",
	["Piton-de-la-Fournaise"]  = "Pas Bellecombe. Au-delà, le Dolomieu et son cœur en feu.",
}

-- ============================================================================
-- DIALOGUES (messages courts, affichés en HUD pendant les vagues)
-- ============================================================================
Story.Lines = {
	waveStart    = { "Ils arrivent...", "Encerclement en cours.", "Tenez la ligne !", "Une vague approche." },
	waveCleared  = { "Vague repoussée !", "Bien joué.", "Reprends ton souffle.", "Ils reculent." },
	bossWarning  = { "Quelque chose de plus gros approche.", "Le sol tremble.", "Boss en vue !" },
	cityCleared  = { "Ville libérée !", "Une lumière revient.", "La Réunion respire un peu plus." },
}

return Story
