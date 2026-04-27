local M = {}

local defaults = {
  output = "clipboard",
  save_dir = nil,
  filename_format = "%Y-%m-%d_%H-%M-%S",
  backend = {
    command = "carbon-now",
    timeout = 30000,
    extra_args = {},
  },
}

local state = vim.deepcopy(defaults)
local known_keys = {
  output = true,
  save_dir = true,
  filename_format = true,
  backend = true,
}
local known_backend_keys = {
  command = true,
  timeout = true,
  extra_args = true,
}

local function validate_known_keys(options)
  for key, value in pairs(options) do
    if not known_keys[key] then
      error("screenshot.nvim: unknown setup option `" .. key .. "`")
    end

    if key == "backend" and value ~= nil then
      if type(value) ~= "table" then
        error("screenshot.nvim: `backend` must be a table")
      end

      for backend_key, _ in pairs(value) do
        if not known_backend_keys[backend_key] then
          error("screenshot.nvim: unknown backend option `" .. backend_key .. "`")
        end
      end
    end
  end
end

local function trim_trailing_slash(path)
  return (path:gsub("[/\\]+$", ""))
end

local function normalize_save_dir(path)
  if path == nil or path == "" then
    return nil
  end

  local expanded = vim.fn.fnamemodify(vim.fn.expand(path), ":p")
  return trim_trailing_slash(expanded)
end

local function validate_backend(backend)
  if type(backend.command) ~= "string" or backend.command == "" then
    error("screenshot.nvim: `backend.command` must be a non-empty string")
  end

  if type(backend.timeout) ~= "number" or backend.timeout <= 0 then
    error("screenshot.nvim: `backend.timeout` must be a positive number")
  end

  if type(backend.extra_args) ~= "table" then
    error("screenshot.nvim: `backend.extra_args` must be a list of strings")
  end

  for _, arg in ipairs(backend.extra_args) do
    if type(arg) ~= "string" then
      error("screenshot.nvim: `backend.extra_args` must only contain strings")
    end
  end
end

local function validate(config)
  if type(config.output) ~= "string" then
    error("screenshot.nvim: `output` must be a string")
  end

  if config.output ~= "clipboard" and config.output ~= "file" then
    error("screenshot.nvim: `output` must be either `clipboard` or `file`")
  end

  if type(config.filename_format) ~= "string" or config.filename_format == "" then
    error("screenshot.nvim: `filename_format` must be a non-empty string")
  end

  if config.output == "file" then
    if config.save_dir == nil then
      error("screenshot.nvim: `save_dir` is required when `output = \"file\"`")
    end

    if vim.fn.isdirectory(config.save_dir) == 0 then
      error("screenshot.nvim: `save_dir` does not exist: " .. config.save_dir)
    end
  end

  validate_backend(config.backend)
end

function M.get()
  return vim.deepcopy(state)
end

function M.setup(options)
  if options ~= nil and type(options) ~= "table" then
    error("screenshot.nvim: setup options must be a table")
  end

  validate_known_keys(options or {})

  local merged = vim.tbl_deep_extend("force", vim.deepcopy(defaults), options or {})
  merged.save_dir = normalize_save_dir(merged.save_dir)

  validate(merged)

  state = merged
  return M.get()
end

function M.defaults()
  return vim.deepcopy(defaults)
end

return M
