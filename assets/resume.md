---
# ============================================================================
# BUILD INSTRUCTIONS — for future agents / humans. Not part of the résumé.
# Everything between these --- fences is YAML frontmatter: strip it before
# rendering. It must NOT appear in the generated HTML or PDF.
#
# This markdown file is the SINGLE SOURCE OF TRUTH for the résumé content.
# The published artifact is assets/resume.pdf, embedded by the /resume page
# via an iframe. This file is excluded from the Jekyll build (see _config.yml),
# so it lives in the repo as source only and is not served.
#
# TO REGENERATE assets/resume.pdf AFTER EDITING THE CONTENT BELOW:
#
# Step 1 — Build a styled, standalone HTML version of the body below
#          (suggested: assets/resume.html). Styling conventions to match the
#          approved look:
#            * Black text only — no accent colors; render links in black too.
#            * Body font: "Calibri", "Segoe UI", "Helvetica Neue", Arial; ~10.4pt.
#            * Name: title-case exactly as written, DEFAULT kerning (no added
#              letter-spacing), ~27pt, centered.
#            * Contact line: centered under the name; DROP the "Phone/SMS:" and
#              "Email:" labels, KEEP the "GitHub:" label; join items with " | ".
#            * Section headings (Summary, Technical Skills, Experience,
#              Education): UPPERCASE, bold, with a 1.8px solid black bottom rule.
#            * Each job heading is "## <Title> @ <Company> (<Dates>)". Render the
#              "<Title> @ <Company>" bold on the left and the dates in italic,
#              right-aligned, on the same row (flexbox space-between). Normalize
#              spacing around "/" in titles; show date ranges with an en dash (–).
#            * Bullets ("* ...") become a tight <ul>. NO bold lead-in phrases and
#              NO em dashes — bullets should read as plain flowing sentences.
#            * Summary paragraph is ragged-right (left-aligned), NOT justified.
#            * Page: @page { size: Letter; margin: 0.5in 0.6in }
#
# Step 2 — Render that HTML to PDF with headless Chrome. Use a FRESH temporary
#          --user-data-dir so Chrome starts its own instance instead of
#          attaching to an already-running browser (otherwise the PDF is not
#          written). Output directly over assets/resume.pdf:
#
#            chrome --headless=new --disable-gpu --no-first-run \
#              --no-default-browser-check --user-data-dir="<fresh-temp-dir>" \
#              --no-pdf-header-footer --run-all-compositor-stages-before-draw \
#              --virtual-time-budget=8000 \
#              --print-to-pdf="assets/resume.pdf" \
#              "file:///<absolute-path>/assets/resume.html"
#
#          Inside the repo devcontainer, use the portable handle $CHROME_BIN
#          (/usr/bin/chromium). See CLAUDE.md. Outside the container, point at a
#          local browser, e.g. on Windows:
#            C:\Program Files\Google\Chrome\Application\chrome.exe
#            C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe
#
# Step 3 — Verify the PDF visually (2 pages, black, ragged-right) and keep it in
#          sync with this file. The /resume page needs no changes; it always
#          embeds assets/resume.pdf.
# ============================================================================
---

# Aaron Breckenridge

