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

  -- get the differences between the current buffer and the last saved version
  local diff = vim.diff(last_saved_lines, current_lines)

  -- loop through the differences and add them to the changes table
  for _, d in ipairs(diff) do
    if d[1] == 1 and d[3] == #d[4] then
      -- an entire line was added
      table.insert(changes, d[1] .. '+: ' .. d[4][1])
    elseif d[1] == #last_saved_lines and d[2] == 1 and d[4] == "" then
      -- an entire line was deleted
      table.insert(changes, d[1] .. '-: ' .. last_saved_lines[d[1]])
    else
      -- some characters were changed in the line
      local line_num = d[1]
      local start_col = d[2]
      local end_col = d[2] + #d[4] - 1
      local old_line = last_saved_lines[line_num]
      local new_line = current_lines[line_num]
      local old_chars = string.sub(old_line, start_col, end_col)
      local new_chars = string.sub(new_line, start_col, end_col)
      local old_chars_iter = string.gmatch(old_chars, ".")
      local new_chars_iter = string.gmatch(new_chars, ".")

      while true do
        local old_char = old_chars_iter()
        local new_char = new_chars_iter()

        if old_char == nil and new_char == nil then
          -- we've reached the end of the line
          break
        elseif old_char == nil then
          -- a new character was added to the end of the line
          table.insert(changes, line_num .. ',' .. line_num .. ':' .. ' +' .. new_char)
        elseif new_char == nil then
          -- a character was deleted from the end of the line
          table.insert(changes, line_num .. ',' .. line_num .. ':' .. ' -' .. old_char)
        elseif old_char ~= new_char then
          -- a character was changed in the line
          table.insert(changes, line_num .. ',' .. line_num .. ':' .. ' ' .. old_char .. '->' .. new_char)
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

