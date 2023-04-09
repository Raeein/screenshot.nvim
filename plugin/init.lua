if vim.g.screenshot_nvim_loaded then
	print("screenshot_nvim already loaded")
else
	return
end

vim.g.screenshot_nvim_loaded = 1

vim.cmd("command! SS :lua require('lua.screenshot_nvim.screenshot_nvim').SS()")
vim.cmd("command! -range=% -nargs=0 SSText :'<,'>lua require('lua.screenshot_nvim.screenshot_nvim').SSText()")

vim.g.mapleader = " "
vim.keymap.set({"v"}, "<leader>ss", ":lua SS()<CR>", {noremap = true, silent = true})
