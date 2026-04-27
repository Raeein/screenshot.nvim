if vim.g.loaded_screenshot_nvim == 1 then
  return
end

vim.g.loaded_screenshot_nvim = 1

require("screenshot_nvim.commands").setup()
