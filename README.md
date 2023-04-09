## NOT READY FOR USE

# screenshot.nvim

Generate pretty screenshots of code without leaving the safe space of your terminal

# Requirments

- Neovim - preferably 0.8.3
- carbon-now (You can get it from [here](https://github.com/mixn/carbon-now-cli))

## Features
- Take screenshot of the current file (buffer yea ik) and copy it to your clipboard with :SS
- Take screenshot of the current highlighted text and copy it to your clipboard with :SSText

## Setup

- Only inlcude the options you want to change in the setup function
- Both clipboard and save_screenshot can not be true as carbon-now does not support it

```lua
require('Raeein/screenshot.nvim').setup({
        -- Save to clipboard or not: Boolean
        clipboard = false,
        -- Save the screen shot or not: Boolean
        save_screenshot = true,
        -- Save directory for the screnshot: String
        save_dir = "/Users/raeeinbagheri/Desktop/"
})
```

# Installation

With packer (Have to restart neovim after installing):

```lua
use 'Raeein/screenshot.nvim'
```
