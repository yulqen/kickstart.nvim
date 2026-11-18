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
| `mini.pairs` enabled | Auto-close brackets/quotes in insert mode (all filetypes) |
| **nvim-paredit** added | Structural editing for clojure/fennel/scheme/lisp (see below) |
| **Neogit** added (`<Space>gg`) | Magit-style git status/commit/branch/push UI |

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

## Git workflow

Three layers:

1. **Inline (gitsigns)** — hunks in the sign column: `]c`/`[c` navigate,
   `<Space>hs`/`hr` stage/reset hunk, `<Space>hb` blame, `<Space>hd` diff,
   `<Space>hq` hunks to quickfix.
2. **Neogit (`<Space>gg`)** — magit-style status buffer for commits, branches,
   push/pull, stash, rebase. `?` shows keys in any menu.
3. **Outside nvim** — lazygit is installed on the system for terminal use.

## Structural editing (Clojure & other lisps)

**Insert mode:** brackets auto-close (`(` → `()` via mini.pairs — `(`, `[`, `{`, `"` all work.

**nvim-paredit** (treesitter-based; active in clojure/fennel/scheme/lisp buffers):

| Keys | Action |
|---|---|
| `>)` / `<)` | Slurp / barf forwards (pull next element in, push last one out) |
| `<(` / `>(` | Slurp / barf backwards |
| `>e` / `<e` | Drag element right / left |
| `>p` / `<p` | Drag key-value pair right / left (maps, let bindings…) |
| `>f` / `<f` | Drag whole form right / left |
| `<Space>o` / `<Space>O` | Raise form / element (replace parent with it) |
| `<Space>@` | Splice (unwrap) form under cursor |
| `W` / `E` / `B` / `gE` | Jump to element head / tail / prev head / prev tail |
| `(` / `)` | Jump to parent form start / end, `T` top-level form head |
| `af` / `if` | Text object: around / inside form (`aF`/`iF` top-level) |
| `ae` / `ie` | Text object: around / inside element |

All the drag/slurp/barf keys are dot-repeatable (`.` repeats). Conjure chords
(`ee`, `eb`, `lS`, …) are unaffected — no overlaps.

## Setting up a new machine

The config is portable: git clone + a handful of system deps, everything
else self-installs on first launch.

1. **Back up any existing config** (if there was one):

   ```bash
   mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null
   mv ~/.local/share/nvim ~/.local/share/nvim.bak 2>/dev/null
   ```

2. **System dependencies** — Neovim >= 0.12, `git`, `gcc`/`make`,
   `ripgrep`, `fd`, `node`/`npm` (runs the TypeScript LSP),
   `python3-venv` (Mason's pip-based packages) and the `tree-sitter` CLI
   (nvim-treesitter `main` builds parsers with it). Add `xclip` /
   `wl-clipboard` only where a real X/Wayland session exists — on a
   headless box (no `DISPLAY`/`WAYLAND_DISPLAY`) the config hands
   clipboard duties to the terminal via OSC 52 instead:

   ```bash
   sudo apt install git build-essential ripgrep fd-find nodejs npm python3-venv xclip
   ```

   Distro packages are usually too old (Debian 13 still ships 0.10), so
   take the release tarball rather than `apt install neovim`:

   ```bash
   curl -sL -o /tmp/nvim.tar.gz \
     https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
   sudo tar xzf /tmp/nvim.tar.gz -C /opt
   sudo mv /opt/nvim-linux-x86_64 /opt/nvim
   sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
   ```

   `/usr/local/bin` comes before `/usr/bin` in `PATH`, so this shadows any
   packaged `nvim`.

3. **Clone the config** (SSH key must be registered with GitHub):

   ```bash
   git clone git@github.com:yulqen/kickstart.nvim.git ~/.config/nvim
   ```

4. **The three tools Mason cannot fetch**:

   ```bash
   # Clojure CLI
   curl -O https://download.clojure.org/install/linux-install-1.12.189.sh
   chmod +x linux-install-1.12.189.sh && sudo ./linux-install-1.12.189.sh

   mkdir -p ~/.local/bin

   # cljstyle (not in mason; conform expects it on PATH). Release assets
   # are versioned now — bump the tag from the releases page.
   curl -sL -o /tmp/cljstyle.zip \
     https://github.com/greglook/cljstyle/releases/download/0.17.642/cljstyle_0.17.642_linux_amd64_static.zip
   unzip -oq /tmp/cljstyle.zip -d /tmp/cljstyle
   install -m755 /tmp/cljstyle/cljstyle ~/.local/bin/cljstyle

   # tree-sitter CLI (nvim-treesitter `main` shells out to it)
   curl -sL -o /tmp/ts.zip \
     https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-cli-linux-x64.zip
   unzip -oq /tmp/ts.zip -d /tmp/ts
   install -m755 /tmp/ts/tree-sitter ~/.local/bin/tree-sitter
   ```

   Check `~/.local/bin` is on `PATH` (`~/.profile` normally does this).

5. **First launch**: run `nvim` and wait — plugins download, Mason installs
   the LSP servers (pyright, ruff, marksman, ts_ls, prettierd, djlint,
   html-lsp, clojure-lsp), treesitter parsers install on first file open.
   Verify with `:checkhealth lsp treesitter`.

6. **Comic Code** — install the font and set it in the terminal emulator.
   No Nerd Font needed anywhere (`vim.g.have_nerd_font = false`).

Optional but nice: `lazygit` if you want it outside nvim.

```bash
LG=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
  | grep -oP '"tag_name": "v\K[^"]+')
curl -sL -o /tmp/lg.tar.gz \
  "https://github.com/jesseduffield/lazygit/releases/download/v$LG/lazygit_${LG}_linux_x86_64.tar.gz"
tar xzf /tmp/lg.tar.gz -C ~/.local/bin lazygit
```

## See also

- Upstream kickstart docs: [KICKSTART-README.md](KICKSTART-README.md)
- Everything in `init.lua` is commented — the file is meant to be read
