---
layout: post
title: "ship: from Jira ticket to a mergeable PR without watching"
date: 2026-10-07 12:00:00 -0700
categories: dev
---

Back in March I wrote that [my workflow was trending toward less babysitting](/dev/2026/03/11/rails-workflow-update.html). That was true, but I was still the glue. Pick a ticket, make a worktree, start Claude, paste in the ticket, then keep checking back to see if CI passed or a reviewer commented. With five of those going at once, most of my day was flipping between tmux panes.

So I built `ship` — a zsh function and a small Python dashboard that takes a Jira ticket and keeps a Claude Code session on it until the PR is ready to merge.

Up front: the source is closed, and I have no plans to open source it. It's built so specifically around how I work that I doubt it'd run for anyone else anyway. I'm writing it up mostly for posterity, and because building it changed how I think about tools.

## One command per ticket

```sh
ship BIG-12345
```

That creates a worktree and branch, runs the repo's setup, and starts Claude Code in a detached tmux session named after the ticket. Claude first checks whether main already does what the ticket asks, then implements it, opens a PR, and follows it with our pr-checks skill: fixing failing checks, answering review comments, resolving threads.

It also takes a Jira link, a PR, a GitHub issue, a ticket plus some directions, or just a plain description:

```sh
ship "the forum search box loses its text on back navigation"
```

For a description, `claude -p` decides whether the work deserves a ticket. If it does, it writes one up with acceptance criteria, files it under whichever of my epics fits best, and ships it. If it's a question or a one-off chore, it just runs as a task with no ticket. Hand it an epic and it works all of the epic's To Do tickets in one session.

## The watcher decides when it's done

This is the part I'm happiest with. Claude doesn't get to decide when the work is finished. Every run gets a watcher that checks GitHub every few minutes, and it only closes the session once everything is pushed, every check passes, the PR is approved, and every review thread is resolved.

Before the watcher, sessions would cheerfully announce they were done with a check still pending or a review thread still open. Moving that call to a script that actually asks GitHub fixed it.

The watcher also handles context. Nothing inside a session can compact itself, so once a session passes 300k tokens and is sitting between turns, the watcher types `/compact` into the tmux pane — same as I would.

Review that shows up after the PR is ready gets handled too. `ship` resumes the same session in the same worktree and tells Claude to address what's new. Same deal for merge conflicts (`ship --conflicts BIG-12345`) and runs that died partway through. Uncommitted changes never get reset or stashed. Every session is recorded in SQLite, so picking a run back up resumes the actual conversation instead of starting cold.

## ship status

What I actually look at all day is `ship status`, a [Textual](https://textual.textualize.io/) dashboard with one row per piece of work:

![The ship status dashboard, showing runs in different states, PRs waiting on review, and recent Sentry exceptions](/assets/images/ship/ship-status.png)

*Demo data. The tickets and PRs are made up.*

Anything that needs a person sorts to the top. In the screenshot, BIG-4127's session has stopped to ask a question. When a session can't continue without a decision, it runs a small `ship-signal ask` script instead of guessing, and the question shows up in the details pane. I hit `w`, type an answer into the session, and it carries on. That `needs answers` state has honestly changed how I work with these sessions more than anything else — answering a question takes ten seconds, catching a wrong guess takes a whole review cycle.

Under the table there's a list of recent Sentry exceptions, and `s` on one of those starts a session to fix it. `s` anywhere else opens a short wizard: pick a repo, then type a ticket, link, or description.

![The ship wizard prompting for what to ship in the webapp repo](/assets/images/ship/ship-wizard.png)

The dashboard also auto-ships. Every 15 minutes it asks Jira for To Do tickets under my epics and ships any that don't have a run yet.

## Why build it at all?

Every time I try someone else's tool for this kind of thing, I end up thinking I'd rather build my own than learn theirs. That used to be a bad instinct. Building your own tool meant weeks of work plus maintaining it forever, and learning the popular one was almost always cheaper. With Claude writing most of the code, that's not really true anymore. `ship` grew one feature at a time, each one its own ticket and PR.

The obvious alternative right now is something like [herdr](https://github.com/ogulcancelik/herdr) — multiplexers built for running a fleet of agents side by side are popping up everywhere, and herdr is a good one. But I think it's the wrong abstraction, at least for me. I don't need something to manage my agents. tmux does that well enough. What I needed was something to manage my commitments: tickets, tasks, research, followups, performance, all of it. Getting herdr there would mean a ton of plugins, and even then it wouldn't know our Jira fields, our repos, our pr-checks skill, or my tmux habits. I'd be bending my workflow to fit its model instead.

The tradeoff is that it's close to useless for anyone else. It hardcodes a Jira site, assumes macOS and iTerm, and expects a particular plugin to be installed. Which is part of why it's staying closed. I'm fine with that. I suspect a lot more of our tools are going to look like this: built for one person, cheap to change, never really meant to be shared — at least not the source.

## Where it stands

I still spend most of my day talking to agents. But it's about product ideas now, not code.

If you want something like `ship`, the shape is the useful part — a worktree per ticket, a watcher that checks real readiness, one screen that shows what needs you. Claude can build you your own version of that faster than you'd expect.
