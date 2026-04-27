local M = {}

function M.run(command, args, opts, callback)
  local argv = { command }
  vim.list_extend(argv, args)

  return vim.system(argv, {
    text = true,
    timeout = opts.timeout,
  }, function(result)
    vim.schedule(function()
      callback(result)
    end)
  end)
end

return M
