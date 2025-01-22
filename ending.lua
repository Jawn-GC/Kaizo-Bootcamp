local ending = {
    identifier = "Ending",
    title = "Ending",
    theme = THEME.EGGPLANT_WORLD,
	world = 7,
	level = 5,
    width = 4,
    height = 4,
    file_name = "Egg.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

ending.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_GENERIC)
	
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOORSTYLED_PAGODA)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity.station = 1
	end, SPAWN_TYPE.ANY, 0, ENT_TYPE.TV)

	local frames = 0
	level_state.callbacks[#level_state.callbacks+1] = set_callback(function ()
		frames = frames + 1
    end, ON.FRAME)
	
	toast("Congratulations!")
end

ending.unload_level = function()
    if not level_state.loaded then return end
    
    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _, callback in pairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return ending