-- enter vim file explorer
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- FloaTerm configuration
vim.keymap.set('n', "<leader>ft", ":FloatermNew --name=myfloat --height=0.8 --width=0.7 --autoclose=5 <CR> ")
vim.keymap.set('n', "t", ":FloatermToggle myfloat<CR>")
vim.keymap.set('t', "<Esc>", "<C-\\><C-n>:q<CR>")
vim.keymap.set('t', "<C-p>", "<C-\\><C-n>:FloatermPrev<CR>")
vim.keymap.set('t', "<C-n>", "<C-\\><C-n>:FloatermNext<CR>")
vim.keymap.set('t', "<C-x>", "<C-\\><C-n>:FloatermKill<CR>")

-- undo tree
vim.keymap.set("n", "<leader>u", ":UndotreeShow<CR>")

-- window navigation
vim.keymap.set("n", "<leader>nw", "<C-w>v")
vim.keymap.set("n", "<leader>w", "<C-w>w")

-- move blocks of code up or down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

--copy entire line
vim.keymap.set("n", "Y", "yg$")
-- keep cursor at beginning of line when joining lines
vim.keymap.set("n", "J", "mzJ`z")
-- keep cursor in center when half page scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- keep cursor in center when jumping to next match
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- paste from system clipboard
vim.keymap.set("x", "<leader>p", "\"_dP")

-- yank to system clipboard
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

-- delete to black hole register
vim.keymap.set("n", "<leader>d", "\"_d")
vim.keymap.set("v", "<leader>d", "\"_d")

-- stay in normal and add new line
vim.keymap.set("n", "<leader>o", "o<Esc>")
vim.keymap.set("n", "<leader>O", "O<Esc>")

-- allign ctrl c and esc
vim.keymap.set("n", "<C-c>", "<Esc>")

-- don't worry about this
vim.keymap.set("n", "Q", "<nop>")
-- This remap will not work until tmux is set up and the script is installed
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww ~/.local/scripts/tmux-sessionizer.sh<CR>")
--format all code in file
vim.keymap.set("n", "<leader>f", function()
    vim.lsp.buf.format()
end)

-- jest
vim.keymap.set("n", "<leader>tf", function()
    require('nvim-jest').test_file()
end)
vim.keymap.set("n", "<leader>ts", function()
    require('nvim-jest').test_single()
end)
vim.keymap.set("n", "<leader>js", function()
    require('nvim-jest').test_stop()
end)
vim.keymap.set("n", "<leader>js", ":JestStop<CR>")

-- navigate errors and locations
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- replace word under cursor
vim.keymap.set("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")
-- make file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
