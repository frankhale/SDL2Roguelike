Game = {
	window_title = "Roguely - A simple Roguelike in C++/Lua/SDL2",
	window_icon_path = "assets/icon.png",
	window_width = 1280,
	window_height = 768,
	map_width = 125,
	map_height = 125,
	view_port_width = 40,
	view_port_height = 24,
	music = false,
	spritesheet_path = "assets/roguelike.png",
	soundtrack_path = "assets/ExitExitProper.mp3",
	font_path = "assets/VT323-Regular.ttf",
	logo_image_path = "assets/roguely-logo.png",
	start_game_image_path = "assets/press-space-bar-to-play.png",
	credit_image_path = "assets/credits.png",
	sounds = {
		coin = "assets/sounds/coin.wav",
		bump = "assets/sounds/bump.wav",
		combat = "assets/sounds/combat.wav",
		death = "assets/sounds/death.wav",
		pickup = "assets/sounds/pickup.wav",
		warp = "assets/sounds/warp.wav"
	},
	dead = false,
	started = false,
	total_enemies_killed = 0,
	won = false,
	lost = false,
	player_pos = {
		-- These is notional because after we generate a map we'll get a randomized
		-- position to start that is a known good ground tile
		x = 10,
		y = 10
	},
	sprite_info = {
		-- used for quick reference even though entities have a sprite component
		width = 32,
		height = 32,
		health_gem = 1,
		treasure_chest = 13,
		attack_bonus_gem = 2,
		player_sprite_id = 3,
		hidden_sprite_id = 18,
		heart_sprite_id = 48,
		coin_sprite_id = 14,
		spider_sprite_id = 4,
		lurcher_sprite_id = 5,
		crab_sprite_id = 12,
		bug_sprite_id = 17,
		firewalker_sprite_id = 21,
		crimsonshadow_sprite_id = 34,
		purpleblob_sprite_id = 61,
		orangeblob_sprite_id = 64,
		mantis_sprite_id = 54,
		golden_candle_sprite_id = 6,
		wall_with_grass_1 = 35,
		wall_with_grass_2 = 36
	},
	health_recovery_time = 0,
	health_recovery = 10,
	entities = {
		rewards = {
			coin = {
				components = {
					sprite_component = {
						name = "coin",
						spritesheet_name = "game-sprites",
						sprite_id = 14
					},
					value_component = {
						value = 25
					}
				},
				total = 100
			},
			healthgem =  {
				components = {
					sprite_component = {
						name = "healthgem",
						spritesheet_name = "game-sprites",
						sprite_id = 1
					},
					health_restoration_component = {
						type = "powerup",
						properties = {
							action = function(group, entity_name, component_name, component_value_name, existing_component_value)
								set_component_value(group, entity_name, component_name, component_value_name, existing_component_value + 25)
							end
						}
					}
				},
				total = 50
			},
			goldencandle = {
				components = {
					sprite_component = {
						name = "goldencandle",
						spritesheet_name = "game-sprites",
						sprite_id = 6
					},
					value_component = { value = 25000 },
					win_component = {
						type = "flags",
						properties = { win = true }
					}
				},
				total = 1
			}
		},
		enemies = {
			spider = {
				components = {
					sprite_component = {
						name = "spider",
						spritesheet_name = "game-sprites",
						sprite_id = 4
					},
					health_component = { health = 20 },
					stats_component = { attack = 1 }
				},
				total = 50
			},
			crab = {
				components = {
					sprite_component = {
						name = "crab",
						spritesheet_name = "game-sprites",
						sprite_id = 12
					},
					health_component = { health = 30 },
					stats_component = { attack = 2 }
				},
				total = 30
			},
			bug = {
				components = {
					sprite_component = {
						name = "bug",
						spritesheet_name = "game-sprites",
						sprite_id = 17
					},
					health_component = { health = 25 },
					stats_component = { attack = 2 }
				},
				total = 25
			},
			lurcher = {
				components = {
					sprite_component = {
						name = "lurcher",
						spritesheet_name = "game-sprites",
						sprite_id = 5
					},
					health_component = { health = 35 },
					stats_component = { attack = 2 }
				},
				total = 25
			},
			firewalker = {
				components = {
					sprite_component = {
						name = "firewalker",
						spritesheet_name = "game-sprites",
						sprite_id = 21
					},
					health_component = { health = 75 },
					stats_component = { attack = 4 }
				},
				total = 25
			},
			mantis = {
				components = {
					sprite_component = {
						name = "crimsonshadow",
						spritesheet_name = "game-sprites",
						sprite_id = 54
					},
					health_component = { health = 50 },
					stats_component = { attack = 3 }
				},
				total = 25
			},
			crimsonshadow = {
				components = {
					sprite_component = {
						name = "crimsonshadow",
						spritesheet_name = "game-sprites",
						sprite_id = 34
					},
					health_component = { health = 85 },
					stats_component = { attack = 5 }
				},
				total = 20
			},
			purpleblob = {
				components = {
					sprite_component = {
						name = "purpleblob",
						spritesheet_name = "game-sprites",
						sprite_id = 61
					},
					health_component = { health = 95 },
					stats_component = { attack = 6 }
				},
				total = 15
			},
			orangeblob = {
				components = {
					sprite_component = {
						name = "orangeblob",
						spritesheet_name = "game-sprites",
						sprite_id = 64
					},
					health_component = { health = 100 },
					stats_component = { attack = 7 }
				},
				total = 10
			}
		}
	}
}

