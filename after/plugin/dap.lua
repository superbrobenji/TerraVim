local dap = require('dap')

vim.g.dotnet_build_project = function()
    local default_path = vim.fn.getcwd() .. '/'
    if vim.g['dotnet_last_proj_path'] ~= nil then
        default_path = vim.g['dotnet_last_proj_path']
    end
    local path = vim.fn.input('Path to your *proj file', default_path, 'file')
    vim.g['dotnet_last_proj_path'] = path
    local cmd = 'dotnet build -c Debug ' .. path .. ' > /dev/null'
    print('')
    print('Cmd to execute: ' .. cmd)
    local f = os.execute(cmd)
    if f == 0 then
        print('\nBuild: ✔️ ')
    else
        print('\nBuild: ❌ (code: ' .. f .. ')')
    end
end

vim.g.dotnet_get_dll_path = function()
    local request = function()
        return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
    end

    if vim.g['dotnet_last_dll_path'] == nil then
        vim.g['dotnet_last_dll_path'] = request()
    else
        if vim.fn.confirm('Do you want to change the path to dll?\n' .. vim.g['dotnet_last_dll_path'], '&yes\n&no', 2) == 1 then
            vim.g['dotnet_last_dll_path'] = request()
        end
    end

    return vim.g['dotnet_last_dll_path']
end

local config = {
  {
    type = "coreclr",
    name = "launch - netcoredbg",
    request = "launch",
    program = function()
        if vim.fn.confirm('Should I recompile first?', '&yes\n&no', 2) == 1 then
            vim.g.dotnet_build_project()
        end
        return vim.g.dotnet_get_dll_path()
    end,
  },
}

dap.configurations.cs = config
dap.configurations.fsharp = config


vim.api.nvim_create_user_command("RunScriptWithArgs", function(t)
	-- :help nvim_create_user_command
	local args = vim.split(vim.fn.expand(t.args), '\n')
	local approval = vim.fn.confirm(
		"Will try to run:\n    " ..
		vim.bo.filetype .. " " ..
		vim.fn.expand('%') .. " " ..
		t.args .. "\n\n" ..
		"Do you approve? ",
		"&Yes\n&No", 1
	)
	if approval == 1 then
		dap.run({
			type = vim.bo.filetype,
			request = 'launch',
			name = 'Launch file with custom arguments (adhoc)',
			program = '${file}',
			args = args,
		})
	end
end, {
	complete = 'file',
	nargs = '*'
})



vim.keymap.set("n", "<leader>dr", function() dap.run() end)
vim.keymap.set("n", "<leader>drr", function() dap.restart() end)
vim.keymap.set("n", "<leader>dq", function() dap.stop() end)
vim.keymap.set("n", "<leader>dcb", function() dap.clear_breakpoints() end)
vim.keymap.set("n", "<leader>db", function() dap.toggle_breakpoint() end)
vim.keymap.set("n", "<leader>dc", function() dap.continue() end)
vim.keymap.set("n", "<leader>dd", function() dap.step_over() end)
vim.keymap.set("n", "<leader>di", function() dap.step_into() end)
vim.keymap.set("n", "<leader>do", function() dap.step_out() end)
vim.keymap.set("n", "<leader>dl", function() dap.repl.open() end)
