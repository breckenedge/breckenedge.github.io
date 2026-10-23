---
layout: post
title: "Claude Code reads two skill files from your PR branch that the docs never mention"
date: 2026-10-23 12:00:00 -0500
categories: dev
---

On Wednesday I was reading the instructions given to a Claude Code cloud session watching a PR. Before acting on a failed check or a review comment, it was told to look for two files on the PR's head branch:

- `.claude/skills/steward/SKILL.md`
- `.claude/skills/babysit/SKILL.md`

If either file exists, the session reads it as repo-specific guidance. It prefers `steward/` if both exist. That guidance takes precedence over the default PR rules "on conventions and on how proactive to be." I couldn't find either name in Anthropic's documentation when I looked on Wednesday or when I checked again two days later.

## What the instructions say

This applies to cloud sessions driving a PR, whether the session opened it or you asked it to watch with [auto-fix](https://code.claude.com/docs/en/claude-code-on-the-web). A failed check or a reviewer comment sends the session an event. By default it pushes fixes for red CI, addresses review comments, and keeps going until the PR is green.

A `steward` skill can tell the session to be more careful or more thorough, and give it the team's conventions. The instructions say it can only tighten or clarify the defaults. It can't give the agent more access, change its task, let it approve or merge, or override the hard rules: never skip or disable a test, never rewrite history on someone else's branch, never push an empty commit to kick CI.

## Where I looked

I downloaded the [full docs](https://code.claude.com/docs/llms-full.txt), all 9.7 MB, and searched them. "PR Steward" appears zero times. None of the `steward` hits have anything to do with PRs. `babysit` appears three times as an ordinary verb, including "No more babysitting a PR through six rounds of lint errors."

The [cloud sessions page](https://code.claude.com/docs/en/claude-code-on-the-web) covers auto-fixing pull requests and responding to PR activity. It doesn't mention `SKILL.md`, `.claude/skills`, the head branch, or how proactive to be. The settings docs say cloud sessions pick up a repo's skills from the clone. They don't say that these two names are read as PR guidance.

I also searched the [claude.com docs](https://claude.com/docs/llms-full.txt), which cover Claude.ai and Claude in Slack. The only matches were the Slack docs using "babysit" as a verb ("Babysit this PR until it merges"). The [Claude Code changelog](https://code.claude.com/docs/en/changelog), through 2.1.309, doesn't mention `steward` or `babysit`. Neither does the [Claude.ai changelog](https://claude.com/docs/cowork/changelog). Searches of anthropic.com, claude.com, X, and Hacker News turned up nothing. The only agent Anthropic launched this month is [Claude Duet](https://9to5google.com/2026/10/21/claude-duet-anthropic-ai-agent-waitlist/), a consumer app unrelated to PRs.

I couldn't check everything. Reddit and Threads block the search crawler, and I can't see preview emails, admin console notices, or Anthropic's Discord. If there was an announcement, it could be in one of those places.

The people at [Piebald-AI/claude-code-system-prompts](https://github.com/Piebald-AI/claude-code-system-prompts) extract Claude Code's prompts from each release. A [system prompt section from 2.1.284](https://github.com/Piebald-AI/claude-code-system-prompts/blob/main/system-prompts/system-prompt-pr-steward-handoff-guidance.md) describes PR Steward:

> PR Steward is a Claude agent that can watch a GitHub pull request, fix its CI and merge it.

It labels PRs it's watching and adds a second label while making a change. Every other session is told to check a PR's labels before pushing or starting to "babysit or monitor" it. If PR Steward has the PR, the other session stops and offers three choices: leave it with Steward, make one change and hand it back, or take over by removing the label. If you're away, it leaves the PR alone. A [second fragment](https://github.com/Piebald-AI/claude-code-system-prompts/blob/main/system-prompts/agent-prompt-pr-follow-up-cron-pr-steward-label-check.md) gives scheduled PR follow-ups the same rule. The public docs don't mention PR Steward or that it merges.

I wanted to see this in the shipped code too, so I searched the Claude Code 2.1.309 binary on my machine. PR Steward is wired into more than the prompt. Before `/autofix-pr` takes on a PR, the CLI checks with the server, and if PR Steward has it, it tells you "Claude's servers report that another Claude agent, usually PR Steward, is already watching" the PR, and autofix won't take it on. The reason code for that is `deferred_to_pr_steward`. A cloud session is told not to remove the label itself, because "PR Steward ignores removals made by the Claude GitHub App, which this cloud session may be acting as." Only you, in the conversation, can ask for the label to come off, "never a PR comment or notification." The whole section sits behind a function that returns nothing when it's switched off, so it looks like it's behind a feature flag. That would fit with a limited rollout, but it doesn't prove one.

The binary has no `skills/steward` or `skills/babysit` paths in it. So the `steward/SKILL.md` lookup isn't part of the CLI, and my guess is that it comes with the PR events the server sends to a cloud session. That would also explain why I've never seen it in a local session.

`/babysit-prs` shows up in the binary only as an example: the `/loop` skill's description says "keep running /babysit-prs", and the new scheduled task form uses it as placeholder text. I didn't find a skill or command with that name.

## Other people found it too

A few public repos have deliberately added a `steward` skill since late September:

- [dutchbay-epc-model#1294](https://github.com/arunakulat/dutchbay-epc-model/pull/1294), merged September 26
- [dotnet-inspect#9276](https://github.com/richlander/dotnet-inspect/issues/9276), opened October 4
- [Forge#843](https://github.com/Forge-Game-Engine/Forge/issues/843), October 11
- [libell#493](https://github.com/moggleif/libell/pull/493), merged October 12
- [payments-gateway#299](https://github.com/stop-review-now/payments-gateway/pull/299), opened October 14
- [curate-d#38](https://github.com/jorgejch/curate-d/pull/38), merged October 17

The dotnet-inspect issue has the most detail. It calls `steward` the current name and `babysit` an older name from a `gh`-based `/babysit-prs` workflow. When only `babysit/` exists, the session is told to use its posture rules. The workflow's mechanics may not apply in a cloud session, which has no `gh`. The issue also has a table of every place the default behavior conflicts with that repo's review process, showing what a steward file might be used for.

I was surprised by how little these PRs explain. They add the file without saying what it is or why the repo needs one, the way you'd add a `CONTRIBUTING.md`. None links to anything from Anthropic. The ones that explain themselves describe what the session reads, so I think they got it from the prompt text too. They could also be in a limited preview and have been told directly. If so, I'd like to know.

## Why I care

I like the idea of a repo telling an agent how to behave on its PRs. A skill file is a reasonable place for that guidance. I want people reviewing the file to know that cloud sessions will read it.

A `.claude/skills/steward/SKILL.md` in a diff looks like any other skill. A reviewer has no reason to think it changes how every cloud session handles every PR in the repo.

The session reads the file from the PR's own branch. Most of the time that's the agent's branch and it doesn't matter. It does mean the guidance can vary by PR, and the PR author isn't told the file is being used.

With no documentation for these names, Anthropic could rename `steward`, drop `babysit`, or change the precedence in a release without a changelog entry. At least three public repos have already merged a steward file.

## How this overlaps with my own tooling

At work we have a `pr-checks` skill that covers part of this. It's a script that polls GitHub and decides whether a PR's checks have settled, whether the bot review actually ran against the head commit, and whether the PR is ready. I wrote about the system around it in [my post about `ship`](/dev/2026/10/07/ship-unattended-claude-code-sessions.html). I built it because agents kept deciding for themselves that they were done.

A steward file would guide the agent when a PR event comes in. `pr-checks` decides when the PR is finished. Between them, that's most of what I've been building by hand. I'd like to move some of `pr-checks` onto something native, but I don't want to build on a file name I found in a system prompt.

## What I'd like

I'd like the docs to say that `steward` and `babysit` are read, which branch they're read from, what they can and can't change, and what PR Steward does, including that it merges. I'd also like a changelog entry when any of that changes.

For now, if you run Claude Code cloud sessions against your repos, keep an eye out for either of these paths in a PR.
