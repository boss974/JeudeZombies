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
-- API : pick une ligne, en priorité depuis CityHooks[city][category], sinon Lines[category]
-- ============================================================================
function Story.PickLine(category, city)
	if city and Story.CityHooks[city] and Story.CityHooks[city][category] then
		local list = Story.CityHooks[city][category]
		if #list > 0 then return list[math.random(1, #list)] end
	end
	local list = Story.Lines[category]
	if list and #list > 0 then return list[math.random(1, #list)] end
	return ""
end

return Story
