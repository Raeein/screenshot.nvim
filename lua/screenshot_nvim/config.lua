local M = {}

local config = {
    clipboard = true,
    save_screenshot = false,
    save_dir = "",
}

function M.get_default_options()
    return config
end

function M.setup(options)
    if options == nil then
        -- print("Screenshot-nvim: No options provided")
        return
    end
    -- remove the trailing slash from the save_dir
    if options.save_dir ~= nil and options.save_dir:sub(-1) == "/" then
        options.save_dir = options.save_dir:sub(1, -2)
    end
    if vim.fn.isdirectory(options.save_dir) == 0 then
        error("Screenshot-nvim: Invalid save directory in the setup - " .. options.save_dir)
        return
    end

    for k, v in pairs(options) do
        config[k] = v
    end
end

return M
