# CLAUDE.md

Guidance for agents working in this repo: Aaron Breckenridge's personal blog +
resume site, a Jekyll / GitHub Pages site served at www.breckenridge.dev
(minima theme, kramdown markdown, custom domain via `CNAME`).

## Development environment

This repo ships a devcontainer (`.devcontainer/`) so the full toolchain is
available without installing anything on the host. Open the folder in VS Code
and "Reopen in Container", or run `devcontainer up` from the CLI. It provides:

- **Ruby** (pinned by `.ruby-version`) with Bundler for the Jekyll build.
- **Chromium** at `$CHROME_BIN` (`/usr/bin/chromium`) for rendering the resume
  PDF. Use this env var instead of a hard-coded browser path.
- **Carlito + Liberation fonts**: metric-compatible stand-ins for Calibri and
  Arial (which Linux doesn't ship), so `assets/resume.pdf` renders with its
  intended typeface.
- **GitHub CLI** plus **SSH agent forwarding**. VS Code forwards the host SSH
  agent into the container automatically on any host OS; do not bind-mount
  `~/.ssh`. See issue #33 for the (Windows-specific) permission gotcha.

## Common tasks

Serve the site locally (port 4000 is forwarded):

```sh
bundle exec jekyll serve
```

Create a new post:

```sh
bundle exec rake new_post["My Title"]
```

## Regenerating the resume PDF

`assets/resume.md` is the single source of truth for the resume content; the
full styling/build conventions live in its YAML frontmatter. The published
artifact is `assets/resume.pdf`, embedded by the `/resume` page via an iframe.
`assets/resume.md` itself is excluded from the Jekyll build (see `_config.yml`),
so it lives in the repo as source only and is never served.

After editing the content:

1. Build the styled standalone HTML (`assets/resume.html`) per the conventions
   documented in the frontmatter of `assets/resume.md`.
2. Render it to PDF with headless Chromium. Inside the devcontainer the browser
   is portable via `$CHROME_BIN`, and a fresh `--user-data-dir` is required so
   Chromium starts its own instance instead of attaching to a running one
   (otherwise the PDF is silently not written):

   ```sh
   "$CHROME_BIN" --headless=new --disable-gpu --no-first-run \
     --no-default-browser-check --user-data-dir="$(mktemp -d)" \
     --no-pdf-header-footer --run-all-compositor-stages-before-draw \
     --virtual-time-budget=8000 \
     --print-to-pdf="assets/resume.pdf" \
     "file://$(pwd)/assets/resume.html"
   ```

3. Verify the PDF visually (2 pages, black, ragged-right) and commit it
   alongside the source. The `/resume` page needs no changes.

Outside the container, substitute your local browser path (example paths are
documented in the frontmatter of `assets/resume.md`).
