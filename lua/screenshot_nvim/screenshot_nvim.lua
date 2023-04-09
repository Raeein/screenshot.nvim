local M = {}

local command = require("screenshot_nvim.command")
local config = require("screenshot_nvim.config")

function M.setup(options)
    config.setup(options)
end

function M.check_versions()

    local version = vim.fn.system("carbon-now --version")
    version = string.gsub(version, "^%s+", "")
    version = string.gsub(version, "%s+$", "")

    local minor, patch = vim.version().minor, vim.version().patch

    if not tostring(version) == "1.4.0" then
        -- print("Carbon version is not 1.4.0")
        print("Carbon version is not 1.4.0, it is: " .. tostring(version))
    end

    if not (minor == 8 and patch == 3) then
        print("Neovim version is not 0.8.3, it is: " .. minor .. "." .. patch)
    end
end

-- check_versions()


local function is_text_selected()

    local start_line = vim.fn.getpos("'<")[2]
    local end_line = vim.fn.getpos("'>")[2]
    local start_col = vim.fn.getpos("'<")[3]
    local end_col = vim.fn.getpos("'>")[3]

    if start_line == end_line and start_col == end_col then
        return false
    end
    return true
end

local function get_file_info()
    local info = {}
    local curr_file = vim.fn.expand("%:t:r")
    local date = os.date("%Y-%m-%d_%H-%M-%S")
    local file_name = curr_file .. "_" .. date
    local path = vim.fn.expand("%:p")

    local current_dir = vim.fn.getcwd()
    -- return current_dir, file_name, path
    info.current_dir = current_dir
    info.file_name = file_name
    info.path = path

    return info
end

local function capture_selection()

    local configs = config.get_default_options()

    local file_info = get_file_info()

    local options = {
        type = "selection",
        start_line = vim.fn.getpos("'<")[2],
        end_line = vim.fn.getpos("'>")[2],
        -- file info
        path = file_info.path,
        current_dir = file_info.current_dir,
        file_name = file_info.file_name,
        -- options
        save_dir = configs.save_dir,
        clipboard = configs.clipboard,
        save = configs.save_screenshot,
    }
    command.run(options)
end


local function capture_all()
    local configs = config.get_default_options()

    local file_info = get_file_info()

    local options = {
        type = "all",
        start_line = -1,
        end_line = -1,
        -- file info
        path = file_info.path,
        current_dir = file_info.current_dir,
        file_name = file_info.file_name,
        -- options
        save_dir = configs.save_dir,
        clipboard = configs.clipboard,
        save = configs.save_screenshot,
    }
    command.run(options)
end


-- Screenshot all the page
function M.SS()
    capture_all()
end

-- only screenshot the selected portion
function M.SSText()

    if is_text_selected() then
        capture_selection()
    else
        print("No text selected")
    end
end

return M
