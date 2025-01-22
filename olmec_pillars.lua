-- olmec pillars that grow up until they hit a ceiling or level ends
define_tile_code("pillar_grow")
set_pre_tile_code_callback(function(x, y, layer)
    local bottom = get_entity(spawn_critical(ENT_TYPE.BG_OLMEC_PILLAR, x, y, layer, 0, 0))
    bottom.animation_frame = 10
    y = y + 1
    local top
    while #get_entities_at(0, MASK.FLOOR, x, y, layer, 1) == 0 and y < 123 do
        top = get_entity(spawn_critical(ENT_TYPE.BG_OLMEC_PILLAR, x, y, layer, 0, 0))
        top.animation_frame = 5
        y = y + 1
    end
    top.animation_frame = 0
end, "pillar_grow")
