if vim.g.screenshot_nvim_loaded then
	print("screenshot_nvim already loaded")
-- 	return
else
	print("screenshot_nvim loaded")
end

vim.g.screenshot_nvim_loaded = 1

local function check_versions()

    local version = vim.fn.system("carbon-now --version")
    version = string.gsub(version, "^%s+", "")
    version = string.gsub(version, "%s+$", "")

    local minor, patch = vim.version().minor, vim.version().patch

    if not tostring(version) == "1.4.0" then
        print("Carbon version is not 1.4.0")
    end

    if not (minor == 8 and patch == 3) then
        print("Neovim version is not 0.8.3")
    end
end

check_versions()

local function get_visual_selection()
	print("get_visual_selection")
    -- check if mark has been set
    if vim.fn.getpos("'<")[1] == 0 then
        print("No text selected")
        return nil
    end

    local s_start = vim.fn.getpos("'<")
    local s_end = vim.fn.getpos("'>")
    local n_lines = math.abs(s_end[2] - s_start[2]) + 1
    local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
    lines[1] = string.sub(lines[1], s_start[3], -1)
    if n_lines == 1 then
        lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
    else
        lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
    end
    local selection = table.concat(lines, '\n')
    -- writeToFile(selection)
    vim.api.nvim_command("echo 'hello world'")
    return selection
end

local function is_visual_mode()
    return vim.fn.mode() == "v" or vim.fn.mode() == "V" or vim.fn.mode() == ""
end

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

local function capture_selection_to_file()
    local content = get_visual_selection()
    if content == nil then
        return
    end
    print("capture_selection")
    if 1 == 1 then
        return
    end

    local extention = vim.fn.expand("%:e")
    local curr_file = vim.fn.expand("%:t:r")
    local date = os.date("%Y-%m-%d_%H-%M-%S")
    local file_name = curr_file .. "_" .. date .. "." .. extention

    local current_dir = vim.fn.getcwd()
    local file_path = current_dir .. "/" .. file_name
    local file = io.open(file_path, "w")

    file:write(content)
    file:close()
    print("Saved to: " .. file_path)
end

local function capture_selection_to_clipboard()
    local path = vim.fn.expand("%:p")
    print("Path is: " .. path)

    local start_line = vim.fn.getpos("'<")[2]
    local end_line = vim.fn.getpos("'>")[2]

    print("capture_selection_to_clipboard")
    print("start_line: " .. start_line)
    print("end_line: " .. end_line)

    local command = "carbon-now " .. path .. " -h -c -s " .. start_line .. " -e " .. end_line
    local callbacks = {
        -- standard out callbac
        on_stdout = function(_, data)
            if (#data == 0) or (#data == 1 and data[1] == "") then
                print("Failed to capture")
            end
        end,
        -- standard error callback
        on_stderr = function(_, data)
            P(data)
        end,
        detach = true,
        stdout_buffered = true,
        stderr_buffered = true,
    }

    local job_id = vim.fn.jobstart(command, callbacks)

    if job_id == 0 then
        print("Received invalid arguments")
    elseif job_id == -1 then
        print("cmd is not an executable")
    end

    local job_ids = { job_id }
    local timeout = 1000 * 10
    vim.fn.chansend(job_id, "\n")
    vim.fn.jobwait(job_ids, timeout)
    vim.fn.jobstop(job_id)

end


local function capture_all()
	local extention = vim.fn.expand("%:e")
	local curr_file = vim.fn.expand("%:t:r")
	local date = os.date("%Y-%m-%d_%H-%M-%S")
	local file_name = curr_file .. "_" .. date .. "." .. extention
    local path = vim.fn.expand("%:p")

    local current_dir = vim.fn.getcwd()
    local carbon_command = "carbon-now " .. path .. " -h -c -l " .. current_dir .. " -t " .. file_name
    -- local command = {"carbon-now", path, "-h", "-c", "-l", current_dir, "-t", file_name}
    -- local command = "ls -la"
    local command = carbon_command
    local callbacks = {
        -- standard out callbac
        on_stdout = function(_, data)
            if (#data == 0) or (#data == 1 and data[1] == "") then
                print("Failed to capture")
            end
        end,
        -- standard error callback
        on_stderr = function(_, data)
            P(data)
        end,
        detach = true,
        stdout_buffered = true,
        stderr_buffered = true,
    }

    local job_id = vim.fn.jobstart(command, callbacks)

    if job_id == 0 then
        print("Received invalid arguments")
    elseif job_id == -1 then
        print("cmd is not an executable")
    end

    local job_ids = { job_id }
    local timeout = 1000 * 10
    vim.fn.chansend(job_id, "\n")
    vim.fn.jobwait(job_ids, timeout)
    vim.fn.jobstop(job_id)
end

-- Screenshot all the page
function SS()
    print("Capturing all the page")
    capture_all()
end

-- only screenshot the selected portion
function SSText()

    if is_text_selected() then
        capture_selection_to_clipboard()
    else
        print("No text selected")
    end
end


vim.g.mapleader = " "
vim.keymap.set({"v"}, "<leader>ss", ":lua SS()<CR>", {noremap = true, silent = true})

vim.cmd("command! SS lua SS()")
vim.cmd("command! -range=% -nargs=0 SSText :'<,'>lua SSText()")
