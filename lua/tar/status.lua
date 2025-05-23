local M = {}

--- @see https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md#lsp
M.Navic = function()
  return {
    condition = function()
      return require('nvim-navic').is_available()
    end,
    static = {
      --- Type highlight map
      type_hl = {
        File = 'Directory',
        Module = '@include',
        Namespace = '@namespace',
        Package = '@include',
        Class = '@structure',
        Method = '@method',
        Property = '@property',
        Field = '@field',
        Constructor = '@constructor',
        Enum = '@field',
        Interface = '@type',
        Function = '@function',
        Variable = '@variable',
        Constant = '@constant',
        String = '@string',
        Number = '@number',
        Boolean = '@boolean',
        Array = '@field',
        Object = '@type',
        Key = '@keyword',
        Null = '@comment',
        EnumMember = '@field',
        Struct = '@structure',
        Event = '@keyword',
        Operator = '@operator',
        TypeParameter = '@type',
      },
      --- bit operation dark magic, see below...
      enc = function(line, col, winnr)
        return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr)
      end,
      --- line: 16 bit (65535); col: 10 bit (1023); winnr: 6 bit (63)
      dec = function(c)
        local line = bit.rshift(c, 16)
        local col = bit.band(bit.rshift(c, 6), 1023)
        local winnr = bit.band(c, 63)
        return line, col, winnr
      end,
    },
    init = function(self)
      local data = require('nvim-navic').get_data() or {}
      local children = {}
      --- create a child for each level
      for i, d in ipairs(data) do
        --- encode line and column numbers into a single integer
        local pos = self.enc(d.scope.start.line, d.scope.start.character, self.winnr)
        local child = {
          {
            provider = d.icon,
            hl = self.type_hl[d.type],
          },
          {
            --- escape `%`s (elixir) and buggy default separators
            provider = d.name:gsub('%%', '%%%%'):gsub('%s*->%s*', ''),
            --- highlight icon only or location name as well
            --- hl = self.type_hl[d.type],

            on_click = {
              --- pass the encoded position through minwid
              minwid = pos,
              callback = function(_, minwid)
                --- decode
                local line, col, winnr = self.dec(minwid)
                vim.api.nvim_win_set_cursor(vim.fn.win_getid(winnr), { line, col })
              end,
              name = 'heirline_navic',
            },
          },
        }
        --- add a separator only if needed
        if #data > 1 and i < #data then
          table.insert(child, {
            provider = ' > ',
            hl = { fg = 'bright_fg' },
          })
        end
        table.insert(children, child)
      end
      --- instantiate the new child, overwriting the previous one
      self.child = self:new(children, 1)
    end,
    {
      provider = ' ',
    },
    {
      --- evaluate the children containing navic components
      provider = function(self)
        return self.child:eval()
      end,
      hl = { fg = 'gray' },
      update = 'CursorMoved',
    },
  }
end

M.FileType = function(utils)
  return {
    provider = function()
      return ' ' .. string.upper(vim.bo.filetype) .. ' '
    end,
    hl = { fg = utils.get_highlight('Type').fg, bold = true },
  }
end

M.ScrollBar = function()
  return {
    static = { sbar = { '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█' } },
    { provider = ' %P ' },
    {
      provider = function(self)
        local curr_line = vim.api.nvim_win_get_cursor(0)[1]
        local lines = vim.api.nvim_buf_line_count(0)
        local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
        return string.rep(self.sbar[i], 2)
      end,
      hl = { fg = 'pink' },
    },
    { provider = ' ' },
  }
end

M.Git = function(conditions)
  return {
    condition = conditions.is_git_repo,

    init = function(self)
      self.status_dict = vim.b.gitsigns_status_dict
      self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
    end,

    hl = { fg = 'orange' },

    { -- git branch name
      provider = function(self)
        return ' ' .. self.status_dict.head
      end,
      hl = { bold = true },
    },
    {
      provider = function(self)
        local count = self.status_dict.added or 0
        return count > 0 and ('+' .. count)
      end,
      -- hl = { fg = 'gray' },
    },
    {
      provider = function(self)
        local count = self.status_dict.removed or 0
        return count > 0 and ('-' .. count)
      end,
      -- hl = { fg = 'gray' },
    },
    {
      provider = function(self)
        local count = self.status_dict.changed or 0
        return count > 0 and ('~' .. count)
      end,
      hl = { fg = 'gray' },
    },
  }
end

return M
