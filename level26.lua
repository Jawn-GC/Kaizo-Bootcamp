local checkpoints = require("Checkpoints/checkpoints")
local sound = require('play_sound')

local level_var = {
    identifier = "level26",
    title = "Sunken City-2",
    theme = THEME.SUNKEN_CITY,
    world = 7,
	level = 2,
	width = 4,
    height = 4,
    file_name = "level26.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

level_var.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true
	
	replace_drop(DROP.EGGSAC_GRUB_1, ENT_TYPE.ITEM_BLOOD)
	replace_drop(DROP.EGGSAC_GRUB_2, ENT_TYPE.ITEM_BLOOD)
	replace_drop(DROP.EGGSAC_GRUB_3, ENT_TYPE.ITEM_BLOOD)
	
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.ITEM_PICKUP_SKELETON_KEY)
	
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_SKELETON)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.ANY, 0, ENT_TYPE.ITEM_SKULL)
	
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.ANY, 0, ENT_TYPE.ITEM_BONES)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_GENERIC)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOORSTYLED_SUNKEN)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_THORN_VINE)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.x = entity.x - 0.5
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.ITEM_TELESCOPE)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_CONVEYORBELT_LEFT)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_CONVEYORBELT_RIGHT)

	local mother_platform = {}
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.player1_health_received = true
		mother_platform[#mother_platform + 1] = entity.uid
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_MOTHER_STATUE)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:give_powerup(ENT_TYPE.ITEM_POWERUP_SPIKE_SHOES)
	end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_SNAKE)

	local golden_idol_xy
	define_tile_code("golden_idol")
	level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
		golden_idol_xy = {x,y,layer}
	end, "golden_idol")

	local tusken_idol_xy
	define_tile_code("tusken_idol")
	level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
		tusken_idol_xy = {x,y,layer}
	end, "tusken_idol")

	local laser = {}
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		laser[#laser + 1] = entity
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_HORIZONTAL_FORCEFIELD)

	-- I'm using my own variables for mother statue stuff because the ones from the API aren't changing values for some reason.
	local frames = 0
	local mother_activated = false
	local mother_frames = 0
	local player_standing_on_statue = false
	local idol
	laser_on = false
	level_state.callbacks[#level_state.callbacks+1] = set_callback(function ()	
		if laser[1].timer > 0 and laser_on == false then
			laser_on = true
		end
		
		if laser_on == true then
			for i = 1,#laser do
				laser[i].timer = 2 -- Keep forcefield on
			end
		end
		
		if #players > 0 then
			for i = 1,#mother_platform do
				if players[1].standing_on_uid == mother_platform[i] then
					player_standing_on_statue = true
				end
			end
			if player_standing_on_statue == true and mother_activated == false then
				mother_frames = mother_frames + 1
			else
				mother_frames = 0
			end
		end
		player_standing_on_statue = false
		
		if mother_frames == 600 and mother_activated == false then
			mother_activated = true
			
			idol = spawn(ENT_TYPE.ITEM_IDOL, golden_idol_xy[1], golden_idol_xy[2], golden_idol_xy[3], 0, 0)
			get_entity(idol).flags = set_flag(get_entity(idol).flags, ENT_FLAG.INTERACT_WITH_SEMISOLIDS)
			generate_world_particles(PARTICLEEMITTER.TELEPORTEFFECT_GREENSPARKLES, idol)
			generate_world_particles(PARTICLEEMITTER.TELEPORTEFFECT_REDSPARKLES, idol)
			sound.play_sound(VANILLA_SOUND.SHARED_TELEPORT)
			
			idol = spawn(ENT_TYPE.ITEM_MADAMETUSK_IDOL, tusken_idol_xy[1], tusken_idol_xy[2], tusken_idol_xy[3], 0, 0)
			get_entity(idol).flags = set_flag(get_entity(idol).flags, ENT_FLAG.INTERACT_WITH_SEMISOLIDS)
			generate_world_particles(PARTICLEEMITTER.TELEPORTEFFECT_GREENSPARKLES, idol)
			generate_world_particles(PARTICLEEMITTER.TELEPORTEFFECT_REDSPARKLES, idol)
			sound.play_sound(VANILLA_SOUND.SHARED_TELEPORT)
		end
		
		frames = frames + 1
    end, ON.FRAME)
	
	if not options.checkpoints_disabled then
		checkpoints.activate()
	end
	
	toast(level_var.title)
	
end

level_var.unload_level = function()
    if not level_state.loaded then return end
    
	checkpoints.deactivate()
	replace_drop(DROP.EGGSAC_GRUB_1, ENT_TYPE.MONS_GRUB)
	replace_drop(DROP.EGGSAC_GRUB_2, ENT_TYPE.MONS_GRUB)
	replace_drop(DROP.EGGSAC_GRUB_3, ENT_TYPE.MONS_GRUB)
	
    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _, callback in pairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return level_var
