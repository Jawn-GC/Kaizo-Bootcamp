define_tile_code("checkpoint")

local function play_sound(vanilla_sound)
	local sound = get_sound(vanilla_sound)
	if sound then
		sound:play()
	end
end

local CHECKPOINT_STYLE = {
    DEFAULT_BORING = 0,
    GREENI = 1,
	CUSTOM = 2,
}
local MAX_CHECKPOINT_STYLE = CHECKPOINT_STYLE.CUSTOM

local checkpoint_params = {
    directory = "Checkpoints",
    style = CHECKPOINT_STYLE.GREENI,
    custom_active_texture = nil,
    custom_inactive_texture = nil,
}

local checkpoint_state = {
    checkpoints = {},
    active_location = nil,
    callback =  nil,
    active = false,
    time = nil
}

local inactive_texture
local active_texture

local function set_directory(directory)
    directory = directory or 'Checkpoints'
    checkpoint_params.directory = directory
    inactive_texture = nil
    active_texture = nil
end

local function set_style(style, custom_active_texture, custom_inactive_texture)
    style = style or CHECKPOINT_STYLE.DEFAULT_BORING
    if style > MAX_CHECKPOINT_STYLE then style = CHECKPOINT_STYLE.DEFAULT_BORING end
    checkpoint_params.style = style
    checkpoint_params.custom_active_texture = custom_active_texture
    checkpoint_params.custom_inactive_texture = custom_inactive_texture
    inactive_texture = nil
    active_texture = nil
end

local texture_definition = TextureDefinition.new()
texture_definition.width = 128
texture_definition.height = 128
texture_definition.tile_width = 128
texture_definition.tile_height = 128
local function active_checkpoint_texture()
    if active_texture then return active_texture end
    local style = checkpoint_params.style
    local texture_file_name = "checkpoint_active.png"
    if style == CHECKPOINT_STYLE.CUSTOM then
        active_texture = checkpoint_params.custom_active_texture
        return active_texture
    elseif style == CHECKPOINT_STYLE.DEFAULT_BORING then
        texture_file_name = "checkpoint_active.png"
    elseif style == CHECKPOINT_STYLE.GREENI then
        texture_file_name = "checkpoint_active_greeni.png"
    end
    texture_definition.texture_path = f'{checkpoint_params.directory}/Textures/{texture_file_name}'
    active_texture = define_texture(texture_definition)
    return active_texture
end

local function inactive_checkpoint_texture()
    if inactive_texture then return inactive_texture end
    local style = checkpoint_params.style
    local texture_file_name = "checkpoint_inactive.png"
    if style == CHECKPOINT_STYLE.CUSTOM then
        inactive_texture = checkpoint_params.custom_inactive_texture
        return inactive_texture
    elseif style == CHECKPOINT_STYLE.DEFAULT_BORING then
        texture_file_name = "checkpoint_inactive.png"
    elseif style == CHECKPOINT_STYLE.GREENI then
        texture_file_name = "checkpoint_inactive_greeni.png"
    end
    texture_definition.texture_path = f'{checkpoint_params.directory}/Textures/{texture_file_name}'
    inactive_texture = define_texture(texture_definition)
    return inactive_texture
end

local function checkpoint_activate_callback(callback)
    checkpoint_state.callback = callback
end

local function activate_checkpoint_at(x, y, layer, time)
    for _, checkpoint in pairs(checkpoint_state.checkpoints) do
        if checkpoint.x == x and checkpoint.y == y and checkpoint.layer == layer then
            checkpoint.checkpoint:set_texture(active_checkpoint_texture())
            checkpoint.active = true
        else
            checkpoint.checkpoint:set_texture(inactive_checkpoint_texture())
            checkpoint.active = false
        end
    end
    checkpoint_state.active_location = {x = x, y = y, layer = layer, time = time}
end

