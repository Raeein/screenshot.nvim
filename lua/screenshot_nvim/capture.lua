local backend = require("screenshot_nvim.backend.carbon_now")
local config = require("screenshot_nvim.config")
local notify = require("screenshot_nvim.notify")

local M = {}

local function sanitize_filename_segment(value)
  local sanitized = value:gsub("[^%w%-_]+", "-"):gsub("%-+", "-"):gsub("^%-", ""):gsub("%-$", "")
  if sanitized == "" then
    return "untitled"
  end
  return sanitized
end

local function current_buffer_name()
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    return nil
  end
  return name
end

local function current_extension()
  local bufname = current_buffer_name()
  if bufname ~= nil then
    local extension = vim.fn.fnamemodify(bufname, ":e")
    if extension ~= "" then
      return extension
    end
  end

  local filetype = vim.bo.filetype
  if filetype ~= "" then
    return filetype
  end

  return "txt"
end

local function make_temp_path()
  return string.format("%s.%s", vim.fn.tempname(), current_extension())
end

local function make_file_name()
  local bufname = current_buffer_name()
  local stem = bufname and vim.fn.fnamemodify(bufname, ":t:r") or "untitled"
  local timestamp = os.date(config.get().filename_format)
  return string.format("%s_%s", sanitize_filename_segment(stem), timestamp)
end

local function write_temp_file(path)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local ok, err = pcall(vim.fn.writefile, lines, path)
  if not ok then
    error("screenshot.nvim: failed to write temp file: " .. tostring(err))
  end
end

local function cleanup_temp_file(path)
  if path == nil or path == "" then
    return
  end

  pcall(vim.fn.delete, path)
end

local function resolve_selection_range(options)
  if
    options.has_range
    and type(options.line1) == "number"
    and type(options.line2) == "number"
    and options.line1 > 0
    and options.line2 > 0
  then
    local start_line = math.min(options.line1, options.line2)
    local end_line = math.max(options.line1, options.line2)
    return start_line, end_line
  end

  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line = start_pos[2]
  local end_line = end_pos[2]
  local start_col = start_pos[3]
  local end_col = end_pos[3]

  if start_line == 0 or end_line == 0 then
    return nil
  end

  if start_line == end_line and start_col == end_col then
    return nil
  end

  return math.min(start_line, end_line), math.max(start_line, end_line)
end

local function build_request(kind, range_start, range_end)
  local temp_path = make_temp_path()
  write_temp_file(temp_path)

  return {
    kind = kind,
    temp_path = temp_path,
    file_name = make_file_name(),
    start_line = range_start,
    end_line = range_end,
  }
end

local function run_capture(request)
  local cfg = config.get()

  if not backend.check(cfg) then
    cleanup_temp_file(request.temp_path)
    return false
  end

  backend.run(request, cfg, function()
    cleanup_temp_file(request.temp_path)
  end)

  return true
end

function M.capture_buffer()
  return run_capture(build_request("buffer"))
end

function M.capture_selection(options)
  local start_line, end_line = resolve_selection_range(options or {})

  if start_line == nil or end_line == nil then
    notify.warn("No visual selection found")
    return false
  end

  return run_capture(build_request("selection", start_line, end_line))
end

return M
