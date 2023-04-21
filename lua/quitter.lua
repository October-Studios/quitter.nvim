-- Organization: October Studios
-- Developer: Cameron Howell (@crhowell3)
-- License: MIT
-- Source: https://github.com/October-Studios/quitter.nvim
local api = vim.api

function setup()
  local unsaved_changes = vim.fn.undotree()['seq_undo'][1]['changes']
  local message = "Unsaved changes:\n\n" .. unsaved_changes .. "\n\nAre you sure you want to quit without saving?"
  local buttons = {"&Quit Without Saving", "&Cancel"}

  -- display the pop-up message with unsaved changes
  local choice = vim.fn.confirm(message, buttons, {default = 2})

  -- if the user chooses to quit without saving, exit Neovim
  if choice == 1 then
    vim.cmd('qa!')
  end
end

local augroup = api.nvim_create_augroup('quitter', {clear = true})

api.nvim_create_autocmd('QuitPre', {
  pattern = '*',
  group = augroup,
  command = 'if &modified | call luaeval("setup()") | endif',
})

return {
  setup = setup,
}