-- Spawn a checkpoint.
--
-- x, y, layer: Position of checkpoint.
-- callback: callback called when the checkpoint is crossed. Passes the position as parameters.
local function spawn_checkpoint(x, y, layer)
    local is_active = false
    local active_location = checkpoint_state.active_location
    if active_location and active_location.x == x and active_location.y == y and active_location.layer == layer then
        is_active = true
    end
    local checkpoint_uid = spawn_entity(ENT_TYPE.ITEM_CONSTRUCTION_SIGN, x, y, layer, 0, 0)
    local checkpoint = get_entity(checkpoint_uid)
    checkpoint.flags = clr_flag(checkpoint.flags, ENT_FLAG.PICKUPABLE)
    checkpoint.flags = clr_flag(checkpoint.flags, ENT_FLAG.THROWABLE_OR_KNOCKBACKABLE)
    checkpoint.flags = set_flag(checkpoint.flags, ENT_FLAG.NO_GRAVITY)
    checkpoint.flags = clr_flag(checkpoint.flags, ENT_FLAG.ENABLE_BUTTON_PROMPT)
    checkpoint:set_texture(is_active and active_checkpoint_texture() or inactive_checkpoint_texture())
    checkpoint.animation_frame = 0

    local checkpoint_object = {
        checkpoint = checkpoint,
        x = x,
        y = y,
        layer = layer,
        active = is_active
    }
    local collision = set_pre_collision2(checkpoint_uid, function(self, collision_entity)
        if checkpoint_object.active then return end
        if #players < 1 then return end
        if collision_entity == players[1] and players[1].health > 0 and players[1].airtime == 0 then
            activate_checkpoint_at(x, y, layer, state.time_level)
            if checkpoint_state.callback then
                checkpoint_state.callback(x, y, layer, state.time_level)
            end
            play_sound(VANILLA_SOUND.UI_GET_ITEM1)
			generate_world_particles(PARTICLEEMITTER.TREASURE_SPARKLE_HIGH, checkpoint_uid)
        end
    end)
    checkpoint_object.collision = collision
    checkpoint_state.checkpoints[#checkpoint_state.checkpoints+1] = checkpoint_object
end

local function spawn_checkpoint_flag(x, y, layer)
    local flag_uid = spawn_entity(ENT_TYPE.ITEM_CONSTRUCTION_SIGN, x, y, layer, 0, 0)
    local flag = get_entity(flag_uid)
    flag.flags = clr_flag(flag.flags, ENT_FLAG.PICKUPABLE)
    flag.flags = clr_flag(flag.flags, ENT_FLAG.THROWABLE_OR_KNOCKBACKABLE)
    flag.flags = set_flag(flag.flags, ENT_FLAG.NO_GRAVITY)
    flag.flags = clr_flag(flag.flags, ENT_FLAG.ENABLE_BUTTON_PROMPT)
    flag:set_texture(active_checkpoint_texture())
    flag.animation_frame = 0
end

set_pre_tile_code_callback(function(x, y, layer)
    if not checkpoint_state.active then return true end
    spawn_checkpoint(x, y, layer)
end, "checkpoint")

set_pre_tile_code_callback(function(x, y, layer)
    if not checkpoint_state.active then return false end
    if state.screen == 13 then return false end
    if checkpoint_state.active_location then return true end
end, "entrance")

set_callback(function()
    if not checkpoint_state.active then return end
    if state.screen == 13 then return end
    if checkpoint_state.active_location then
        local x, y = checkpoint_state.active_location.x, checkpoint_state.active_location.y
        state.level_gen.spawn_x = x
        state.level_gen.spawn_y = y
        state.camera.focus_x = x
        state.camera.focus_y = y
        state.camera.adjusted_focus_x = x
        state.camera.adjusted_focus_y = y
    end
end, ON.POST_ROOM_GENERATION)

set_callback(function()
    if not checkpoint_state.active then return end
    if state.screen == SCREEN.TRANSITION then return end
    if checkpoint_state.active_location then
        state.time_level = checkpoint_state.active_location.time
    end
end, ON.POST_LEVEL_GENERATION)

local saved_checkpoint

set_callback(function()
    if state.loading == 1 and (state.screen_next == SCREEN.TRANSITION or state.theme == THEME.BASE_CAMP) then
        saved_checkpoint = nil
    end
end, ON.LOADING)

local function save_checkpoint(checkpoint)
    saved_checkpoint = checkpoint
end

local function get_saved_checkpoint()
    return saved_checkpoint
end

local function get_saved_checkpoints()
    return checkpoint_state.checkpoints
end

local function activate()
    checkpoint_state.active = true

    checkpoint_activate_callback(function(x, y, layer, time)
        save_checkpoint({
            position = {
                x = x,
                y = y,
                layer = layer,
            },
            time = time,
        })
    end)

    if saved_checkpoint then
        activate_checkpoint_at(
            saved_checkpoint.position.x,
            saved_checkpoint.position.y,
            saved_checkpoint.position.layer,
            saved_checkpoint.time
        )
    end
end

local function deactivate()
    for _, checkpoint in pairs(checkpoint_state.checkpoints) do
        clear_callback(checkpoint.collision)
    end
    checkpoint_state.checkpoints = {}
    checkpoint_state.active = false
    checkpoint_state.callback = nil
    checkpoint_state.active_location = nil
end

return {
    save_checkpoint = save_checkpoint,
    get_saved_checkpoint = get_saved_checkpoint,
    get_saved_checkpoints = get_saved_checkpoints,
    spawn_checkpoint = spawn_checkpoint,
    spawn_checkpoint_flag = spawn_checkpoint_flag,
    activate_checkpoint_at = activate_checkpoint_at,
    checkpoint_activate_callback = checkpoint_activate_callback,
    set_directory = set_directory,
    set_style = set_style,
    CHECKPOINT_STYLE = CHECKPOINT_STYLE,

    activate = activate,
    deactivate = deactivate,
}
