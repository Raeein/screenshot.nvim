local M = {}

local function create_command(name, rhs, opts)
  pcall(vim.api.nvim_del_user_command, name)
  vim.api.nvim_create_user_command(name, rhs, opts)
end

function M.setup()
  create_command("ScreenshotBuffer", function()
    require("screenshot_nvim").capture_buffer()
  end, {
    desc = "Generate a screenshot of the current buffer",
  })

  create_command("ScreenshotSelection", function(args)
    require("screenshot_nvim").capture_selection({
      has_range = args.range > 0,
      line1 = args.line1,
      line2 = args.line2,
    })
  end, {
    desc = "Generate a screenshot of the current visual selection",
    range = true,
  })
end

return M
