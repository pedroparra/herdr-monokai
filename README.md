# Monokai

The classic Monokai dark theme from Sublime Text and VS Code, across the whole [Herdr](https://herdr.dev) window: sidebar, tabs and every terminal. Agents show their state in Monokai's own colors (yellow working, pink needs you, cyan done), and an orange ring marks the pane you're typing in. It's Herdr's own window, unchanged: spaces and agents on the left, tabs on top, panes as cards. Only the colors are new.

![Monokai](preview.png)

**No mods, no code.** The layout is JSON files and a picture. Herdr's own mods draw everything, so there is nothing here that runs, reads your files or reaches the network.

Your agents change color as they go: yellow while working, cyan when done, pink when they need you.

![An agent in the sidebar going from working to done to needs you](states.gif)

Needs Herdr 0.1.13 or later. Comes with a second theme, **Monokai Dimmed**, for a quieter grey look.

## Install

In Herdr, ask your agent:

```text
Read ~/.config/herdr-app/AGENTS.md, then add this layout: github.com/pedroparra/herdr-monokai
```

Or install it by hand:

```sh
git clone https://github.com/pedroparra/herdr-monokai
cd herdr-monokai
cp -n layouts/monokai-for-herdr.json layouts/monokai-for-herdr.svg ~/.config/herdr-app/layouts/
cp -n themes/monokai.json themes/monokai-dimmed.json ~/.config/herdr-app/themes/
herdr-app do layout.switch --name monokai-for-herdr
```

`cp -n` never replaces a file you already have. `ctrl-shift-l` switches back to your other layouts. If your Herdr uses another folder, set `HERDR_APP_HOME` and copy there instead.

If you keep it, a ★ on this repo helps other people find it: the Herdr gallery sorts layouts by stars.

### Just the colors

To keep your own layout, copy only the themes (`themes/monokai.json`, `themes/monokai-dimmed.json`) into `~/.config/herdr-app/themes/` and pick `monokai` or `monokai-dimmed` in Settings → Look. The themes have their own names, different from the layout's, so Herdr offers them in every layout. Herdr keeps one theme for light mode and one for dark mode, and files both of these under dark: if your system is in light mode, add `"appearance": "dark"` to `~/.config/herdr-app/settings.json` and reopen Herdr.

### Update or remove

To update, delete the files below from `~/.config/herdr-app/` and install again. To remove, switch to another layout (`herdr-app do layout.switch --name main`) and delete them:

- `layouts/monokai-for-herdr.json`
- `layouts/monokai-for-herdr.svg`
- `themes/monokai.json`
- `themes/monokai-dimmed.json`

Your spaces, tabs and terminals live in herdr-core, not in the layout, so nothing else changes.

### Try it without touching your own Herdr

```sh
scripts/demo.sh          # a second Herdr window with this layout and demo content
scripts/demo.sh shot     # save preview.png from it (needs uv)
scripts/demo.sh gif      # save states.gif: one agent going through its states (needs uv)
scripts/demo.sh stop     # quit it and stop its core
```

The demo has its own Herdr home, its own herdr-core session and its own `HOME`, so it can't see or change your spaces, terminals or settings. It opens three example projects with agents in every state. The agents are small scripts that print text and report a status; no real agent runs. The pictures above are this demo: `scripts/cover.py` frames it with a title, and `scripts/states-gif.py` turns its frames into the GIF.

## The colors

| | black | red | green | yellow | blue | magenta | cyan | white |
|---|---|---|---|---|---|---|---|---|
| normal | `#3e3d32` | `#f92672` | `#a6e22e` | `#e6db74` | `#66d9ef` | `#ae81ff` | `#a1efe4` | `#cfcfc2` |
| bright | `#75715e` | `#f92672` | `#a6e22e` | `#e6db74` | `#66d9ef` | `#ae81ff` | `#a1efe4` | `#f9f8f5` |

Terminal text `#f8f8f2` on `#272822`, selection `#49483e`. The sidebar and bars are `#1e1f1c`, as in VS Code's Monokai.

A few choices made for a terminal app with agents:

- **Vivid normal colors.** VS Code's built-in Monokai keeps the normal ANSI colors muted (`#c4265e`, `#86b42b`…) and saves the vivid ones for the bright slots. Most terminal output uses the normal colors, so there it looks grey. Here the normal colors are the vivid Monokai ones.
- **An orange focus ring.** Herdr draws agent states with three terminal colors: working is yellow, needs you is pink, done is cyan. Orange `#fd971f` is the one Monokai color left, so the ring around the focused pane never reads as a state.
- **Contrast, measured.** Text on the background is 13.9:1, the focus ring 6.8:1 and comments (`#75715e`) 3.0:1.

### Monokai Dimmed

VS Code's other built-in Monokai: neutral greys instead of olive, and muted normal colors with the vivid ones kept for the bright slots. Pick `monokai-dimmed` in Settings → Look.

| | black | red | green | yellow | blue | magenta | cyan | white |
|---|---|---|---|---|---|---|---|---|
| normal | `#333333` | `#c4265e` | `#86b42b` | `#b3b42b` | `#6a7ec8` | `#8c6bc8` | `#56adbc` | `#e3e3dd` |
| bright | `#666666` | `#f92672` | `#a6e22e` | `#e2e22e` | `#819aff` | `#ae81ff` | `#66d9ef` | `#f8f8f2` |

Terminal text `#c5c8c6` on `#1e1e1e`, sidebar and bars `#272727`. Two changes from VS Code: black is `#333333` instead of the background color, so black text stays visible, and the focus ring is VS Code's orange cursor `#c07020` (4.4:1) instead of its blue focus border (2.5:1, too faint for a ring).

## What's inside

| File | What it is |
|---|---|
| `themes/monokai.json` | the terminal palette, plus the sidebar, background and accent colors |
| `themes/monokai-dimmed.json` | the same for Monokai Dimmed, a theme to pick in Settings |
| `layouts/monokai-for-herdr.json` | Herdr's `main` layout with `"theme": "monokai"` at its root |
| `layouts/monokai-for-herdr.svg` | the picture Herdr's settings show for the layout |
| `RECIPE.md` | how to rebuild it from scratch, with every color and where it goes |
| `preview.png` | the picture for this README and the Herdr gallery |
| `states.gif` | the agent states, filmed from the demo |
| `scripts/demo.sh` | the demo window above; `demo-agent.sh` and `demo-shell.sh` fill its panes |
| `scripts/cover.py` | frames the demo's screenshot into `preview.png` |
| `scripts/states-gif.py` | turns the demo's frames into `states.gif` |
| `scripts/sync-main.py` | rebuilds the layout from Herdr's own `main.json`; a weekly workflow runs it and opens a PR (or an issue linking to one) when Herdr changes |

## Credits

- The Monokai color scheme is by Wimer Hazenberg (2006). This port is not affiliated with or endorsed by Monokai or Monokai Pro.
- The terminal, text and sidebar colors follow the Monokai theme built into [Visual Studio Code](https://github.com/microsoft/vscode) (MIT), and Monokai Dimmed follows VS Code's Monokai Dimmed.
- The layout is Herdr's own `main` ([herdrdev/herdr-app](https://github.com/herdrdev/herdr-app), Apache-2.0).
- The isolated demo follows the approach of [shellscape/herdr-whitby](https://github.com/shellscape/herdr-whitby)'s demo script.

## License

[Apache-2.0](LICENSE), the same license as Herdr. [NOTICE](NOTICE) lists what comes from Herdr, Monokai and VS Code.
