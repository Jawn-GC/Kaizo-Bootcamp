return function()
    local stats = {}

    -- Stats for games played in the default difficulty.
    stats.normal = {
        best_time = 0,
        best_time_idol_count = 0,
        best_time_death_count = 0,
        least_deaths_completion = nil,
        least_deaths_completion_time = 0,
        max_idol_completions = 0,
        max_idol_best_time = 0,
        deathless_completions = 0,
        best_level = nil,
        completions = 0,
    }
    return stats
end