vim.opt.runtimepath:append(vim.fn.getcwd())
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.cmd("set shadafile=NONE")
vim.cmd("runtime plugin/init.lua")
