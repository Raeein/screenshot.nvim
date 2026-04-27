local notify = require("screenshot_nvim.notify")
local process = require("screenshot_nvim.process")

local M = {}

local function normalize_result_message(result)
  local stderr = vim.trim(result.stderr or "")
  local stdout = vim.trim(result.stdout or "")

  if stderr ~= "" then
    return stderr
  end

  if stdout ~= "" then
    return stdout
  end

  return nil
end

function M.is_available(config)
  return vim.fn.executable(config.backend.command) == 1
end

function M.check(config)
  if M.is_available(config) then
    return true
  end

  notify.error(
    string.format(
      "Backend executable `%s` was not found. Install carbon-now-cli or set `backend.command`.",
      config.backend.command
    )
  )
  return false
end

function M.build_args(request, config)
  local args = {
    "-h",
    request.temp_path,
  }

  if config.output == "clipboard" then
    vim.list_extend(args, { "-c" })
  else
    vim.list_extend(args, {
      "-l",
      config.save_dir,
      "-t",
      request.file_name,
    })
  end

  if request.kind == "selection" then
    vim.list_extend(args, {
      "-s",
      tostring(request.start_line),
      "-e",
      tostring(request.end_line),
    })
  end

  vim.list_extend(args, config.backend.extra_args)

  return args
end

function M.run(request, config, done)
  local args = M.build_args(request, config)

  process.run(config.backend.command, args, {
    timeout = config.backend.timeout,
  }, function(result)
    if result.code == 0 then
      if config.output == "clipboard" then
        notify.info("Copied screenshot to clipboard")
      else
        notify.info(string.format("Saved screenshot to %s/%s.png", config.save_dir, request.file_name))
      end
    else
      local details = normalize_result_message(result)

      if details then
        notify.error("Screenshot failed: " .. details)
      else
        notify.error("Screenshot failed")
      end
    end

    done(result)
  end)
end

return M
