-- horizontal forcefields that are actually pointing in the right direction
-- left is off when right is on, like in tiamat
define_tile_code("forcefield_right")
set_pre_tile_code_callback(function(x, y, layer)
    local uid = spawn_grid_entity(ENT_TYPE.FLOOR_HORIZONTAL_FORCEFIELD, x, y, layer)
    local ent = get_entity(uid)
    ent.angle = 3*math.pi/2
end, "forcefield_right")
define_tile_code("forcefield_right_top")
set_pre_tile_code_callback(function(x, y, layer)
    local uid = spawn_grid_entity(ENT_TYPE.FLOOR_HORIZONTAL_FORCEFIELD_TOP, x, y, layer)
    local ent = get_entity(uid)
    ent.angle = 3*math.pi/2
end, "forcefield_right_top")
define_tile_code("forcefield_left")
set_pre_tile_code_callback(function(x, y, layer)
    local uid = spawn_grid_entity(ENT_TYPE.FLOOR_HORIZONTAL_FORCEFIELD, x, y, layer)
    local ent = get_entity(uid)
    ent.angle = math.pi/2
    ent.flags = set_flag(ent.flags, ENT_FLAG.FACING_LEFT)
    ent.timer = 60
end, "forcefield_left")
define_tile_code("forcefield_left_top")
set_pre_tile_code_callback(function(x, y, layer)
    local uid = spawn_grid_entity(ENT_TYPE.FLOOR_HORIZONTAL_FORCEFIELD_TOP, x, y, layer)
    local ent = get_entity(uid)
    ent.angle = math.pi/2
    ent.flags = set_flag(ent.flags, ENT_FLAG.FACING_LEFT)
end, "forcefield_left_top")
