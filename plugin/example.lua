
if vim.g.screenshot_nvim_loaded then
	print("screenshot_nvim already loaded")
-- 	return
else
	print("screenshot_nvim loaded")
end

vim.g.screenshot_nvim_loaded = 1


function getVisualSelection()
	print("getVisualSelection")
	local line_start = vim.fn.getpos("'<")[2]
	local line_end = vim.fn.getpos("'>")[2]
	local col_start = vim.fn.getpos("'<")[3]
	local col_end = vim.fn.getpos("'>")[3]
	local lines = vim.fn.getline(line_start, line_end)
	local selection = ""
	for i, line in ipairs(lines) do
		if i == 1 then
			selection = selection .. string.sub(line, col_start)
		elseif i == #lines then
			selection = selection .. "\n" .. string.sub(line, 1, col_end)
		else
			selection = selection .. "\n" .. line
		end
	end
	writeToFile(selection)
end


function writeToFile(content)
	local extention = vim.fn.expand("%:e")
	local curr_file = vim.fn.expand("%:t:r")
	local date = os.date("%Y-%m-%d_%H-%M-%S")
	local file_name = curr_file .. "_" .. date .. "." .. extention

	local current_dir = vim.fn.getcwd()
	local file_path = current_dir .. "/" .. file_name
	local file = io.open(file_path, "w")

	file:write(content)
	file:close()
end

vim.g.mapleader = " "
vim.keymap.set({"v"}, "<leader>ss", ":lua getVisualSelection()<CR>", {noremap = true, silent = true})