Phone/SMS: (214) 564-0869
Email: [aaronbreckenridge@gmail.com](mailto:aaronbreckenridge@gmail.com)
GitHub: [breckenedge](https://github.com/breckenedge) & [bockets](https://github.com/bockets)

# Summary

Engineering leader with 10+ years building web and mobile products and 7+ years leading teams, currently managing a team of 6. Track record of driving measurable growth, including 20% YoY organic traffic and conversion-lift A/B tests, while embedding AI into how the team plans, builds, and reviews code. Hands-on full-stack background (Ruby/Rails, JavaScript) paired with the operational discipline to keep teams shipping fast.

## Technical Skills

Most Proficient Languages: Ruby, JavaScript
Frameworks: Rails, Stimulus, Hotwire, Hotwire Native, React, React Native
Databases: PostgreSQL, Redis, ElasticSearch, Pinecone
AI & Agentic Tooling: Claude Code, MCP, Pi, Codex, OpenRouter
Cloud & Infrastructure: AWS, Docker, Linux

# Experience

## Team Lead/Engineering Manager @ BiggerPockets (Aug 2025 - Present)

* Lead a 6-person Engineering team, grown from 3, responsible for delivering and enhancing a revenue-generating affiliate system.
* Launched a new React-based forums experience with server-side rendering, delivering substantially faster interaction times.
* Launched a public-facing MCP endpoint exposing BiggerPockets tools to Anthropic's community of connectors.
* Automated code review for the entire Engineering team, putting AI-assisted review on every pull request.
* Built AI skills and workflows for agentic-assisted development, automating bug fixes and feature delivery across Claude Code, Pi, Codex, and OpenRouter.
* Partnered with Sales on customer calls and information discovery sessions to shape requirements for new products.
* Executed test plans to intelligently improve user experiences and increase conversion rates.
* Created Engineering plans according to Product Requirements Document specifications (and wrote a few PRDs myself).
* Transitioned team from local development environments to local and cloud-based DevContainers.

## Staff Software Engineer @ BiggerPockets (Jan 2022 - Aug 2025)

* Launched a greenfield iOS mobile app powered by Rails-based HTTP APIs + Hotwire Native.
* Drove 20% YoY organic traffic growth by optimizing legacy site performance to meet Core Web Vitals targets, improving SEO rankings and user experience.
* Guided team through service-based API rewrite to consolidate multiple navigation implementations into a single microservice.
* Implemented real-time push notification system on mobile and desktop using WebSockets and Rails channels.
* Created ML-powered recommendation feature that increased user time-on-site and engagement, implemented using a Pinecone vector database.
* Designed A/B test presenting popular utility in strategic locations, driving a 3.5% increase in signup conversions.

## Senior Software Engineer @ Theorem (Sept 2019 - Dec 2021)

* Developed an iPad-based application for in-store engraving of Apple Pencils, AirPods, and AirTags.
* Maintained and enhanced a corporate internship platform spanning internship management, automated business reporting, infrastructure integration, and QA lab asset tracking.
* Led development for new Apple engagement within the Retail QA organization, recruited and trained additional developers, then successfully transitioned the client relationship.

## Lead Software Developer @ Onsite Health Diagnostics (May 2015 - Aug 2019)

* Led the B2E to SaaS transformation, advising the C-suite on the business model transition and executing a comprehensive infrastructure and development strategy to support the new revenue model.
* Established the HIPAA compliance framework, designing and implementing the security protocols and certification processes required for healthcare partnerships and contractual agreements.
* Built and managed a 4-person engineering team, recruiting, leading, and mentoring in-house developers who maintained and enhanced a custom software suite.
* Oversaw contractor relationships, managing external development resources and company-owned hardware maintenance to support business operations.
* Modernized the health screening platform, leading a team that developed an iPad-based solution to replace paper incentive programs while handling UX design, architecture, user research, and process optimization.
* Executed a strategic leadership transition, hiring and training a replacement to enable a return to hands-on development with larger teams and diverse projects.

## Lead Software Developer @ Geoforce (Feb 2013 - Apr 2015)

* Led team that laid the foundational work for a major platform rewrite to upgrade the underlying application framework.
* Enhanced the asset tracking platform, maintaining and improving a software suite for cellular and satellite-based tracker communication across oil and gas operations.
* Built an automated billing system, designing and implementing Rental Radar software that combines asset tracking with rental data to automate customer billing.

## Software Developer @ Readyflight (Aug 2012 - Feb 2013)

## Software QA Analyst/Customer Services Team Manager/Technical Analyst @ Certrec (Jan 2009 - Aug 2012)

## Technical Analyst @ CAVOK Group/Oliver Wyman (Feb 2005 - Dec 2008)

# Education

B.A., University of North Texas (May 2006)
