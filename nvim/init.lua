-- 基础设置
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true          -- 显示行号
vim.opt.tabstop = 2            -- Tab 显示为2个空格
vim.opt.shiftwidth = 2         -- 自动缩进时用2个空格
vim.opt.expandtab = true       -- 将 Tab 转换为空格
vim.opt.cursorline = true      -- 高亮当前行
vim.opt.relativenumber = true
vim.o.timeoutlen = 600  -- 从默认 1000ms 缩短到 300ms

-- 安装 Lazy.nvim 插件管理器
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", 
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 在这里添加你的插件
require("lazy").setup({
   -- 紫色主题：tokyonight
  {
    "folke/tokyonight.nvim",
    config = function()
      require("tokyonight").setup({
        style = "night",  -- 深紫色主题
      })
      vim.cmd.colorscheme("tokyonight")
    end
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      -- 你的 Flash 配置...
    },
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash Jump",
      },
    },
  },
  
  -- 添加平滑滚动插件
--   {
--     "karb94/neoscroll.nvim",
--     event = "VeryLazy",
--     config = function()
--       require("neoscroll").setup({
--         -- 每次滚动的时间（毫秒）
--         duration_multiplier = 0.3,     -- 全局速度乘数，默认1.0
--         
--         -- 各种滚动方式的时间（毫秒）
--         -- 你可以单独为每种滚动设置不同时长
--         easing = "quadratic",           -- 动画曲线：linear, quadratic, cubic, quartic, quint, circular, sine
--         
--         -- 更精细的时间控制（毫秒）
--         mappings = {
--           -- 逐行滚动
--           "<C-u>", "<C-d>",             -- 半屏滚动
--           "<C-b>", "<C-f>",             -- 全屏滚动
--           "zt", "zz",                   -- 居中滚动
-- 
--         },
--         
--             
--         -- 性能相关
--         hide_cursor = false,              -- 滚动时隐藏光标（更平滑）
--         stop_eof = true,                 -- 滚动到文件尾时停止动画
--         respect_scrolloff = true,        -- 尊重 scrolloff 设置
--         cursor_scrolls_alone = true,     -- 光标是否跟随滚动
--         
--         -- 性能优化
--         performance_mode = false,         -- 性能模式，禁用一些效果换取流畅度
--         post_hook = function() vim.cmd('normal! zz') end,
--       })
--     end
--   },

  -- 文件树插件 
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 35,
        },
        -- 正确的映射配置位置
        actions = {
          open_file = {
            quit_on_open = false,  -- 打开文件后不自动退出文件树
          },
        },
        -- update_focused_file 应该在这里面
        update_focused_file = {
          enable = true,      -- 启用此功能
          update_root = true, -- 同时更新文件树的根目录
          update_cwd = true,  -- 更新 Neovim 的当前工作目录
        },
      })
      
      -- 启动时自动打开文件树
      -- vim.api.nvim_create_autocmd({ "VimEnter" }, {
      --     callback = function(data)
      --         -- 延迟打开确保界面稳定
      --         vim.defer_fn(function()
      --             local is_dir = vim.fn.isdirectory(data.file) == 1
      --             if is_dir then
      --                 vim.cmd.cd(data.file)
      --             end
      --             -- 打开文件树但不聚焦
      --             require("nvim-tree.api").tree.open({ focus = false })
      --             
      --             -- 关键添加：立即切换焦点到编辑窗口
      --             vim.defer_fn(function()
      --                 vim.cmd('wincmd l')  -- 切换到右侧窗口（通常是编辑区域）
      --             end, 10)
      --         end, 50)
      --     end,
      -- })
      
      -- 在文件树打开后设置快捷键
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "NvimTree",
        callback = function()
          -- 使用 nvim-tree 的 API 来设置映射
          local api = require("nvim-tree.api")
          vim.keymap.set('n', 'l', api.node.open.edit, { buffer = true, desc = "Open" })
          vim.keymap.set('n', 'h', api.node.navigate.parent_close, { buffer = true, desc = "Close" })
          vim.keymap.set('n', '<CR>', api.node.open.edit, { buffer = true, desc = "Open" })
        end,
      })
      
    end
  },  

  -- 语法高亮增强
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "javascript", "typescript", "html", "css", "json", "lua" },
        highlight = { enable = true },
      })
    end
  },
  
  -- 状态栏
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({ options = { theme = "tokyonight" } })
    end
  }
},
{
  rocks = {
    enabled = false,  -- 完全禁用 luarocks 支持
  }
})

-- 键位映射
vim.keymap.set('i', 'jj', '<Esc>', {desc = "退出编辑模式"})
vim.keymap.set('v', 'jk', '<Esc>', {desc = "退出可视模式"})

vim.keymap.set('n', 'H', '^', { desc = "普通模式下跳转到行首" })
vim.keymap.set('o', 'H', '^', { desc = "字符模式下跳转到行首" })
vim.keymap.set('v', 'H', '^', { desc = "可视模式下跳转到行首" })
vim.keymap.set('n', 'L', '$', { desc = "普通模式下跳转到行尾" })
vim.keymap.set('o', 'L', '$', { desc = "字符模式下跳转到行首" })
vim.keymap.set('v', 'L', '$', { desc = "可视模式下跳转到行首" })

vim.keymap.set("n", "<Leader>w", ":w<CR>", { desc = "保存" })
vim.keymap.set("n", "<Leader>q", ":q<CR>", { desc = "退出" })
vim.keymap.set("n", "<Leader>wq", ":wq<CR>", { desc = "保存并退出" })

vim.keymap.set("n", "<A-j>", "g,zz", { desc = "跳转到下一个修改处" })
vim.keymap.set("n", "<A-k>", "g;zz", { desc = "跳转到上一个修改处" })

-- 所有滚动命令都让光标居中
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = "向下翻页后居中" })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = "向上翻页后居中" })
vim.keymap.set('n', '<C-f>', '<C-f>zz', { desc = "向下翻页后居中" })
vim.keymap.set('n', '<C-b>', '<C-b>zz', { desc = "向上翻页后居中" })
-- 搜索时也让结果居中
vim.keymap.set('n', 'n', 'nzz', { desc = "搜索结果向下查找居中" })
vim.keymap.set('n', 'N', 'Nzz', { desc = "搜索结果向上查找居中" })
vim.keymap.set('n', '*', '*zz', { desc = "当前单词(全词匹配)向下搜索后居中" })
vim.keymap.set('n', '#', '#zz', { desc = "当前单词(全词匹配)向上搜索后居中" })
vim.keymap.set('n', 'g*', 'g*zz', { desc = "当前单词(部分匹配)向下搜索后居中" })

-- 搜索模式
vim.keymap.set("n", "<Leader>f", "/", { desc = "向下搜索(全词匹配)" })
vim.keymap.set("n", "<Leader>F", "/", { desc = "向上搜索(全词匹配)" })

-- 打开和关闭文件树
vim.keymap.set('n', '<leader>e', function()
    require('nvim-tree.api').tree.toggle({ focus = true })
end, { desc = "切换文件树" })
-- 聚焦文件树
vim.keymap.set('n', '<leader>E', function()
    require('nvim-tree.api').tree.focus()
end, { desc = "聚焦文件树" })
 
-- Ctrl+space键进入命令模式
vim.keymap.set("n", "<C-space>", ":", { desc = "Ctrl+space键进入命令模式" })