ERROR = false

-- A PID is an X,Y identitier we use as a key into the entities table. This
-- saves us a for loop which is really slow! PID stands for position ID.
-- This function is used to get a PID for a direction the player wants to move.
-- This PID can be used to see if there is anything on the tile we want to move
-- onto.
function get_player_movement_direction_pid(dir)
	local x = 0
	local y = 0

	if(dir == "up") then
		x = Game.player_pos.x
		y = Game.player_pos.y - 1
	elseif(dir == "down") then
		x = Game.player_pos.x
		y = Game.player_pos.y + 1
	elseif(dir == "left") then
		x = Game.player_pos.x - 1
		y = Game.player_pos.y
	elseif(dir == "right") then
		x = Game.player_pos.x + 1
		y = Game.player_pos.y
	end

	return tostring(x .. "_" .. y)
end

function create_pid_from_x_y(x, y)
	return tostring(x .. "_" .. y)
end

function create_entities(entity_table, group, entity_name, entity_type)
	local entities = {}

	for k,v in pairs(entity_table[group]) do
		entities = add_entities(group, entity_type, v.components, v.total)
	end

	return entities
end

function _init()
	add_sprite_sheet("game-sprites", Game.spritesheet_path, Game.sprite_info.width, Game.sprite_info.height)

	Game.player_id = add_entity("common", "player", Game.player_pos.x, Game.player_pos.y, {
		sprite_component = {
			name = "player",
			spritesheet_name = "game-sprites",
			sprite_id = 3
		},
		health_component = { health = 60 },
		stats_component = { attack = 1 },
		score_component = { score = 0 },
		inventory_component = {
			items = {
				health_potion = 3
			}
		}
	})

	generate_map("main", Game.map_width, Game.map_height)
	switch_map("main")

	local pos = generate_random_point({ "common" })
	update_entity_position("common", "player", pos.x, pos.y)

	Game.items = create_entities(Game.entities, "rewards", "coin", "item")
	Game.enemies = create_entities(Game.entities, "enemies", "spider", "enemy")

	for k,v in pairs(Game.items) do
		for k1,v1 in pairs(v) do
			if(v1.components.sprite_component.name == "goldencandle") then
				Game.goldencandle = {
					point = v1.point,
					p_id = tostring(v1.point.x .. "_" .. v1.point.y)
				}
			end
		end
	end

	Game.map = get_map("main", false)
	fov("main")
end

function initiate_attack_sequence(pid)
	-- generate some random numbers for crit chance (player and enemy)
	local player_crit_chance = get_random_number(1, 100) <= 20
	local enemy_crit_chance =  get_random_number(1, 100) <= 20
	local player_attack = Game.player.components.stats_component.attack
	local player_health = Game.player.components.health_component.health
	local enemy_attack = Game.enemies[pid].enemy.components.stats_component.attack
	local enemy_health = Game.enemies[pid].enemy.components.health_component.health
	local enemy_id = Game.enemies[pid].enemy.id

	-- player strikes first
	if (player_crit_chance) then
		-- do crit attack
		local damage = player_attack + get_random_number(1, 5) * 2
		print("Player damage during attack = " .. damage)
		set_component_value("enemies", enemy_id, "health_component", "health", math.floor(enemy_health - damage))
	else
		-- do normal attack
		local damage = player_attack + get_random_number(1, 5)
		set_component_value("enemies", enemy_id, "health_component", "health", math.floor(enemy_health - damage))
		print("Player damage during attack = " .. damage)
	end

	-- enemy strikes next
	if (enemy_crit_chance) then
		-- do crit attack
		local damage = player_attack + get_random_number(1, 5) * 2
		set_component_value("common", "player", "health_component", "health", math.floor(player_health - damage))
	else
		-- do normal attack
		local damage = player_attack + get_random_number(1, 5)
		set_component_value("common", "player", "health_component", "health", math.floor(player_health - damage))
	end

	-- check to see if enemy died
	if(enemy_health <= 0) then
		print("Player killed enemy!!!")
		Game.total_enemies_killed = Game.total_enemies_killed + 1
		set_component_value("common", "player", "score_component", "score", Game.player.components.score_component.score + 25)
		remove_entity("enemies", enemy_id)
	end

	-- check to see if player died
	if (player_health <= 0) then
		Game.win_lose_message = "You ded son!"
		Game.lost = true
	end
