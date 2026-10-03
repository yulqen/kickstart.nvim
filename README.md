# My Neovim Config

Personal config based on [kickstart.nvim](KICKSTART-README.md) — single-file,
heavily commented, read `init.lua` top to bottom for the full story.

## Ground rules

- **No Nerd Fonts.** I use [Comic Code](https://www.kutilek.de/comic-code/) in
  the terminal. `vim.g.have_nerd_font = false` stays `false`, and any plugin
  that insists on icon glyphs is patched to use plain text (see below).

## Customizations vs upstream kickstart

| Change | Why |
|---|---|
| `vim.g.have_nerd_font = false` (upstream default) | No Nerd Font in use |
| blink.cmp: `completion.menu.draw.columns` shows text labels | Completion menu drew Nerd Font kind icons regardless of the flag |
| which-key: `icons.keys` overridden with plain text (`<Esc>`, `<BS>`, `SPC`...) | which-key renders special keys as Nerd Font glyphs even with `icons.mappings = false` |
| Python LSP enabled (`pyright`, `ruff`) | Python dev (see below) |
| conform: python = `ruff_organize_imports` + `ruff_format`, format-on-save on | Auto-format Python on save |
| Theme: **kanagawa** instead of tokyonight | `wave` (dark, high contrast) / `lotus` (warm paper light). `<Space>tt` toggles |

## Daily driving

- `<Space>` — which-key menu, shows everything, browse with prefixes
- `<Space>sk` — fuzzy search all keymaps (when in doubt)
- `<Space>sf` / `sg` / `sw` / `s.` / `sh` — files / grep / word / recent / help
- `<Space>sd` — diagnostics, `<Space><Space>` — buffers, `<Space>/` — fuzzy search in buffer
- `<Space>f` — format buffer, `<Space>q` — diagnostics to quickfix
- `<C-h/j/k/l>` — move between splits; `<Esc>` clears search highlight
- LSP: `grd` definition, `grr` references, `gri` implementations, `gO` symbols, `gra` code action
- Insert mode completion: `<C-space>` open, `<C-n>/<C-p>` select, `<C-y>` accept, `<C-e>` dismiss, `<C-k>` signature

## Python

- **pyright** — LSP: completion, hover, go-to-def, type checking
- **ruff** — LSP diagnostics + quick fixes, and formatter/import sorter via conform
- Virtualenvs: launch nvim from an activated venv, or add a `pyrightconfig.json`
  in the project root so pyright resolves imports
- Format on save is enabled for python; `<Space>f` formats manually

## Language support roadmap

Enabled servers live in the `servers` table in `init.lua`; mason auto-installs
them on next start. Status:

- [x] **Python** — pyright + ruff (done)
- [x] **Markdown** — `marksman` LSP; `prettierd` formatter (done)
- [x] **Django (python side)** — covered by pyright + ruff (done)
- [x] **Django templates** — `htmldjango` filetype detection (see the
      autocmd in `init.lua`: `templates/` dirs, `*.jinja*`, `*.djhtml`);
      HTML LSP attached to `htmldjango`; `djlint` formatter (done)
- [x] **JavaScript** — `ts_ls` LSP; `prettierd` formatter (done; needs `npm`)
- [x] **Clojure/ClojureScript** — `clojure_lsp` + `cljstyle` (on PATH) +
      [conjure](https://github.com/Olical/conjure) for connected REPL dev
      (done; needs the `clojure` CLI). Workflow: start a REPL
      (`clj -M:dev` / `npx shadow-cljs watch app`), open a `.clj`/`.cljs`
      file, evaluate with `<Space>ee` (form) / `<Space>eb` (buffer);
      `<Space>lS` opens the log split. Docs: `:help conjure`
      - shadow-cljs projects: `:ConjureShadowSelect <build>` (e.g. `diary`)
        after connecting, or evals land in the JVM clj session
        (`No such namespace: js` is the tell)
      - shadow-cljs dashboard: http://localhost:9630; the app itself is
        served by Django (runserver, `/diary/`) — the open browser tab is
        the JS runtime evals need
      - conjure session chords are rebound (`sF`/`sC`/`sN`/`sS`) so the
        global `<Space>s` search group keeps working in clojure buffers
- [ ] **Java** — deferred. Plan: `jdtls` via
      [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls) rather than
      plain lspconfig (projects/workspaces need it); heaviest setup of the
      lot

## See also

- Upstream kickstart docs: [KICKSTART-README.md](KICKSTART-README.md)
- Everything in `init.lua` is commented — the file is meant to be read
