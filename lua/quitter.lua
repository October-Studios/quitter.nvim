-- Organization: October Studios
-- Developer: Cameron Howell (@crhowell3)
-- License: MIT
-- Source: https://github.com/October-Studios/quitter.nvim
local api = vim.api

function setup()
  -- get the changes made to the buffer since the last save
  local changes = vim.api.nvim_buf_get_changes(0, {since = 0})

  -- check if there are any changes in the buffer
  if changes == nil or #changes == 0 then
    -- if there are no changes, do nothing
    return
  end

  -- get the first change in the buffer
  local unsaved_changes = ""
  for _, change in ipairs(changes) do
    unsaved_changes = unsaved_changes .. change[2]
  end

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

