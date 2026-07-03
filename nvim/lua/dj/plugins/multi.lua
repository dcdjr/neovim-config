return {
  {
    "mg979/vim-visual-multi",
    -- Crucial: This plugin relies on Vimscript global variables set during startup.
    -- Loading it lazily via keys or events often breaks default keybindings like <C-n>.
    lazy = false,
    init = function()
      vim.g.VM_maps = {
        ['Find Under'] = '<C-d>',
        ['Find Subword Under'] = '<C-d>',
      }
    end,
  }
}
