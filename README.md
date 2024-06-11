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
      git_info = true,
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
  author = "xxxx",
  email = "xxxxxx@xxx.com",
  git_info = false, -- get author and email from git config
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
  }
}
```

## Example for template file

- `${_AUTHOR_}`
- `${_EMAIL_}`
- `${_DATE()_}`: use `os.date()`

```lua
-- AUTHOR: ${_AUTHOR_}
-- EMAIL: ${_EMAIL_}
-- DATE: ${_DATE(%Y-%B-%A)_}
add_rules("mode.debug", "mode.release")
set_languages("c17", "c++17")

target "main"
set_kind "binary"
add_files "src/*.c"
```

## Usage

```vim
:Templ <template>
:Templ <template> <target>
:TemplAdd <template>
:TemplDel <template1> <template2> ...
```
