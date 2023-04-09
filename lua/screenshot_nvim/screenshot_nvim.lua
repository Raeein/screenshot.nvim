local M = {}

local command = require("screenshot_nvim.command")
local config = require("screenshot_nvim.config")

function M.setup(options)
    config.setup(options)
end

M.setup({
    clipboard = true,
    save_screenshot = false,
    -- save_dir = "/home/username/Pictures/Screenshots",
    save_dir = "/Users/raeeinbagheri/Desktop/"
})


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

-- local function capture_selection_to_file()
--     local content = get_visual_selection()
--     if content == nil then
--         return
--     end
--     print("capture_selection")
--     if 1 == 1 then
--         return
--     end
--
--     local extention = vim.fn.expand("%:e")
--     local curr_file = vim.fn.expand("%:t:r")
--     local date = os.date("%Y-%m-%d_%H-%M-%S")
--     local file_name = curr_file .. "_" .. date .. "." .. extention
--
--     local current_dir = vim.fn.getcwd()
--     local file_path = current_dir .. "/" .. file_name
--     local file = io.open(file_path, "w")
--
--     file:write(content)
--     file:close()
--     print("Saved to: " .. file_path)
-- end

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

-- local function get_visual_selection()
--     -- check if mark has been set
--     if vim.fn.getpos("'<")[1] == 0 then
--         print("No text selected")
--         return nil
--     end
--
--     local s_start = vim.fn.getpos("'<")
--     local s_end = vim.fn.getpos("'>")
--     local n_lines = math.abs(s_end[2] - s_start[2]) + 1
--     local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
--     lines[1] = string.sub(lines[1], s_start[3], -1)
--     if n_lines == 1 then
--         lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
--     else
--         lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
--     end
--     local selection = table.concat(lines, '\n')
--     -- writeToFile(selection)
--     vim.api.nvim_command("echo 'hello world'")
--     return selection
-- end

-- local function is_visual_mode()
--     return vim.fn.mode() == "v" or vim.fn.mode() == "V" or vim.fn.mode() == ""
-- end
