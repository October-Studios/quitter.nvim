-- Organization: October Studios
-- Developer: Cameron Howell (@crhowell3)
-- License: MIT
-- Source: https://github.com/October-Studios/quitter.nvim
local api = vim.api

function setup()
  -- get the modified status of the buffer
  local modified = vim.fn.line('$') ~= 1 or vim.fn.getbufvar(vim.fn.bufnr(''), '&modified') ~= 0

  -- check if the buffer has been modified
  if not modified then
    -- if there are no changes, do nothing
    return
  end

  -- get the changes made to the buffer since the last save
  local current_lines = api.nvim_buf_get_lines(0, 0, -1, false)
  local last_saved_lines = vim.fn.readfile(vim.fn.expand('%:p'))
  local changes = {}

--  for i, line in ipairs(current_lines) do
--    if line ~= last_saved_lines[i] then
--      table.insert(changes, i .. ': ' .. line)
--    end
--  end

  -- get the differences between the current buffer and the last saved version
  local diff = vim.diff(table.concat(last_saved_lines, "\n"), table.concat(current_lines, "\n"))

  -- loop through the differences and add them to the changes table
  for _, d in ipairs(vim.split(diff, "\n")) do
    if d[1] == 1 and d[3] == #d[4] then
      -- an entire line was added
      table.insert(changes, d[1] .. '+: ' .. d[4][1])
    elseif d[1] == #last_saved_lines and d[2] == 1 and d[4] == "" then
      -- an entire line was deleted
      table.insert(changes, d[1] .. '-: ' .. last_saved_lines[d[1]])
    else
      -- some characters were changed in the line
      for i = 1, (d[4] and #d[4] or 0) do
        local char = string.sub(d[4], i, i)
        local old_char = last_saved_lines[d[1]][d[2] + i - 1]
        if char ~= old_char then
          table.insert(changes, d[1] .. ',' .. (d[1] + d[3] - 1) .. ': ' .. old_char .. ' -> ' .. char)
        end
      end
    end
  end

  local formatted = table.concat(changes, "\n")

  -- construct the message for the pop-up window
  local message = "Unsaved changes:\n\n" .. formatted .. "\n\nAre you sure you want to quit without saving?"

  -- display the pop-up window and get the user's choice
  local choice = vim.fn.confirm(message, "&Quit Without Saving\n&Cancel", 2)

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

