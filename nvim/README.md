# Neovim Config

Small, custom Neovim setup using `lazy.nvim`, LSP, completion, Telescope, Treesitter, `nvim-tree`, Git signs, and safe format-on-save.

## Requirements

- Neovim 0.11+; 0.12+ is recommended for the current LSP APIs.
- `git` for plugin installation and Git-aware Telescope/Gitsigns features.
- `ripgrep` (`rg`) for Telescope live grep.
- `7z` or `unzip` so Mason can extract packages reliably on Windows.
- `node`/`npm` for Mason-managed web, JSON, YAML, TypeScript, and Pyright language servers.
- A JDK for Java language-server support.
- Optional formatter executables for `conform.nvim`: `stylua`, `prettier`, `black`, `clang-format`, and `google-java-format`.
- Treesitter parser installs are explicit to avoid noisy startup failures. Use `:TSInstall c cpp css html java javascript json lua markdown markdown_inline matlab python vim vimdoc query tsx typescript yaml`.

## Useful Commands

- `:Lazy` manages plugins.
- `:Mason` manages language servers.
- `:ConformInfo` shows formatter status.
- `:FormatDisable`, `:FormatEnable`, and `:FormatToggle` control format-on-save.

Use `!` with the format commands for global scope, for example `:FormatDisable!`. Without `!`, they apply to the current buffer.
