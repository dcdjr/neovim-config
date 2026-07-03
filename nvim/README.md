# nvim-clean-start

A deliberately small Neovim config for WezTerm + WSL.

## What this includes

- No plugins
- Your existing core keybinds
- Transparent-ish UI so WezTerm's Catppuccin/Mica setup shows through
- 2-space default indentation
- 4-space C/C++ and Python indentation
- corrected autocmds so switching buffers does not reset C++/Python indentation
- Terminal split helpers
- No autoformat-on-save
- No autopairs
- No LSP
- No completion
- No Telescope
- No file tree

This is the base layer. Add tools one at a time.

## Install

Backup your current config first:

```bash
mv ~/.config/nvim ~/.config/nvim.bak.$(date +%Y%m%d-%H%M%S)
mkdir -p ~/.config
cp -r nvim-clean-start ~/.config/nvim
```

Then open Neovim:

```bash
nvim
```

## Preserved core keybinds

- `<C-h/j/k/l>`: move between windows
- `<C-d>` / `<C-u>`: page down/up and center
- `<leader>t`: horizontal terminal
- `<leader>T`: vertical terminal
- `<leader>tc`: close terminal window
- `<leader>w`: write file
- `<leader>q`: quit window
- `<leader>x`: delete buffer
- `<C-Up/Down/Left/Right>`: resize windows
- `<S-h>` / `<S-l>`: previous/next buffer
- `<leader>uw`: toggle wrap
- `<leader>ur`: toggle relative numbers
- `<leader>uh`: toggle search highlight
- `<leader>uM`: remove Windows `^M` carriage returns
- `<Esc>`: clear search highlight
- `jk`: exit insert or terminal mode
- visual `<A-j>/<A-k>`: move selected text
- visual `p`: paste without yanking replaced text

## Recommended plugin order

Add these only when the base config feels stable:

1. lazy.nvim + Catppuccin
2. Telescope
3. Treesitter
4. LSP + completion
5. Gitsigns
6. Formatting
7. File tree, only if you still want it
