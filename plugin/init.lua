if vim.g.screenshot_nvim_loaded then
	-- print("screenshot_nvim already loaded")
	return
end

vim.g.screenshot_nvim_loaded = 1

-- change this to true if your are developing locally
local installed_locally = false


if installed_locally then
    vim.cmd("command! SS :lua require('lua.screenshot_nvim.screenshot_nvim').SS()")
    vim.cmd("command! -range=% -nargs=0 SSText :'<,'>lua require('lua.screenshot_nvim.screenshot_nvim').SSText()")
else
    vim.cmd("command! SS :lua require('screenshot_nvim.screenshot_nvim').SS()")
    vim.cmd("command! -range=% -nargs=0 SSText :'<,'>lua require('screenshot_nvim.screenshot_nvim').SSText()")
end


vim.g.mapleader = " "
vim.keymap.set({"v"}, "<leader>ss", ":lua SS()<CR>", {noremap = true, silent = true})
