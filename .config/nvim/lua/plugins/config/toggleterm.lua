return {
    size = function(term)
        if term.direction == "horizontal" then
            return math.floor(vim.o.lines * 0.3)
        elseif term.direction == "vertical" then
            return math.floor(vim.o.columns * 0.8)
        end
        return 20
    end,
    open_mapping = [[<c-\>]],
    shade_terminals = true,
    start_in_insert = true,
    direction = 'float',
    float_opts = {
        border = "curved",
        width = math.floor(vim.o.columns * 0.85),
        height = math.floor(vim.o.lines * 0.85),
    },
}
