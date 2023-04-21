-- Organization: October Studios
-- Developer: Cameron Howell (@crhowell3)
-- License: MIT
-- Source: https://github.com/October-Studios/quitter.nvim
local api = vim.api

local M

local function setup()
  -- Check if there are any unsaved changes
  if vim.fn.getbufvar('%', '&modified') == 1 then
    if vim.bo.diff ~= 1 then
      vim.cmd('diffthis')
    end
    -- Get the unsaved changes
    local changes = vim.fn.execute('diffget').gsub(vim.fn.line2byte('w$'), '')

    -- Create the pop-up message
    local message = 'Unsaved changes:\n' .. changes .. '\nDo you want to quit without saving?'

    -- Show the pop-up message and prompt the user to confirm quitting without saving
    local choice = vim.fn.confirm(message, '&Yes\n&No', 2)

    -- If the user chooses not to quit, return to normal mode
    if choice ~= 1 then
      vim.cmd('stopinsert')
    end
  end
end

M = {
  setup = setup,
}

return M
