---
layout: post
title: "ship: from Jira ticket to a mergeable PR without watching"
date: 2026-10-07 12:00:00 -0700
categories: dev
---

In March I wrote that [my workflow was trending toward less babysitting](/dev/2026/03/11/rails-workflow-update.html): background agents, parallel worktrees, subagents. I had all the pieces, but I was still the glue between them. I picked a ticket, made a worktree, started Claude, pasted in the ticket, and checked back every so often to see whether CI had passed or a reviewer had left a comment. With five of those going at once, I spent the day switching between tmux panes.

So I built `ship`. It's a zsh function and a small Python dashboard that takes a Jira ticket and keeps a Claude Code session on it until its PR is ready to merge.

## One command per ticket

```sh
ship BIG-12345
```

That creates a worktree and branch for the ticket, runs the repo's own setup (databases, dependencies), and starts an interactive Claude Code session in a detached tmux session named after the ticket. Nothing opens on screen. Claude reads the ticket, first checks whether main already does what it asks, then implements it, opens a PR, and follows it with our pr-checks skill: it fixes failing checks, answers review comments, and resolves each thread once it has dealt with it.

`ship` takes more than ticket numbers. It also accepts a Jira link, a PR number, a GitHub issue link, a ticket plus directions (`ship "BIG-12345 only the iOS side"`), or a plain description of new work:

```sh
ship "the forum search box loses its text on back navigation"
```

For a description, `claude -p` decides whether the work deserves a ticket. If it does, it writes the ticket up with acceptance criteria, files it under the best-fitting epic I lead, and ships it. If it's a question or a one-off chore, it runs as a task with no ticket. Pass an epic and `ship` works all of the epic's To Do tickets in one session. Tickets that block each other get stacked branches.

## The watcher decides when it's done

The part I'm happiest with is that Claude doesn't decide when the work is finished. Every run gets a watcher, a background process that checks GitHub directly every few minutes. It closes the session only once everything is pushed, every check passes, the head commit is approved, every review thread is resolved, and the PR is out of draft. Until all of that is true, the session keeps going.

The watcher also handles context. A run can spend hours waiting on CI and review, and its context grows the whole time. Nothing inside a session can compact itself, so once a session passes 300k tokens and is between turns, the watcher types `/compact` into the tmux pane, the way I would.

Review that arrives after the PR is ready gets the same treatment. `ship` resumes the same session in the same worktree and tells Claude to address what's new. The same goes for merge conflicts (`ship --conflicts BIG-12345`) and runs that died partway through. Uncommitted changes are never reset or stashed. Every session is recorded in SQLite, so picking a run back up resumes the conversation.

## ship status

The thing I actually look at is `ship status`, a [Textual](https://textual.textualize.io/) dashboard with one row per piece of work:

![The ship status dashboard, showing runs in different states, PRs waiting on review, and recent Sentry exceptions](/assets/images/ship/ship-status.png)

*Demo data. The tickets and PRs are made up.*

Rows that need a person sort to the top. In this screenshot, BIG-4127's session has stopped to ask a question. When a session can't continue without a decision, it runs a small `ship-signal ask` script instead of guessing, and the question appears in the details pane. Pressing `w` types my answer into the session, and it carries on. Below that are runs waiting on CI or review, each with the reason its PR isn't ready, then a finished task and my other open PRs.

Under the table is a list of recent Sentry exceptions. Pressing `s` on one starts a session to fix it. Pressing `s` anywhere else opens a short wizard: pick a repo, then type a ticket, link, or description.

![The ship wizard prompting for what to ship in the webapp repo](/assets/images/ship/ship-wizard.png)

The dashboard also auto-ships. Every 15 minutes it asks Jira for To Do tickets under the epics I'm Engineering Lead for and ships any that don't have a run yet. Tickets labelled `no-ship` are left for a person.

`a` attaches to a run's session, even after its PR is ready, so I can ask it why it made a particular choice.

## Why not herdr?

[herdr](https://github.com/ogulcancelik/herdr) is a good multiplexer for running any agent in parallel, but it shows you what your agents are doing. `ship` gets a ticket from To Do to a mergeable PR. It's narrower in return: Claude Code only, on macOS and tmux.

## What I've learned

**Readiness belongs outside the agent.** Before the watcher, sessions would announce they were done with a check still pending or a review thread still open. Moving that judgment to a script that asks GitHub fixed it entirely.

**Asking is better than guessing.** The `needs answers` state changed how I work with these sessions. A question in a dashboard takes ten seconds to answer. A wrong guess takes a review cycle to catch.

**Sessions need a resume path, not a restart path.** Laptops sleep, tmux servers die, and I close things by accident. Recording every session ID along with the worktree it ran in means a run can always be picked back up.

**Most of my time is now review.** I read PRs, answer questions, and leave comments, and the comments get addressed without me opening an editor.

`ship` is built around our Jira, repos, and pr-checks skill, but the shape carries over: a worktree and tmux session per unit of work, a watcher that checks real readiness, and one screen that shows what needs you.