end

function _update(event, data)
	if(event == "key_event") then
		if data["key"] == "up" then
			if(is_tile_walkable(Game.player_pos.x, Game.player_pos.y, "up", "player", { "common", "enemies" })) then
				update_entity_position("common", "player", Game.player_pos.x, Game.player_pos.y - 1)
			else
				local pid = get_player_movement_direction_pid("up")
				if(Game.enemies[pid]) then
					play_sound("combat")
					initiate_attack_sequence(pid)
				else
					play_sound("bump")
				end
			end
		 elseif data["key"] == "down" then
			if(is_tile_walkable(Game.player_pos.x, Game.player_pos.y, "down", "player", { "common", "enemies" })) then
				update_entity_position("common", "player", Game.player_pos.x, Game.player_pos.y + 1)
			else
				local pid = get_player_movement_direction_pid("down")
				if(Game.enemies[pid]) then
					play_sound("combat")
					initiate_attack_sequence(pid)
				else
					play_sound("bump")
				end
			end
		 elseif data["key"] == "left" then
			if(is_tile_walkable(Game.player_pos.x, Game.player_pos.y, "left", "player", { "common", "enemies" })) then
				update_entity_position("common", "player", Game.player_pos.x - 1, Game.player_pos.y)
			else
				local pid = get_player_movement_direction_pid("left")
				if(Game.enemies[pid]) then
					play_sound("combat")
					initiate_attack_sequence(pid)
				else
					play_sound("bump")
				end
			end
		 elseif data["key"] == "right" then
			if(is_tile_walkable(Game.player_pos.x, Game.player_pos.y, "right", "player", { "common", "enemies" })) then
				update_entity_position("common", "player", Game.player_pos.x + 1, Game.player_pos.y)
			else
				local pid = get_player_movement_direction_pid("right")
				if(Game.enemies[pid]) then
					play_sound("combat")
					initiate_attack_sequence(pid)
				else
					play_sound("bump")
				end
			end
		 elseif data["key"] == "space" then
			if (Game.started) then
				-- warp player (for testing purposes)
				play_sound("warp")
				local pos = generate_random_point({ "common" })
				update_entity_position("common", "player", pos.x, pos.y)
				set_component_value("common", "player", "health_component", "health", 10)
			else
				Game.lost = false
				Game.won = false
				Game.started = true
				reset()
			end
		end

		if(Game.started and Game.items[XY_Id]) then
			if (Game.items[XY_Id].item.components.sprite_component.name == "coin") then
				play_sound("coin")
				set_component_value("common", "player", "score_component", "score",
					Game.player.components.score_component.score +
					Game.items[XY_Id].item.components.value_component.value)
				remove_entity("rewards", Game.items[XY_Id].item.id)
			elseif (Game.items[XY_Id]["item"]["components"]["sprite_component"]["name"] == "healthgem") then
				play_sound("pickup")
				local action = Game.items[XY_Id].item.components.health_restoration_component.properties.action
				local player_current_health = Game.player.components.health_component.health
				action("common", "player", "health_component", "health", player_current_health)
				remove_entity("rewards", Game.items[XY_Id].item.id)
			elseif (Game.items[XY_Id]["item"]["components"]["sprite_component"]["name"] == "goldencandle") then
				-- TODO: Use the Lua Component associated with the goldencandle to determine actions to take
				Game.win_lose_message = "YOU WIN!!!"
				Game.won = true
				Game.started = false
				set_component_value("common", "player", "score_component", "score",
					Game.player.components.score_component.score +
					Game.items[XY_Id].item.components.value_component.value)
				remove_entity("rewards", Game.items[XY_Id].item.id)
			end
		end

	elseif (event == "entity_event") then
		if (data["player"] ~= nil) then
			Game.player = data["player"]
			Game.player_id = data["player"][Game.player_id]
			Game.player_pos["x"] = data["player"]["point"]["x"]
			Game.player_pos["y"] = data["player"]["point"]["y"]
			XY_Id = tostring(Game.player_pos["x"] .. "_" .. Game.player_pos["y"])
			fov("main")
		elseif (data["enemy"] ~= nil) then
			local enemy_pid = create_pid_from_x_y(data["enemy"].point.x, data["enemy"].point.y)
			Game.enemies[enemy_pid].enemy = data["enemy"]
		else
			if(data["entity_group_name"] == "rewards") then
			 	Game.items = data["entity_group"]
			else
				Game.enemies = data["entity_group"]
			end
		end
	elseif (event == "light_map") then
	 	Game.light_map = data
	end
