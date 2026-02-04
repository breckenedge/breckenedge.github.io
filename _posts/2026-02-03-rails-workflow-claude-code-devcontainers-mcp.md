---
layout: post
title: "My Rails workflow: devcontainers, Claude Code, and MCP"
date: 2026-02-03 12:00:00 -0700
categories: dev
---

I've settled into a workflow over the last couple of months that I'm pretty happy with. Rails inside a devcontainer, Claude Code on the host talking into it, and a handful of MCP servers handling context that I used to go hunting for manually.

## Devcontainers

This is the piece that moved the needle the most. New project, legacy project, doesn't matter — clone, open in VS Code, and the devcontainer comes up with Ruby, Node, Postgres, Redis, whatever the project needs. Zero setup on the host. I used to sometimes spend hours getting a legacy Rails app running on a new machine. Now it's seconds or, at most, minutes. If you've never used them, they're worth the hour it takes to learn.

## I'm not using git worktrees

I tried. The problem is specific to Rails with Webpacker/Shakapacker (a thoroughly antiquated setup these days). The Shakapacker dev server runs on its own port, and that port gets baked into the client-side HTML at build time so the browser knows where to fetch assets from. Rails has to know about it at startup.

With worktrees, you'd want each branch in its own devcontainer, each on its own set of ports — you can't have two containers fighting over 3000. But the port configuration lives in the repo, so it's the same across every worktree unless you manually change it per-container before you start. And if you have to configure a container before you can use it, you've lost most of the reason to have worktrees in the first place.

Chicken and egg. I stick with one working tree per project and switch branches the normal way.

## Claude Code on the host

Claude Code runs on my host machine, not inside the devcontainer. It needs access to my MCP servers and the broader file system, not just what's inside one container.

The trick is a `CLAUDE.md` in the project root that tells it how to reach in and use the shell:

```md
Commands need to run inside the devcontainer. Prefix commands with `docker exec`:

docker exec -it my-app bundle exec rails test
docker exec -it my-app bundle exec rails console
```

Claude reads the workspace files directly through the volume mount — no copying back and forth. Any command that needs the container environment goes through `docker exec`. It works well enough that I rarely have to think about the boundary.

The thing I'd like to change eventually is running Claude inside the devcontainer instead. If it's already in the container, I can pass `--dangerously-skip-permissions` and stop worrying about the `docker exec` indirection entirely. I haven't gotten that working yet — MCP setup is the sticking point — but it's on the list.

## MCP servers

At work I've got a handful running that feed Claude context it would otherwise have to go dig for:

- [**GitHub**](https://github.com/modelcontextprotocol/servers#github) — PRs, issues, code search. Claude also knows how to use the `gh` CLI directly, so I go back and forth.
- [**Jira and Confluence**](https://github.com/atlassian/atlassian-mcp-server) — tickets, epics, internal docs
- [**Sentry**](https://github.com/getsentry/sentry-mcp-stdio) — error tracking. I can point Claude at a specific error and it can look at the stack trace and the relevant code at the same time.
- [**CircleCI**](https://github.com/CircleCI-Public/mcp-server-circleci) — build and pipeline status
- [**Figma**](https://developers.figma.com/docs/figma-mcp-server/) — design specs. This one's a bit odd: it requires the Figma desktop app to be running.

The MCP servers are the part that changes the day-to-day the most. Before, I'd bounce between six tabs gathering context before I could even ask a useful question. Now I just ask.

## Setting up MCP for the whole team

Not everyone on the team uses Claude Code. Some use Cursor, some use Codex, and each one stores its MCP configuration in a different place and in a different format. One of them uses TOML. Manually maintaining separate config files for each agent wasn't going to work.

So there's a `bin/mcp-setup` script in the main repo. You clone, you run it, it presents a menu of supported agents, and it writes the right config to the right place for whichever one you picked. The list of MCP servers is defined inside the script and mirrors what I wrote above.

The script is a compiled Go binary. I don't know Go — Claude wrote it. The reason for Go specifically is portability: a single static binary with zero runtime dependencies. No Ruby, no Python, no Node. Anyone on the team can pull the repo and run it immediately regardless of what's installed on their machine. Autodetecting which agents are installed would be nicer than a menu, but that would mean the script needs to probe a bunch of directories and config files on the user's machine, and that felt like too much to ask for. I can see go being a big winner as devs write less and less code directly.

## Skills

Skills are another piece worth mentioning. They're slash commands you can add to Claude Code — reusable prompts that expand when you invoke them. I've got one for `/gmail` that can access my inbox using the Gmail Python API, both for reading and writing mail.

The use case is inbox management. I get 60–100 emails a day, and having Claude summarize what's unread or find a specific thread is genuinely useful.

Claude wrote the skill. I described what I wanted, it found the Gmail API docs on its own, and generated a Python script that handles OAuth, calls the API, and returns email content in a format it can work with. I don't write Python often, so having Claude handle the credentials.json setup, the token refresh logic, and the API query syntax saved me a lot of fumbling through documentation. The whole thing lives in `~/.claude/skills/gmail/`.

Skills are simpler than MCP servers — just a prompt template and optionally a script. If you find yourself repeatedly giving Claude the same setup instructions, a skill is probably the right abstraction.

## In practice

Open a project, devcontainer comes up (or it's already running), open Claude Code in a terminal on the host. Give it a Jira task number. It reads the `CLAUDE.md`, knows how to run things in the container, pulls what it needs from Jira or Sentry or GitHub, and gets to work.

There's an extra layer of indirection for every command thanks to the host/container split. But compared to where I was a couple of months ago — manually provisioning environments, context-switching between tools, spending half my time on plumbing — it's a significant step forward.
