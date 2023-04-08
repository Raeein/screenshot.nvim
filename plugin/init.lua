
if vim.g.screenshot_nvim_loaded then
	print("screenshot_nvim already loaded")
-- 	return
else
	print("screenshot_nvim loaded")
end

vim.g.screenshot_nvim_loaded = 1

local function get_visual_selection()
	print("get_visual_selection")
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

local function capture_selection(content)
    print("capture_selection")
    if 1 == 2 then
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
end

local function capture_all()
	local extention = vim.fn.expand("%:e")
	local curr_file = vim.fn.expand("%:t:r")
	local date = os.date("%Y-%m-%d_%H-%M-%S")
	local file_name = curr_file .. "_" .. date .. "." .. extention
    local path = vim.fn.expand("%:p")

    -- vim.api.nvim_command("echo 'hello world'")

    local current_dir = vim.fn.getcwd()
    -- local command = "carbon-now " .. path .. " -h -c -l " .. current_dir .. " -t " .. file_name
    -- print("Command is " .. command )
    -- vim.api.nvim_command(command)
    -- local res = vim.api.nvim_exec(command, true)
    -- local res = vim.fn.system(command)
    local carbon_command = "carbon-now " .. path .. " -h -c -l " .. current_dir .. " -t " .. file_name
    -- local command = {"carbon-now", path, "-h", "-c", "-l", current_dir, "-t", file_name}
    local command = "ls -la"
    local callbacks = {
        on_stdout = function(_, data)
            print("on_stdout")
            P(data)
        end,
        on_stderr = function(_, data)
            print("on_stderr")
            P(data)
        end,
        on_exit = function(_, data)
            print("on_exit")
            P(data)
        end,
    }
    local job_id = vim.fn.jobstart(command, callbacks)
    local job_ids = { job_id }
    vim.fn.chansend(job_id, "\n")
    vim.fn.jobwait(job_ids, 1000.0)
    vim.fn.jobstop(job_id)
end

local function my_callback(job_id, data, event)
  -- Print the output to the Neovim message area
  vim.api.nvim_out_write(data)
end

function Screenshot()
    if is_visual_mode() == false then
        print("normal mode")
        capture_all()
    elseif is_visual_mode() and is_text_selected() then
        print("visual mode")
        capture_selection()
    end
end



vim.g.mapleader = " "
vim.keymap.set({"v"}, "<leader>ss", ":lua Screenshot()<CR>", {noremap = true, silent = true})

vim.cmd("command! Screenshot lua Screenshot()")
vim.cmd("command! -range=% -nargs=0 Screenshot :'<,'>lua Screenshot()")
