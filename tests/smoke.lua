local function assert_eq(actual, expected, message)
  if actual ~= expected then
    error(string.format("%s: expected %s, got %s", message, vim.inspect(expected), vim.inspect(actual)))
  end
end

local function contains_sequence(list, sequence)
  for i = 1, #list - #sequence + 1 do
    local found = true
    for j = 1, #sequence do
      if list[i + j - 1] ~= sequence[j] then
        found = false
        break
      end
    end
    if found then
      return true
    end
  end
  return false
end

local notifications = {}
vim.notify = function(message, level)
  table.insert(notifications, { message = message, level = level })
end

local calls = {}
vim.system = function(cmd, opts, callback)
  table.insert(calls, { cmd = cmd, opts = opts })
  callback({ code = 0, stdout = "", stderr = "" })
  return {}
end

local screenshot = require("screenshot_nvim")
screenshot.setup({
  output = "clipboard",
  backend = {
    command = "true",
    timeout = 1000,
    extra_args = { "--test-flag" },
  },
})

assert_eq(vim.fn.exists(":ScreenshotBuffer"), 2, "ScreenshotBuffer command should exist")
assert_eq(vim.fn.exists(":ScreenshotSelection"), 2, "ScreenshotSelection command should exist")

vim.api.nvim_buf_set_name(0, vim.fn.tempname() .. ".lua")
vim.api.nvim_buf_set_lines(0, 0, -1, false, {
  "local value = 1",
  "print(value)",
})

vim.cmd("ScreenshotBuffer")
vim.wait(100, function()
  return #notifications > 0
end)

assert_eq(calls[1].cmd[1], "true", "buffer capture should use configured backend command")
assert(contains_sequence(calls[1].cmd, { "-c", "--test-flag" }), "clipboard capture should include clipboard flag and extra args")

notifications = {}
vim.cmd("1,2ScreenshotSelection")
vim.wait(100, function()
  return #notifications > 0
end)

assert(contains_sequence(calls[2].cmd, { "-s", "1", "-e", "2" }), "selection capture should include selected line range")

vim.fn.setpos("'<", { 0, 1, 1, 0 })
vim.fn.setpos("'>", { 0, 1, 1, 0 })
local no_selection_ok = screenshot.capture_selection({})
assert_eq(no_selection_ok, false, "empty selection should be rejected")

local invalid_ok, invalid_err = pcall(screenshot.setup, {
  output = "file",
})
assert_eq(invalid_ok, false, "invalid file output config should fail")
assert(tostring(invalid_err):match("save_dir"), "invalid file output should mention save_dir")
