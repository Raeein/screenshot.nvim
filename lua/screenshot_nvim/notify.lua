local M = {}

local TITLE = "screenshot.nvim"

function M.info(message)
  vim.notify(message, vim.log.levels.INFO, { title = TITLE })
end

function M.warn(message)
  vim.notify(message, vim.log.levels.WARN, { title = TITLE })
end

function M.error(message)
  vim.notify(message, vim.log.levels.ERROR, { title = TITLE })
end

return M
