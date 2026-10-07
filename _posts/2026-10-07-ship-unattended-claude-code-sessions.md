---
layout: post
title: "ship: from Jira ticket to a mergeable PR without watching"
date: 2026-10-07 12:00:00 -0700
categories: dev
---

In March I wrote that [my workflow was trending toward less babysitting](/dev/2026/03/11/rails-workflow-update.html). I had the pieces, but I was still the glue: pick a ticket, make a worktree, start Claude, paste in the ticket, then keep checking whether CI passed or a reviewer commented. With five of those going, I spent the day switching tmux panes.

So I built `ship`. It's a zsh function and a small Python dashboard that takes a Jira ticket and keeps a Claude Code session on it until its PR is ready to merge. Fair warning: I don't expect it to work for anyone but me. I'm writing it up for posterity, and because of what building it taught me about tools in general.

## One command per ticket

```sh
ship BIG-12345
```

That creates a worktree and branch, runs the repo's setup, and starts Claude Code in a detached tmux session named after the ticket. Claude checks whether main already does what the ticket asks, then implements it, opens a PR, and follows it with our pr-checks skill: fixing failing checks, answering review comments, and resolving threads.

It also accepts a Jira link, a PR, a GitHub issue, a ticket plus directions, or a plain description:

```sh
ship "the forum search box loses its text on back navigation"
```

For a description, `claude -p` decides whether the work deserves a ticket. If it does, it writes the ticket up with acceptance criteria, files it under the best-fitting epic I lead, and ships it. If it's a question or a one-off chore, it runs as a task with no ticket. Pass an epic and `ship` works all of its To Do tickets in one session.

## The watcher decides when it's done

The part I'm happiest with is that Claude doesn't decide when the work is finished. Every run gets a watcher that checks GitHub every few minutes and closes the session only once everything is pushed, every check passes, the PR is approved, and every review thread is resolved.

It also handles context. Nothing inside a session can compact itself, so once a session passes 300k tokens and is between turns, the watcher types `/compact` into the tmux pane, the way I would.

Review that arrives after the PR is ready gets the same treatment. `ship` resumes the same session in the same worktree and tells Claude to address what's new. The same goes for merge conflicts (`ship --conflicts BIG-12345`) and runs that died partway through. Uncommitted changes are never reset or stashed. Every session is recorded in SQLite, so picking a run back up resumes the conversation.

## ship status

The thing I actually look at is `ship status`, a [Textual](https://textual.textualize.io/) dashboard with one row per piece of work:

![The ship status dashboard, showing runs in different states, PRs waiting on review, and recent Sentry exceptions](/assets/images/ship/ship-status.png)

*Demo data. The tickets and PRs are made up.*

Rows that need a person sort to the top. In this screenshot, BIG-4127's session has stopped to ask a question. When a session can't continue without a decision, it runs a small `ship-signal ask` script instead of guessing, and the question appears in the details pane. Pressing `w` types my answer into the session, and it carries on.

Under the table is a list of recent Sentry exceptions. Pressing `s` on one starts a session to fix it. Pressing `s` anywhere else opens a short wizard: pick a repo, then type a ticket, link, or description.

![The ship wizard prompting for what to ship in the webapp repo](/assets/images/ship/ship-wizard.png)

The dashboard also auto-ships. Every 15 minutes it asks Jira for To Do tickets under the epics I lead and ships any that don't have a run yet.

## Why build it instead of using herdr?

Tools like [herdr](https://github.com/ogulcancelik/herdr) are on the rise: multiplexers built for running a fleet of agents side by side. herdr is good. But every time I try one of these, I end up thinking I'd rather build my own than spend the time learning someone else's.

That used to be a bad instinct. Building your own tool meant weeks of work and a lifetime of maintenance, and learning the popular one was almost always cheaper. With Claude writing most of the code, the math has flipped. `ship` grew a feature at a time, each one its own ticket and PR. Every one of them fits exactly how I work: our Jira fields, our repos, our pr-checks skill, my tmux habits, the epics I lead. A general tool can't know any of that, so I'd spend my time bending my workflow to fit its model.

The result is a tool so personalized that it's close to useless for anyone else. It hardcodes a Jira site, assumes macOS and iTerm, and expects a particular plugin to be installed. I'm fine with that. I think more of our tools are going to look like this: built for one person, cheap to change, and never meant to be shared.

## What I've learned

**Readiness belongs outside the agent.** Before the watcher, sessions would announce they were done with a check still pending or a review thread still open. Moving that judgment to a script that asks GitHub fixed it entirely.

**Asking is better than guessing.** The `needs answers` state changed how I work with these sessions. A question in a dashboard takes ten seconds to answer. A wrong guess takes a review cycle to catch.

**Most of my time is now review.** I read PRs, answer questions, and leave comments, and the comments get addressed without me opening an editor.

If you want something like `ship`, I wouldn't clone it. I'd take the shape, a worktree per ticket, a watcher that checks real readiness, and one screen that shows what needs you, and have Claude build your own version.
