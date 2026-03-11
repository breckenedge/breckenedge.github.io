---
layout: post
title: "My Rails workflow: March 2026 update"
date: 2026-03-11 12:00:00 -0700
categories: dev
---

Six weeks ago I wrote about [my Rails workflow](/dev/2026/02/03/rails-workflow-claude-code-devcontainers-mcp.html) — devcontainers, Claude Code on the host, MCP servers, a Go binary for team onboarding. Most of that still holds. But enough has changed that it's worth a follow-up.

## Devcontainers: checking in development keys

Still using devcontainers. One thing I've added: checking in development decryption keys so the container can come up with zero interaction. Rails encrypted credentials need a key to decrypt, and if that key isn't available, you're prompted before anything works.

Checking in keys sounds like a bad idea, and in general it is. The reason it's fine here is that the development credentials file doesn't contain anything real — no production secrets, no API keys that matter. If someone gets the dev key, they get lorem ipsum. The habit of never checking in keys is a good one, but it exists to protect real secrets. Blindly applying it to dev environment setup just creates friction for automation with no actual security benefit.

## Worktrees: I changed my mind

In the last post I said I wasn't using git worktrees because of port conflicts — the Shakapacker dev server port gets baked into the build and hardcoded into the repo, so two containers can't share it. That was accurate at the time.

What's changed is that I now have a custom skill that handles port provisioning automatically. When it creates a new worktree, it picks an available port, updates the relevant config, and brings up the container on that port. The problem is solved. I'm using worktrees.

I'm not using Claude Code's built-in worktree support, though. It leaves orphaned worktrees around, and it gets the mechanics wrong often enough that I stopped trusting it for this. The custom skill is more reliable because it's specific to this project's port setup.

## Background agents: the @claude GitHub action

I've set up the `@claude` GitHub action on a few repos. When I open an issue, Claude Code picks it up automatically, runs headless, and opens a PR. I'm not watching.

The clearest example is [claude-code-radar](https://github.com/breckenedge/claude-code-radar), a Technology Radar I maintain for the Claude Code ecosystem — tools, plugins, patterns, and practices organized by adoption maturity (Adopt, Trial, Assess, Hold), modeled on the ThoughtWorks radar. Every week, I open an issue asking Claude to research recent releases and update the radar. It reads the changelog, checks community sources, and opens a PR with a sourced, well-reasoned update. I review, merge, done.

What I appreciate about this pattern is that it matches the task to the agent's actual strengths. Tracking a fast-moving ecosystem means reading a lot of release notes and making incremental updates — tedious for a human, easy for Claude. The output is consistently good enough to merge with light review.

## Git Town and stacked PRs

We've adopted [Git Town](https://www.git-town.com/) for stacking PRs. The motivation is keeping individual PRs reviewable — a 1500-line PR gets shallow reviews because nobody wants to read it. Splitting work into a stack of focused PRs means reviewers actually engage with the code.

The side effect I didn't expect: I've learned things about git. Claude uses tools like `rerere` naturally — it just sets it up, uses it when rebasing across multiple branches, moves on. I'd never touched rerere. Watching it work made me understand what I'd been missing. I'm a decent git user, but Claude is better, and working alongside it has closed some gaps.

## Team plans and the shift away from MCP servers

In February I wrote about `bin/mcp-setup`, a Go script that configures MCP servers across different agents for everyone on the team. We've moved to a Claude Code team plan, and that's changed the picture.

On the team plan, managers can approve and centrally install plugins. Atlassian and Figma — which I was previously wiring up manually as MCP servers — are now just there. The person who owns the tool access grants it, and it shows up in everyone's environment. That's the right model: tool access is an organizational concern, not a developer concern.

`bin/mcp-setup` is still around for the MCP servers that don't have a team-managed equivalent, but it covers less ground now.

## Subagents

Using Claude Code and Git Town together has a side effect: a lot more PRs. More PRs means more CI runs, and CI queues that were fine before started backing up.

To address it, I used a two-phase approach. First, a main agent researched the CI suite and identified where improvements were possible. Then I told Claude to use the worktree skill to create five worktrees and launch five [subagents](https://code.claude.com/docs/en/sub-agents.md) to implement the changes in parallel, one per worktree, each opening its own PR.

The constraint is that this only works when the changes are genuinely independent. If two agents are touching the same files, you've just created merge conflicts at scale. The main agent's research phase is what makes the parallel phase viable — it tells you which improvements don't step on each other.

## /insights

One more thing worth mentioning: [`/insights`](https://code.claude.com/docs/en/interactive-mode.md). Run it in a Claude Code session and it analyzes your history and generates a report — interaction patterns, friction points, what's working, and ready-to-paste suggestions for your `CLAUDE.md`. It's a useful way to surface things you're doing repeatedly that could be codified as instructions or skills. I've run it a few times and each time caught something worth adding to project config.

## Where it stands

The trajectory since February has been toward less babysitting. Background agents handling recurring research, worktrees running in parallel, plugins provisioned by admins rather than configured by hand. The interactive workflow is still there for design and complex problems, but a growing share of the work is just happening in the background.

Two things I'm watching for next month. The first is the [Ralph Loop](https://github.com/snarktank/ralph) — running an agent in a loop against a PRD, with progress persisting in git between fresh sessions rather than in context. The second is Claude Code's native [`/loop`](https://code.claude.com/docs/en/scheduled-tasks) command, which landed recently and does scheduled/recurring tasks natively: `/loop 1d /my-skill` and it runs on a cron without any external infrastructure. They're not quite the same thing — Ralph iterates toward completion of a goal, `/loop` polls on a schedule — but `/loop` looks like it covers a lot of the simpler cases that drove people to Ralph in the first place. I'm curious whether it replaces Ralph for most workflows or whether the two end up complementary.
