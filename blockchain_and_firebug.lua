-- this one is a bit more complicated than the other example here,
-- but these chains will also attach to blocks in the middle

-- piece of chain, attached to what's on top
define_tile_code("chain")
set_pre_tile_code_callback(function(x, y, layer)
    local ceiling = get_grid_entity_at(x, y+1, layer)
    if ceiling == -1 then
        local block = get_entities_at(ENT_TYPE.ACTIVEFLOOR_CHAINEDPUSHBLOCK, MASK.ACTIVEFLOOR, x, y+1, layer, 0.5)
        if #block > 0 then
            ceiling = block[1]
        end
    end
    spawn_over(ENT_TYPE.FLOOR_CHAINANDBLOCKS_CHAIN, ceiling, 0, -1)
    return true
end, "chain")

-- piece of chain with a firebug on it
define_tile_code("chain_firebug")
set_pre_tile_code_callback(function(x, y, layer)
    local ceiling = get_grid_entity_at(x, y+1, layer)
    if ceiling == -1 then
        local block = get_entities_at(ENT_TYPE.ACTIVEFLOOR_CHAINEDPUSHBLOCK, MASK.ACTIVEFLOOR, x, y+1, layer, 0.5)
        if #block > 0 then
            ceiling = block[1]
        end
    end
    local chain = spawn_over(ENT_TYPE.FLOOR_CHAINANDBLOCKS_CHAIN, ceiling, 0, -1)
    spawn_over(ENT_TYPE.MONS_FIREBUG, chain, 0, 0)
    return true
end, "chain_firebug")

-- block, attached to what's on top
define_tile_code("chain_block")
set_pre_tile_code_callback(function(x, y, layer)
    local ceiling = get_grid_entity_at(x, y+1, layer)
    spawn_over(ENT_TYPE.ACTIVEFLOOR_CHAINEDPUSHBLOCK, ceiling, 0, -1)
    return true
end, "chain_block")
