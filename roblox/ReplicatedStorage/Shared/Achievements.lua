-- Achievements.lua
-- Liste des succès / trophées débloquables. Chaque achievement :
--   - id (unique)
--   - title (affiché)
--   - description
--   - icon (emoji)
--   - tier : "bronze" | "silver" | "gold" | "platinum"
--   - trigger : type d'évènement qui le déclenche (interprété par AchievementService)
--   - target : seuil pour déclencher

local Achievements = {}

Achievements.List = {
	-- ========== Premiers pas ==========
	first_zombie = {
		id = "first_zombie",
		title = "Premier moukatère tombé",
		desc = "Tue ton premier zombie. Bienvenue dans la résistance !",
		icon = "🧟",
		tier = "bronze",
		trigger = "kill_count", target = 1,
	},
	ten_zombies = {
		id = "ten_zombies",
		title = "Petit nettoyeur",
		desc = "Tue 10 zombies au total.",
		icon = "🔫",
		tier = "bronze",
		trigger = "kill_count", target = 10,
	},
	hundred_zombies = {
		id = "hundred_zombies",
		title = "Tilamb badass",
		desc = "100 zombies envoyés faire dodo pour de vrai.",
		icon = "💪",
		tier = "silver",
		trigger = "kill_count", target = 100,
	},
	thousand_zombies = {
		id = "thousand_zombies",
		title = "Légende du 974",
		desc = "1000 zombies. La Réunion te doit la vie.",
		icon = "👑",
		tier = "gold",
		trigger = "kill_count", target = 1000,
	},

	-- ========== Photos ==========
	first_photo = {
		id = "first_photo",
		title = "Premier cliché",
		desc = "Prends ta première photo touristique.",
		icon = "📸",
		tier = "bronze",
		trigger = "photo_count", target = 1,
	},
	five_photos = {
		id = "five_photos",
		title = "Photographe en herbe",
		desc = "5 photos différentes prises.",
		icon = "🖼️",
		tier = "bronze",
		trigger = "photo_count", target = 5,
	},
	twenty_photos = {
		id = "twenty_photos",
		title = "Tour de l'île",
		desc = "20 photos. Tu connais l'île par cœur.",
		icon = "🗺️",
		tier = "silver",
		trigger = "photo_count", target = 20,
	},

	-- ========== Missions ==========
	first_city = {
		id = "first_city",
		title = "Saint-Denis sauvée",
		desc = "Libère la première ville du scénario.",
		icon = "🏛️",
		tier = "bronze",
		trigger = "city_complete", target = 1,
	},
	half_cities = {
		id = "half_cities",
		title = "À mi-chemin",
		desc = "Libère 4 villes (Saint-Benoît atteint).",
		icon = "🌧️",
		tier = "silver",
		trigger = "city_complete", target = 4,
	},
	all_cities = {
		id = "all_cities",
		title = "Sauveur de La Réunion",
		desc = "Libère les 7 villes du scénario principal.",
		icon = "🌋",
		tier = "platinum",
		trigger = "city_complete", target = 7,
	},

	-- ========== Pickups ==========
	first_pickup = {
		id = "first_pickup",
		title = "Premier zaffaire",
		desc = "Ramasse ton premier pickup.",
		icon = "💚",
		tier = "bronze",
		trigger = "pickup_count", target = 1,
	},
	bon_marché = {
		id = "bon_marche",
		title = "Bon marché",
		desc = "Ramasse 20 pickups au total.",
		icon = "🛒",
		tier = "silver",
		trigger = "pickup_count", target = 20,
	},

	-- ========== Boss ==========
	miniboss_down = {
		id = "miniboss_down",
		title = "La Roche Merveilleuse",
		desc = "Bats le mini-boss de Cilaos.",
		icon = "🏔️",
		tier = "silver",
		trigger = "boss_killed", target = 1,
	},
	roi_cendre_down = {
		id = "roi_cendre_down",
		title = "Le Roi-Cendre éteint",
		desc = "Bats le boss final au Piton de la Fournaise.",
		icon = "🔥",
		tier = "gold",
		trigger = "boss_killed", target = 2,
	},

	-- ========== Style / Easter eggs ==========
	mega_jump = {
		id = "mega_jump",
		title = "Tilamb cabri",
		desc = "Saut géant utilisé pour la première fois.",
		icon = "⬆️",
		tier = "bronze",
		trigger = "mega_jump", target = 1,
	},
	portal_user = {
		id = "portal_user",
		title = "Voyageur des cirques",
		desc = "Utilise un portail vers une autre ville.",
		icon = "🌀",
		tier = "bronze",
		trigger = "portal_use", target = 1,
	},
	adult_mode = {
		id = "adult_mode",
		title = "Mode adulte activé",
		desc = "Tu as plus de 18 ans et tu l'as confirmé via F1.",
		icon = "🔞",
		tier = "bronze",
		trigger = "adult_mode_on", target = 1,
	},
	moukate = {
		id = "moukate",
		title = "La Moukate",
		desc = "Le moukatère t'a touché. Bienvenue dans la moukate.",
		icon = "😅",
		tier = "bronze",
		trigger = "got_hit", target = 1,
	},
	low_hp_survive = {
		id = "low_hp_survive",
		title = "Mi-èm-a-ou",
		desc = "Survis avec moins de 10 HP pendant une vague entière.",
		icon = "❤️‍🩹",
		tier = "gold",
		trigger = "low_hp_wave_clear", target = 1,
	},
}

-- Helpers
function Achievements.Get(id)
	return Achievements.List[id]
end

function Achievements.AllIds()
	local ids = {}
	for id in pairs(Achievements.List) do table.insert(ids, id) end
	return ids
end

return Achievements
