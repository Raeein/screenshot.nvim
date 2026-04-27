# screenshot.nvim

Generate polished code screenshots from inside Neovim with the `carbon-now` CLI.

## Requirements

- Neovim `0.10+`
- [`carbon-now-cli`](https://github.com/mixn/carbon-now-cli)

## Features

- Capture the current buffer with `:ScreenshotBuffer`
- Capture the current visual selection with `:ScreenshotSelection`
- Copy screenshots to the clipboard or save them to disk
- Work with unsaved and unnamed buffers through a temp-file workflow
- Validate setup early and surface actionable runtime errors

## Installation

### lazy.nvim

```lua
{
  "Raeein/screenshot.nvim",
  config = function()
    require("screenshot_nvim").setup()
  end,
}
```

### packer.nvim

```lua
use({
  "Raeein/screenshot.nvim",
  config = function()
    require("screenshot_nvim").setup()
  end,
})
```

## Usage

### Commands

- `:ScreenshotBuffer`
- `:ScreenshotSelection`

`ScreenshotSelection` is line-based because `carbon-now` accepts start and end lines, not column ranges. In practice that means a partial-line visual selection will capture the full selected lines.

### Lua API

```lua
local screenshot = require("screenshot_nvim")

screenshot.setup()
screenshot.capture_buffer()
screenshot.capture_selection()
```

## Configuration

### Defaults

```lua
require("screenshot_nvim").setup({
  -- "clipboard" or "file"
  output = "clipboard",

  -- required when output = "file"
  save_dir = nil,

  -- os.date format used in saved file names
  filename_format = "%Y-%m-%d_%H-%M-%S",

  backend = {
    -- carbon-now executable
    command = "carbon-now",

    -- timeout in milliseconds
    timeout = 30000,

    -- appended directly to the carbon-now argv list
    extra_args = {},
  },
})
```

### Save screenshots to disk

```lua
require("screenshot_nvim").setup({
  output = "file",
  save_dir = "~/Pictures/code-shots",
})
```

### Use a custom backend executable

```lua
require("screenshot_nvim").setup({
  backend = {
    command = "/opt/homebrew/bin/carbon-now",
  },
})
```

### Add extra `carbon-now` flags

```lua
require("screenshot_nvim").setup({
  backend = {
    extra_args = {
      "--headless",
    },
  },
})
```

## Configuration Reference

| Option | Type | Default | Notes |
| --- | --- | --- | --- |
| `output` | `string` | `"clipboard"` | Must be `"clipboard"` or `"file"` |
| `save_dir` | `string?` | `nil` | Required when `output = "file"` |
| `filename_format` | `string` | `"%Y-%m-%d_%H-%M-%S"` | Passed to `os.date()` |
| `backend.command` | `string` | `"carbon-now"` | Path or executable name |
| `backend.timeout` | `number` | `30000` | Timeout in milliseconds |
| `backend.extra_args` | `string[]` | `{}` | Appended directly to the backend argv |

Unknown setup keys are rejected, and `save_dir` is validated during setup when file output is enabled.

## Behavior Notes

- The plugin captures the current buffer by writing its contents to a temporary file before calling `carbon-now`. This keeps unsaved changes and unnamed buffers supported.
- Saved screenshots use a filename based on the current buffer name plus a timestamp.
- When the backend executable is missing, the plugin reports a clear error instead of failing silently.
- `:ScreenshotSelection` depends on a visual range. If no valid selection exists, the plugin warns and does nothing.

## Health Check

Run `:checkhealth screenshot_nvim` to verify:

- Neovim version support
- backend executable availability
- save-directory validity when file output is enabled

## Migration from the old plugin

- `:SS` was replaced by `:ScreenshotBuffer`
- `:SSText` was replaced by `:ScreenshotSelection`
- The old `clipboard` and `save_screenshot` config flags were replaced by `output = "clipboard"` or `output = "file"`
- The plugin no longer defines keymaps or mutates `mapleader`

## Tests

Run the smoke test with:

```sh
nvim --headless -u tests/minimal_init.lua -i NONE -c "lua dofile('tests/smoke.lua')" -c "qa!"
```