end

function calculate_health_bar_width(health, starting_health, health_bar_max_width)
	local hw = health_bar_max_width

	if (health <= starting_health) then
		hw = (((health * (100 / starting_health)) * health_bar_max_width) / 100)
	end

	return math.floor(hw)
end

function render_info_bar()
	set_draw_color(28 , 28, 28, 128)
	draw_filled_rect(10, 10, 290, 150)

	draw_sprite_scaled("game-sprites", Game.sprite_info["heart_sprite_id"], 20, 20, Game.sprite_info.width * 2, Game.sprite_info.height * 2)

	local p_hw = calculate_health_bar_width(Game.player["components"]["health_component"]["health"], Game.player["components"]["health_component"]["max_health"], 200)

	set_draw_color(33, 33, 33, 255)
	draw_filled_rect((Game.sprite_info.width * 2 + 20), 36, 200, 24)

	if (Game.player["components"]["health_component"]["health"] <= Game.player["components"]["health_component"]["max_health"] / 3) then
		set_draw_color(255, 0, 0, 255) -- red player's health is in trouble
	else
		set_draw_color(8, 138, 41, 255) -- green for player
	end

	draw_filled_rect((Game.sprite_info.width * 2 + 20), 36, math.floor(p_hw), 24)

	draw_text(tostring(Game.player["components"]["health_component"]["health"]), "medium", (Game.sprite_info.width * 3 + 70), 28)
	draw_text(tostring(Game.player["components"]["score_component"]["score"]), "large", 40, 90)

	set_draw_color(0, 0, 0, 255)
end

function render_mini_map()
	local offset_x = Game["window_width"] - 150
	local offset_y = 10
	for r = 1, Game["map_height"] do
		for c = 1, Game["map_width"] do
			local dx = (c - 1) + offset_x
			local dy = (r - 1) + offset_y

			if (Game.map[r][c] == 0 or
				Game.map[r][c] == 35 or
				Game.map[r][c] == 36) then
				set_draw_color(255, 255, 255, 128)
				draw_point(dx, dy)
			elseif (Game.map[r][c] == 9) then
				set_draw_color(0, 0, 0, 128)
				draw_point(dx, dy)
			end

			if (dx == Game.goldencandle.point.x + offset_x and dy == Game.goldencandle.point.y) then
			 	set_draw_color(0, 255, 0, 255)
			 	draw_filled_rect(dx - 3, dy - 3, 6, 6)
			end

			if (dx == Game.player_pos["x"] + offset_x and dy == Game.player_pos["y"] + offset_y) then
				set_draw_color(255, 0, 0, 255)
				draw_filled_rect(dx - 3, dy - 3, 6, 6)
			end
		end
	end

	set_draw_color(0,0,0,255)
end

function render_entity(entity_group, entity_type, p_id, dx, dy)
	if(entity_group[p_id]) then
		local sprite_id = entity_group[p_id][entity_type]["components"]["sprite_component"]["sprite_id"]
		local spritesheet_name = entity_group[p_id][entity_type]["components"]["sprite_component"]["spritesheet_name"]

		if(entity_type == "enemy") then
			render_health_bar(entity_group[p_id][entity_type], 255, 0, 0, dx, dy)
		end

		draw_sprite(spritesheet_name, sprite_id, dx, dy)
	end
end

