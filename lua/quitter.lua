-- Organization: October Studios
-- Developer: Cameron Howell (@crhowell3)
-- License: MIT
-- Source: https://github.com/October-Studios/quitter.nvim
local api = vim.api

function setup()
  -- get the modified status of the buffer
  local modified = api.nvim_buf_get_option(0, "modified")

  -- check if the buffer has been modified
  if not modified then
    -- if there are no changes, do nothing
    return
  end

  -- get the changes made to the buffer
  local unsaved_changes = api.nvim_buf_get_lines(0, 0, -1, false)

  -- construct the message for the pop-up window
  local message = "Unsaved changes:\n\n" .. unsaved_changes .. "\n\nAre you sure you want to quit without saving?"

  -- define the buttons for the pop-up window
  local buttons = {"&Quit Without Saving", "&Cancel"}

  -- display the pop-up window and get the user's choice
  local choice = vim.fn.confirm(message, buttons, {default = 2})

  -- if the user chooses to quit without saving, exit Neovim
  if choice == 1 then
    vim.cmd('quit!')
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

