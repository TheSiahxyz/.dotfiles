return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
    "nvim-telescope/telescope.nvim",
    "epwalsh/pomo.nvim",
  },
  config = function()
    require("obsidian").setup({
      workspaces = {
        {
          name = "SI",
          path = "~/Obsidian/SI",
        },
      },
      notes_subdir = "/Resource/Unsorted notes",
      log_level = vim.log.levels.INFO,
      daily_notes = {
        folder = "Area/Journal/Daily",
        date_format = "%Y-%m-%d",
        alias_format = "%B %e, %Y",
        template = "nvim-todo-daily-template.md",
      },
      templates = {
        subdir = "Resource/Templates/Notes",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
        substitutions = {
          date_alias = function()
            return os.date("%B %-e, %Y")
          end,
          folder_name = function()
            local currentFilePath = vim.fn.expand("%:p:h")
            local _, _, currentFolderName = currentFilePath:find("([^/]+)$")
            currentFolderName = currentFolderName:gsub(" ", "-")
            return currentFolderName
          end,
        },
      },
      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },
      note_id_func = function(title)
        local suffix = ""
        if title ~= nil then
          suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        else
          for _ = 1, 4 do
            -- suffix = suffix .. string.char(math.random(65, 90))
            suffix = tostring(os.date("%Y-%m-%d"))
          end
        end
        -- return tostring(os.date("%Y-%M-%d")) .. "-" .. suffix
        -- return tostring(os.date("%Y-%m-%d"))
        return suffix
      end,
      disable_frontmatter = true,
      note_frontmatter_func = function(note)
        local currentDate = os.date("%B %d, %Y")
        -- local _, _, filename, parentPath = note.id:find("([^/]+)[^/]*$")
        local _, _, parentPath = note.id:find(".*/(.*)/[^/]*$")

        parentPath = parentPath or "unsorted_notes"
        note:add_alias(currentDate)
        -- note:add_tag(filename)
        note:add_tag(parentPath)

        local out = { id = os.date("%Y-%m-%d"), aliases = note.aliases, tags = note.tags }
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end

        return out
      end,
      follow_url_func = function(url)
        vim.fn.jobstart({ "open", url }) -- Mac OS
        -- vim.fn.jobstart({"xdg-open", url})  -- linux
      end,
      use_advanced_uri = false,
      open_app_foreground = true,
      finder = "telescope.nvim",
      finder_mappings = {},
      sort_by = "modified",
      sort_reversed = true,
      open_notes_in = "current",
      ui = {
        tick = 0,
        enable = true, -- set to false to disable all additional syntax features
        update_debounce = 200, -- update delay after a text change (in milliseconds)
        checkboxes = {
          [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
          ["x"] = { char = "", hl_group = "ObsidianDone" },
          [">"] = { char = "", hl_group = "ObsidianRightArrow" },
          ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
        },
        external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
        reference_text = { hl_group = "ObsidianRefText" },
        highlight_text = { hl_group = "ObsidianHighlightText" },
        tags = { hl_group = "ObsidianTag" },
        hl_groups = {
          ObsidianTodo = { bold = true, fg = "#f78c6c" },
          ObsidianDone = { bold = true, fg = "#89ddff" },
          ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
          ObsidianTilde = { bold = true, fg = "#ff5370" },
          ObsidianRefText = { underline = true, fg = "#c792ea" },
          ObsidianExtLinkIcon = { fg = "#c792ea" },
          ObsidianTag = { italic = true, fg = "#89ddff" },
          ObsidianHighlightText = { bg = "#75662e" },
        },
      },
      attachments = {
        img_folder = "assets/imgs", -- This is the default
        ---@param client obsidian.Client
        ---@param path Path the absolute path to the image file
        ---@return string
        img_text_func = function(client, path)
          local link_path
          local vault_relative_path = client:vault_relative_path(path)
          if vault_relative_path ~= nil then
            link_path = vault_relative_path
          else
            link_path = tostring(path)
          end
          local display_name = vim.fs.basename(link_path)
          return string.format("![%s](%s)", display_name, link_path)
        end,
      },
      yaml_parser = "native",
      mappings = {},
    })
  end,
  cmd = {
    "ObsidianOpen",
    "ObsidianNew",
    "ObsidianQuickSwitch",
    "ObsidianFollowLink",
    "ObsidianBacklinks",
    "ObsidianToday",
    "ObsidianYesterday",
    "ObsidianTomorrow",
    "ObsidianTemplate",
    "ObsidianSearch",
    "ObsidianWorkspace",
    "ObsidianPasteImg",
    "ObsidianRename",
    "ObsidianLink",
    "ObsidianLinkNew",
  },
  keys = {
    {
      mode = { "i", "n" },
      "gf",
      function()
        return require("obsidian").util.gf_passthrough()
      end,
      desc = "goto file",
      noremap = false,
      expr = true,
      buffer = true,
    },
    {
      mode = "n",
      "<leader>cb",
      function()
        return require("obsidian").util.toggle_checkbox()
      end,
      buffer = true,
      desc = "Check Box",
    },
    {
      mode = "n",
      "<leader>ono",
      function()
        local query = vim.fn.input("Enter query: ")
        if query and #query > 0 then
          vim.cmd("ObsidianOpen " .. query)
        end
      end,
      desc = "Open Note",
    },
    {
      mode = "n",
      "<leader>onn",
      function()
        local title = vim.fn.input("Enter title: ")
        if title and #title > 0 then
          vim.cmd("ObsidianNew " .. title)
        end
      end,
      desc = "New Note",
    },
    {
      mode = "n",
      "<leader>os",
      "<cmd> ObsidianQuickSwitch <CR>",
      desc = "Quick Switch",
    },
    {
      mode = "n",
      "<leader>o]",
      "<cmd> ObsidianFollowLink <CR>",
      desc = "Follow Link",
    },
    {
      mode = "n",
      "<leader>o[",
      "<cmd> ObsidianBacklinks <CR>",
      desc = "Back Link",
    },
    {
      mode = "n",
      "<leader>ont",
      function()
        local offset = vim.fn.input("Enter offset: ")
        if offset and #offset > 0 then
          vim.cmd("ObsidianToday " .. offset)
        else
          vim.cmd("ObsidianToday")
        end
      end,
      desc = "Today Note",
    },
    {
      mode = "n",
      "<leader>onh",
      "<cmd> ObsidianYesterday <cr>",
      desc = "Yesterday Note",
    },
    {
      mode = "n",
      "<leader>onl",
      "<cmd> ObsidianTomorrow <cr>",
      desc = "Tomorrow Note",
    },
    {
      mode = "n",
      "<leader>oti",
      "<cmd>ObsidianTemplate<cr>",
      desc = "Insert Templates",
    },
    {
      mode = "n",
      "<leader>onf",
      function()
        local note = vim.fn.input("Enter note: ")
        if note and #note > 0 then
          vim.cmd("ObsidianSearch " .. note)
        end
      end,
      desc = "Search Note",
    },
    {
      mode = "n",
      "<leader>ow",
      function()
        local name = vim.fn.input("Enter name: ")
        if name and #name > 0 then
          vim.cmd("ObsidianWorkspace " .. name)
        end
      end,
      desc = "Workspace Name",
    },
    {
      mode = "n",
      "<leader>opi",
      function()
        local image = vim.fn.input("Enter image: ")
        if image and #image > 0 then
          vim.cmd("ObsidianPasteImg " .. image)
        end
      end,
      desc = "Paste Image",
    },
    {
      mode = "n",
      "<leader>onr",
      function()
        local name = vim.fn.input("Enter name: ")
        if name and #name > 0 then
          vim.cmd("ObsidianRename " .. name)
        end
      end,
      desc = "Rename Note",
    },
    {
      mode = "v",
      "<leader>ol",
      function()
        local query = vim.fn.input("Enter query: ")
        if query and #query > 0 then
          vim.cmd("ObsidianLink " .. query)
        else
          vim.cmd("ObsidianLink")
        end
      end,
      desc = "Link Query",
    },
    {
      mode = "v",
      "<leader>onl",
      function()
        local note = vim.fn.input("Enter note: ")
        if note and #note > 0 then
          vim.cmd("ObsidianLinkNew " .. note)
        else
          vim.cmd("ObsidianLinkNew")
        end
      end,
      desc = "New Link Note",
    },
  },
}
