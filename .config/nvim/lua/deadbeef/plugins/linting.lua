return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      javascript = { "eslint_d" },
      typescript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      svelte = { "eslint_d" },
      python = { "pylint" },
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_user_command("EslintFix", function()
      local bufnr = vim.api.nvim_get_current_buf()
      local file_path = vim.api.nvim_buf_get_name(bufnr)
      vim.fn.jobstart("eslint_d --fix " .. file_path, {
        on_exit = function()
          vim.api.nvim_buf_call(bufnr, function()
            vim.cmd("edit")
          end)
        end,
      })
    end, { desc = "Fix ESLint errors in the current file" })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
      command = "EslintFix",
    })

    vim.keymap.set("n", "<leader>l", function()
      lint.try_lint()
    end, { desc = "Trigger linting for current file" })
  end,
}
