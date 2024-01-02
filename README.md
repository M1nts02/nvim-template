# nvim-template

A neovim plugin for template

## Install

```lua
-- lazy.nvim
require("lazy").setup({
  {
    "M1nts02/nvim-template",
    cmd = {"Templ", "TemplAdd", "TemplDel"},
    opts = {
      templ_dir = vim.fn.stdpath("config") .. "/" .. "template",
      templ_register_file = vim.fn.stdpath("config") .. "/" .. "template.json",
    },
  },
})
```

## Configuration

```lua
-- default config
{
  templ_dir = vim.fn.stdpath("config") .. "/" .. "template"),
  templ_register_file = vim.fn.stdpath("config") .. "/" .. "template.json"),
}
```

## Example for register file

```json
{
  "launch(lldb)": {
    "target": ".vscode/launch.json",
    "template": "launch_lldb.json"
  },
  "stylua": {
    "target": "stylua.toml",
    "template": "stylua.toml"
  },
}
```

## Usage

```vim
:Templ <template>
:Templ <template> <target>
:TemplAdd <template>
:TemplDel <template1> <template2> ...
```
