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
		history = "Chef-lieu depuis 1738. Le Barachois était l'abri à pirogues des premiers colons.",
		waves = 3,
		reward = 50,
		reward_item = "Photo du Barachois",
		unlocked = true,
		poi = {
			{ id="mairie",      name="Mairie",              pos=Vector3.new( 20, 8.5, -260), icon="🏛️" },
			{ id="barachois",   name="Le Barachois",        pos=Vector3.new( 15, 8.5, -245), icon="📸" },
			{ id="cathedrale",  name="Cathédrale",          pos=Vector3.new(  5, 8.5, -265), icon="⛪" },
			{ id="jardin_etat", name="Jardin de l'État",    pos=Vector3.new( 30, 8.5, -255), icon="🌳" },
		},
		activities = {
			"Photo coucher de soleil sur le Barachois",
			"Balade au Jardin de l'État (palmiers centenaires)",
			"Marché de Saint-Denis (boucan, vanille)",
			"Visite vieille ville créole",
		},
		objectives = {
			{ id="visit_mairie",    type="touch_poi", target="mairie",
			  text="Réveille la Préfecture (Mairie)" },
			{ id="photo_barachois", type="photo",     target="barachois",
			  text="Photo du Barachois (touche E)" },
			{ id="wave_1",          type="wave",      target=1,
			  text="Survis à la Vague 1" },
			{ id="wave_2",          type="wave",      target=2,
			  text="Survis à la Vague 2" },
			{ id="wave_3",          type="wave",      target=3,
			  text="Survis à la Vague 3" },
			{ id="return",          type="touch_poi", target="cathedrale",
			  text="Retour à la Cathédrale (portail vers St-Paul)" },
		},
	},
	{
		id = "stpaul",
		city = "Saint-Paul",
		title = "Acte II — La Baie de l'Ouest",
		brief = "L'ancienne capitale, son marché forain, et un pirate.",
		lore  = "Le sable noir devient encore plus sombre. Et La Buse i ri dans son tombeau.",
		history = "Première capitale de La Réunion (jusqu'en 1738). Site du débarquement français en 1665. Tombe d'Olivier Levasseur dit La Buse, pirate exécuté en 1730.",
		waves = 5,
		reward = 80,
		reward_item = "Pièce d'or de La Buse",
		poi = {
			{ id="mairie",       name="Mairie",                pos=Vector3.new(-260, 8.5,  -90), icon="🏛️" },
			{ id="cimetiere",    name="Cimetière marin",       pos=Vector3.new(-280, 8.5, -110), icon="🏴‍☠️" },
			{ id="marche_forain",name="Marché Forain",         pos=Vector3.new(-260, 8.5,  -85), icon="🥭" },
			{ id="grotte",       name="Grotte 1ers Français",  pos=Vector3.new(-285, 8.5, -100), icon="🪨" },
			{ id="etang",        name="Étang de Saint-Paul",   pos=Vector3.new(-265, 8.5,  -75), icon="🦜" },
		},
		activities = {
			"Photo tombe de La Buse (cimetière marin)",
			"Marché Forain (mangues, ananas Victoria, achards)",
			"Observation oiseaux à l'Étang",
			"Baignade lagon sable noir",
		},
		objectives = {
			{ id="visit_grotte",   type="touch_poi", target="grotte",
			  text="Découvre la Grotte des Premiers Français" },
			{ id="photo_marche",   type="photo",     target="marche_forain",
			  text="Photo du Marché Forain" },
			{ id="wave_5",         type="wave",      target=5,
			  text="Survis aux 5 vagues" },
			{ id="treasure",       type="touch_poi", target="cimetiere",
			  text="Cherche le trésor de La Buse (cimetière)" },
			{ id="return",         type="touch_poi", target="mairie",
			  text="Libère la Mairie" },
		},
	},
	{
		id = "stpierre",
		city = "Saint-Pierre",
		title = "Acte III — La Capitale du Sud",
		brief = "Front de mer animé, marché créole multiculturel.",
		lore  = "Le marché du samedi est vide. Seuls résonnent les pas trainants.",
		history = "2e ville la plus peuplée. Port de commerce, marché du samedi mythique mêlant créoles, indiens, chinois. Fondée en 1735.",
		waves = 7,
		reward = 120,
		reward_item = "Vinyle Maxime Laope (séga)",
		poi = {
			{ id="eglise",     name="Église Saint-Pierre",     pos=Vector3.new( 0, 8.5, 235), icon="⛪" },
			{ id="bassin",     name="Bassin / Front de mer",   pos=Vector3.new( 5, 8.5, 230), icon="⚓" },
			{ id="marche",     name="Marché couvert",          pos=Vector3.new( 0, 8.5, 240), icon="🥘" },
			{ id="plage",      name="Plage de Saint-Pierre",   pos=Vector3.new(10, 8.5, 250), icon="🏖️" },
			{ id="terre_st",   name="Terre Sainte",            pos=Vector3.new(-5, 8.5, 245), icon="🏘️" },
		},
		activities = {
			"Photo bassin au coucher du soleil",
			"Soirée séga sur le front de mer",
			"Marché du samedi : carry poulet, achards, gâteau patate",
			"Baignade à la plage de Saint-Pierre",
		},
		objectives = {
			{ id="inspect_port", type="touch_poi", target="bassin",
			  text="Inspection du port" },
			{ id="photo_marche", type="photo",     target="marche",
			  text="Photo du marché créole" },
			{ id="wave_7",       type="wave",      target=7,
			  text="Survis aux 7 vagues" },
			{ id="visit_terre",  type="touch_poi", target="terre_st",
			  text="Visite le quartier de Terre Sainte" },
			{ id="return",       type="touch_poi", target="eglise",
			  text="Retour à l'église (cloche libératrice)" },
		},
	},
	{
		id = "stbenoit",
		city = "Saint-Benoît",
		title = "Acte IV — L'Est sous la Pluie",
		brief = "Cascade, vanille, et pluie tropicale.",
		lore  = "L'humidité du Grand-Est nourrit la nuée. Les arbres bruissent sans vent.",
		history = "Capitale de l'Est. Côte au vent, climat très humide. Spécialité : vanille Bourbon. Forte immigration tamoule au 19e siècle.",
		waves = 9,
		reward = 180,
		reward_item = "Gousse de vanille Bourbon",
		poi = {
			{ id="mairie",       name="Mairie",                  pos=Vector3.new(280, 8.5, -80), icon="🏛️" },
			{ id="niagara",      name="Cascade Niagara",         pos=Vector3.new(270, 8.5, -65), icon="💧" },
			{ id="vanille",      name="Vanilleraie Roulof",      pos=Vector3.new(255, 8.5, -75), icon="🌱" },
			{ id="anse",         name="Anse des Cascades",       pos=Vector3.new(310, 8.5,  30), icon="🌊" },
			{ id="embouchure",   name="Embouchure Marsouins",    pos=Vector3.new(280, 8.5, -80), icon="🐟" },
		},
		activities = {
			"Photo Cascade Niagara dans la brume",
			"Visite Vanilleraie + dégustation",
			"Photo côte sauvage Anse des Cascades",
			"Promenade sous la pluie tropicale",
		},
		objectives = {
			{ id="reach_niagara", type="touch_poi", target="niagara",
			  text="Atteins la Cascade Niagara (sous la pluie)" },
			{ id="photo_niagara", type="photo",     target="niagara",
			  text="Photo de la cascade" },
			{ id="wave_9",        type="wave",      target=9,
			  text="Survis aux 9 vagues" },
			{ id="vanille",       type="touch_poi", target="vanille",
			  text="Visite la Vanilleraie (3 gousses)" },
			{ id="return",        type="touch_poi", target="mairie",
			  text="Retour Mairie sous la pluie" },
		},
	},
	{
		id = "cilaos",
		city = "Cilaos",
		title = "Acte V — Le Cirque Englouti",
		brief = "1200m d'altitude, eaux thermales, vin de Cilaos.",
		lore  = "Les remparts protègent le cirque, mais une silhouette géante descend de la Roche Merveilleuse.",
		history = "Cirque (caldeira d'effondrement). Nom tamoul Tsilaosa = lieu qu'on ne quitte pas. Route aux 400 virages. Seul terroir viticole d'outremer FR.",
		waves = 10,
		reward = 250,
		miniBoss = true,
		reward_item = "Bouteille Cilaos Vins",
		poi = {
			{ id="eglise_neiges", name="Notre-Dame-des-Neiges",  pos=Vector3.new(-50, 38.5,  -8), icon="⛪" },
			{ id="roche",         name="Roche Merveilleuse",     pos=Vector3.new(-50, 40.5, -25), icon="🏔️" },
			{ id="source",        name="Source Irénée",          pos=Vector3.new(-45, 38.5,  -5), icon="♨️" },
			{ id="cave_vins",     name="Cilaos Vins (cave)",     pos=Vector3.new(-50, 38.5, -10), icon="🍷" },
			{ id="cascade_br",    name="Cascade Bras Rouge",     pos=Vector3.new(-55, 45.5, -15), icon="💧" },
		},
		activities = {
			"Photo panorama Roche Merveilleuse (360°)",
			"Bain Source Irénée (thermes)",
			"Dégustation vin de Cilaos",
			"Achat broderie de Cilaos (artisanat)",
		},
		objectives = {
			{ id="reach_roche",   type="touch_poi", target="roche",
			  text="Atteins la Roche Merveilleuse" },
			{ id="photo_pano",    type="photo",     target="roche",
			  text="Photo panoramique" },
			{ id="wave_10",       type="wave",      target=10,
			  text="Survis aux 10 vagues" },
			{ id="cave",          type="touch_poi", target="cave_vins",
			  text="Visite Cilaos Vins (1 bouteille)" },
			{ id="miniboss",      type="boss",      target=1,
			  text="MINI-BOSS : la silhouette de la Roche Merveilleuse" },
			{ id="return",        type="touch_poi", target="eglise_neiges",
			  text="Retour à l'église" },
		},
	},
	{
		id = "plaine",
		city = "Plaine-des-Cafres",
		title = "Acte VI — Sur la Route du Volcan",
		brief = "1500m, vaches normandes, et un musée du volcan.",
		lore  = "Les vaches ont fui. Sur la N3, seuls bougent les zombies.",
		history = "Plateau d'altitude (1500m). Nom Cafres = Africains arrivés à l'île. Région d'élevage bovin. Climat froid.",
		waves = 12,
		reward = 350,
		reward_item = "Cendre de la Fournaise",
		poi = {
			{ id="mairie",   name="Mairie Bourg-Murat",     pos=Vector3.new( 40, 30.5, 120), icon="🏛️" },
			{ id="cite_vol", name="Cité du Volcan",         pos=Vector3.new( 50, 30.5, 125), icon="🏛️" },
			{ id="27km",     name="Le 27e km",              pos=Vector3.new( 45, 30.5, 115), icon="🛣️" },
			{ id="bellecombe", name="Pas de Bellecombe",    pos=Vector3.new(130, 35.5,  80), icon="🌋" },
			{ id="sables",   name="Plaine des Sables",      pos=Vector3.new( 90, 35.5, 100), icon="🪐" },
		},
		activities = {
			"Visite Cité du Volcan (musée immersif)",
			"Photo vache normande dans les prés",
			"Photo du 27e km (panneau iconique)",
			"Trek Plaine des Sables (paysage martien)",
		},
		objectives = {
			{ id="cite_vol",    type="touch_poi", target="cite_vol",
			  text="Visite la Cité du Volcan" },
			{ id="photo_27km",  type="photo",     target="27km",
			  text="Photo du 27e km" },
			{ id="wave_12",     type="wave",      target=12,
			  text="Survis aux 12 vagues" },
			{ id="photo_sables",type="photo",     target="sables",
			  text="Photo Plaine des Sables (martien)" },
			{ id="bellecombe",  type="touch_poi", target="bellecombe",
			  text="Atteins le Pas de Bellecombe" },
		},
	},
	{
		id = "fournaise",
		city = "Piton-de-la-Fournaise",
		title = "Acte VII — Le Cœur du Volcan",
		brief = "Boss final. Éteins la nuée orange.",
		lore  = "Au bord du cratère Dolomieu, le Roi-Cendre attend. Il faut le faire taire.",
		history = "Volcan actif (2632m). 1 éruption/an depuis les 60s. Coulée 2007 jusqu'à la mer (Sainte-Rose). Patrimoine UNESCO.",
		waves = 15,
		reward = 1000,
		boss = true,
		reward_item = "Photo finale de l'aube réunionnaise",
		poi = {
			{ id="bellecombe",  name="Pas de Bellecombe",       pos=Vector3.new(130, 35.5,  80), icon="🌋" },
			{ id="dolomieu",    name="Cratère Dolomieu",        pos=Vector3.new(180, 55.5, -20), icon="🔥" },
			{ id="sables",      name="Plaine des Sables",       pos=Vector3.new( 90, 35.5, 100), icon="🪐" },
			{ id="coulee_2007", name="Coulée 2007 (mer)",       pos=Vector3.new(300,  5.5,  45), icon="🌊" },
			{ id="nd_laves",    name="Notre-Dame des Laves",    pos=Vector3.new(300,  8.5,  40), icon="⛪" },
		},
		activities = {
			"Photo cratère Dolomieu depuis Pas de Bellecombe",
			"Marche dans la Plaine des Sables (45 min)",
			"Photo coulée 2007 (lave figée + océan)",
			"Visite Notre-Dame des Laves (contournée par la lave 1977)",
		},
		objectives = {
			{ id="bellecombe",   type="touch_poi", target="bellecombe",
			  text="Pas de Bellecombe (entrée du sanctuaire)" },
			{ id="sables",       type="touch_poi", target="sables",
			  text="Traverse la Plaine des Sables" },
			{ id="wave_15",      type="wave",      target=15,
			  text="Survis aux 15 vagues" },
			{ id="nd_laves",     type="touch_poi", target="nd_laves",
			  text="Visite Notre-Dame des Laves (refuge)" },
			{ id="boss_final",   type="boss",      target=2,
			  text="BOSS FINAL : Le Roi-Cendre" },
			{ id="photo_dolomieu",type="photo",    target="dolomieu",
			  text="Photo de la victoire au cratère apaisé" },
		},
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
-- Notes ton :
-- - Style créole réunionnais familier, JAMAIS vulgaire (public jeune).
-- - "La moukate" = la moquerie, l'embrouille
-- - "Allé marche done !" = allez avance / dégage
-- - "Bondieu !" = oh là là / mince
-- - "Mi sava casse vot tête !" = je vais te casser la tête (taquin)
-- - "Tilamb" = petit-fils, ado (terme affectueux)
-- - "Atak don !" = vas-y attaque !
-- - "Sa zafer !" = c'est l'affaire / oui carrément
-- - "Kaze pa" = casse pas (te fais pas de souci)
Story.Lines = {
	waveStart = {
		"Ils arrivent...",
		"Encerclement en cours.",
		"Tenez la ligne !",
		"Une vague approche.",
		"Aller marmaille, prépare-toi !",
		"Reste près du portail.",
		"Lentement, ils montent depuis la mer.",
		"Atak don ! Ils sont là !",
		"Bondieu, regarde-moi tout ça...",
	},
	waveCleared = {
		"Vague repoussée !",
		"Bien joué.",
		"Reprends ton souffle.",
		"Ils reculent.",
		"Bondieu, on respire un peu.",
		"Une de plus.",
		"Encore solide.",
		"Sa zafer ! T'as géré.",
		"Kaze pa, t'es bon.",
	},
	bossWarning = {
		"Quelque chose de plus gros approche.",
		"Le sol tremble.",
		"Boss en vue !",
		"L'air pèse plus lourd, soudain.",
		"Tiens bon...",
		"Aïe Bondieu, qui ça encore ?",
		"Allé marche done, gros bouchon !",
	},
	cityCleared = {
		"Ville libérée !",
		"Une lumière revient.",
		"La Réunion respire un peu plus.",
		"Les lampions se rallument.",
		"Un cœur de plus qui bat sur l'île.",
		"La moukate ! On a réussi !",
		"Sa zafer, ville sauvée !",
	},
	-- ===== Blagues créoles "quand un zombie te touche" =====
	playerHit = {
		"Aïe la moukate !",
		"Bondieu, ça pique !",
		"Allé marche done, sale bête !",
		"Tilamb, recule un peu !",
		"Eh, mi sava casse vot tête !",
		"Soigne-toi vite.",
		"Ils ne lâchent pas, ces moukatères.",
		"Wèèèye, mi té pa prêt !",
	},
	lowHp = {
		"Il faut tenir...",
		"Mi-èm-a-ou, courage !",
		"Plus que quelques secondes.",
		"Pas maintenant, pas comme ça.",
		"Bondieu, garde-moi !",
		"Tilamb, reste debout !",
	},
	missionStart = {
		"L'aube se lève sur la mission.",
		"On y va.",
		"Tu sais ce qu'il te reste à faire.",
		"Allé, en avant marmaille !",
	},
	firstZombieKill = {
		"Le premier est tombé.",
		"Ça marche.",
		"Continue comme ça.",
		"Sa mêm i di !",
		"Ah ouais, tu gères tilamb.",
	},
	-- ===== Blagues créoles "quand tu tires sur un zombie" =====
	playerShoot = {
		"Atak don !",
		"Allé marche done !",
		"La moukate !",
		"Mi sava casse vot tête !",
		"Tiens, prends ça !",
		"Bouge de là, sale bouchon !",
		"Eh là-bas !",
		"Sa zafer !",
		"Boom, tilamb !",
		"Wèèèye, à la porte !",
	},
	volcanoRumble = {
		"Le Piton gronde.",
		"L'air sent le soufre.",
		"La cendre tombe encore...",
		"Quelque part, le cratère brille.",
		"Eh, la Fournaise est fâchée !",
	},
}

-- ============================================================================
-- LIGNES SPÉCIFIQUES PAR VILLE (hook ville → catégorie : tableau de lignes)
-- Permet aux services serveur de tirer une ligne contextuelle au lieu d'une
-- ligne générique quand le joueur joue dans cette ville.
-- ============================================================================
Story.CityHooks = {
	["Saint-Denis"] = {
		missionStart = {
			"Le Barachois est silencieux. C'est ici que tout commence.",
			"La Préfecture compte sur toi.",
		},
		waveCleared = {
			"Saint-Denis tient.",
			"Une lumière s'allume sur le front de mer.",
		},
	},
	["Saint-Paul"] = {
		missionStart = {
			"La plage est noire de cendre. Et de pas.",
			"L'Ouest n'a jamais semblé aussi long.",
		},
		waveCleared = {
			"La baie respire.",
			"La Buse aurait aimé voir ça.",
		},
	},
	["Saint-Pierre"] = {
		missionStart = {
			"Le marché du samedi est vide. Réveille-le.",
			"Le Sud t'attendait.",
		},
		waveCleared = {
			"Saint-Pierre rallume ses terrasses.",
		},
	},
	["Saint-Benoit"] = {
		missionStart = {
			"La pluie tombe, mais elle n'éteint pas tout.",
			"L'Est est dense. Reste prudent.",
		},
	},
	["Cilaos"] = {
		missionStart = {
			"1200 mètres au-dessus de la mer. L'air est mince.",
			"Le cirque protège, mais quelque chose grimpe.",
		},
		bossWarning = {
			"La Roche Merveilleuse vibre. Il descend.",
			"Une silhouette géante apparaît dans la brume.",
		},
		waveCleared = {
			"Le cirque tient bon.",
			"Les remparts ont vu pire — et toi aussi maintenant.",
		},
	},
	["Plaine-des-Cafres"] = {
		missionStart = {
			"L'odeur de soufre est forte. La route monte.",
			"Bourg-Murat. Dernière étape avant le cratère.",
		},
		volcanoRumble = {
			"Le Piton n'est plus qu'à un kilomètre.",
			"Tu sens la chaleur sous tes pieds.",
		},
	},
	["Piton-de-la-Fournaise"] = {
		missionStart = {
			"Pas Bellecombe. Au-delà : le Dolomieu.",
			"Le cratère est devant toi. Et lui aussi.",
		},
		bossWarning = {
			"Le Roi-Cendre se redresse.",
			"Le sol crache. La cendre tourbillonne.",
		},
		cityCleared = {
			"Le cratère s'éteint.",
			"L'aube revient sur La Réunion.",
			"Tu as sauvé l'île.",
		},
	},
}

-- ============================================================================
-- MODE ADULTE (+18) — lignes plus crues, activées via Config.AdultMode
-- Cf. ADULT_MODE.md. Reste sous limite "sans gore, sans contenu haineux".
-- ============================================================================
-- Mode adulte = ton "familier créole" : plus piquant, plus vivant
-- que le mode enfant, mais SANS gros mots vulgaires cassants.
-- (Pas de "putain", "merde", "ta race", "ton cul", "crève", "défoncer".)
Story.AdultLines = {
	playerHit = {
		"Aïe la moukate !",
		"Bondieu, ça fait mal !",
		"Tcho dehors, sale bête !",
		"Mi sava casser vot tête !",
		"Eh moukatère, recule donc !",
		"Allé marche, lâche-moi !",
		"Bondieu, ça suffit là !",
		"Hé là, doucement bonpèr !",
	},
	playerShoot = {
		"Atak don !",
		"Allé tcho dehors !",
		"Mi sava casser vot tête !",
		"Sale moukatère !",
		"Bouge de là, marmaille !",
		"Allé marche, sa zafer !",
		"Bondieu, prends ça !",
		"Tcho dehors gros bouchon !",
		"Adieu sale bête !",
		"Hop, à la porte !",
	},
	bossWarning = {
		"Bondieu, c'est quoi ce truc ?!",
		"Eh, ce gros bouchon va m'avoir.",
		"Sa zafer, ça sent pas bon là...",
		"Bondieu, garde-moi !",
		"Aïe Bondieu, mi té pa prêt pour ça !",
	},
	lowHp = {
		"Aïe, mi sava tomber...",
		"Bondieu, soigne-moi vite !",
		"Pitié, garde-moi debout !",
		"Mi-èm-a-ou, ne me lâche pas !",
		"Bondieu, c'est moukate quoi...",
	},
}

-- ============================================================================
-- API : pick une ligne, en priorité depuis CityHooks[city][category],
-- sinon Lines[category]. Si adultMode=true (param explicite OU reader global),
-- on tire d'abord dans AdultLines.
-- ============================================================================
local _AdultModeReader = nil  -- fallback global (peu utilisé désormais)
function Story.SetAdultModeReader(fn) _AdultModeReader = fn end

function Story.PickLine(category, city, adultMode)
	-- Calcule le mode adulte effectif : param explicite > reader global > false
	local isAdult = adultMode
	if isAdult == nil then
		isAdult = _AdultModeReader and _AdultModeReader() or false
	end

	-- Mode adulte : si dispo, tire dans AdultLines
	if isAdult and Story.AdultLines[category] then
		local list = Story.AdultLines[category]
		if #list > 0 then return list[math.random(1, #list)] end
	end
	if city and Story.CityHooks[city] and Story.CityHooks[city][category] then
		local list = Story.CityHooks[city][category]
		if #list > 0 then return list[math.random(1, #list)] end
	end
	local list = Story.Lines[category]
	if list and #list > 0 then return list[math.random(1, #list)] end
	return ""
end

return Story
