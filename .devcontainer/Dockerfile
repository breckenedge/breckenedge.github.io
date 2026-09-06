# Match .ruby-version so the container build matches CI / GitHub Pages.
FROM ruby:4.0.6-bookworm

# Chromium drives the headless render of assets/resume.pdf. The two font
# packages are metric-compatible stand-ins for Calibri and Arial, which Linux
# doesn't ship, so the resume PDF still renders with its intended typeface:
#   - fonts-crosextra-carlito -> drop-in for "Calibri" (installs a fontconfig
#     alias, so the CSS font-family "Calibri" resolves to Carlito automatically)
#   - fonts-liberation        -> drop-in for Arial / Helvetica
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      chromium \
      fonts-crosextra-carlito \
      fonts-liberation \
      ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Portable handle for the headless browser, referenced by CLAUDE.md and the
# build instructions in assets/resume.md. Use this instead of a hard-coded path.
ENV CHROME_BIN=/usr/bin/chromium