function render_health_bar(entity, r, g, b, dx, dy)
	local hw = calculate_health_bar_width(entity["components"]["health_component"]["health"],
										  entity["components"]["health_component"]["max_health"], Game.sprite_info.width)

	if(hw >= 0) then
		set_draw_color(r, g, b, 255)
		draw_filled_rect(dx, dy - 8, hw, 6)
		set_draw_color(0, 0, 0, 255)
	end
end

function render_title_screen()
	draw_graphic(Game.logo_image_path, Game.window_width, 0, 20, true, true, 2)

	draw_sprite("game-sprites", Game.sprite_info["orangeblob_sprite_id"], math.floor(Game.window_width / 2 - 256), 325)
	draw_sprite("game-sprites", Game.sprite_info["crimsonshadow_sprite_id"], math.floor(Game.window_width / 2 - 192), 325)
	draw_sprite("game-sprites", Game.sprite_info["spider_sprite_id"], math.floor(Game.window_width / 2 - 128), 325)
	draw_sprite("game-sprites", Game.sprite_info["lurcher_sprite_id"], math.floor(Game.window_width / 2 - 64), 325)
	draw_sprite("game-sprites", Game.sprite_info["player_sprite_id"], math.floor(Game.window_width / 2), 325)
	draw_sprite("game-sprites", Game.sprite_info["crab_sprite_id"], math.floor(Game.window_width / 2 + 64), 325)
	draw_sprite("game-sprites", Game.sprite_info["firewalker_sprite_id"], math.floor(Game.window_width / 2 + 128), 325)
	draw_sprite("game-sprites", Game.sprite_info["mantis_sprite_id"], math.floor(Game.window_width / 2 + 192), 325)
	draw_sprite("game-sprites", Game.sprite_info["purpleblob_sprite_id"], math.floor(Game.window_width / 2 + 256), 325)

	draw_graphic(Game.start_game_image_path, Game.window_width, 0, 215, true, true, 2)
	draw_graphic(Game.credit_image_path, Game.window_width, 0, 300, true, true, 2)
end

function render_win_or_death_screen()
	local text_extents = get_text_extents(Game.win_lose_message, "large")
	draw_text(Game.win_lose_message, "large", math.floor(Game.window_width / 2 - text_extents.width / 2),
											  math.floor(Game.window_height / 2 - text_extents.height / 2))
	draw_text(tostring("Final Score: " .. Game.player["components"]["score_component"]["score"]), "large", 20, 20)
	draw_text(tostring("Total Enemies Killed: " .. Game.total_enemies_killed), "large", 20, 70)
	draw_text("Press the space bar to play again...", "medium", math.floor(Game.window_width / 2 - text_extents.width / 2 - 150), Game.window_height - 100)
end

function _render(delta_time)
	if (ERROR) then
		return
	end

	if(Game.started == false and Game.won == false) then
			render_title_screen()
		else if (Game.started == true and Game.won == false and Game.lost == false) then
			for r = 1, get_view_port_height() do
				for c = 1, get_view_port_width() do
					local p_id = tostring((c-1) .. "_" .. (r-1))
					local dx = ((c-1) * Game.sprite_info.width) - (get_view_port_x() * Game.sprite_info.width)
					local dy = ((r-1) * Game.sprite_info.height) - (get_view_port_y() * Game.sprite_info.height)

					if(Game.light_map[r][c] == 2) then
						draw_sprite("game-sprites", Game.map[r][c], dx, dy)

						render_entity(Game.items, "item", p_id, dx, dy)
						render_entity(Game.enemies, "enemy", p_id, dx, dy)

						if(Game.player_pos["x"] == (c-1) and Game.player_pos["y"] == (r-1)) then
							render_health_bar(Game.player, 8, 138, 41, dx, dy)
							draw_sprite("game-sprites", Game.sprite_info["player_sprite_id"], dx, dy)
						end
					else
						draw_sprite("game-sprites", Game.sprite_info["hidden_sprite_id"] , dx, dy)
					end
				end
			end

			render_info_bar()
			render_mini_map()
		else
			render_win_or_death_screen()
		end
	end
end

function _tick(delta_time)
	Game.health_recovery_time = Game.health_recovery_time + delta_time
	if(Game.health_recovery_time >= 2) then
		Game.health_recovery_time = 0
		if(Game.player.components.health_component.health < Game.player.components.health_component.max_health) then
			set_component_value("common", "player", "health_component", "health", math.floor(Game.player.components.health_component.health + Game.health_recovery))
		end
	end
end

function _error(err)
	ERROR = true
	print("An error occurred: " .. err)
end
