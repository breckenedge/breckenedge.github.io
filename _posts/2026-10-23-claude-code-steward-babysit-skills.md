---
layout: post
title: "Claude Code reads two skill files from your PR branch that the docs never mention"
date: 2026-10-23 12:00:00 -0500
categories: dev
---

On Wednesday I was reading through what a Claude Code cloud session had been told to do while it watched a PR, and found a paragraph I didn't expect. Before it acts on a CI failure or a review comment, it's instructed to look for two files on the PR's head branch:

- `.claude/skills/steward/SKILL.md`
- `.claude/skills/babysit/SKILL.md`

If either exists (it prefers `steward/` when both do), the session treats it as repo-specific guidance that takes precedence over its default PR rules "on conventions and on how proactive to be."

I couldn't find either name anywhere in Anthropic's documentation, and two days later I still can't.

## What the instructions say

This applies when a cloud session is driving a PR, either one it opened or one you asked it to watch with [auto-fix](https://code.claude.com/docs/en/claude-code-on-the-web). Each time a check fails or a reviewer comments, the session gets an event and decides what to do about it. By default it pushes a fix for red CI, addresses review comments, and keeps going until the PR is green.

A `steward` skill lets a repo adjust that. It can make the agent more careful or more thorough, or teach it the team's conventions. The instructions limit it to tightening or clarifying the defaults. It can't give the agent more access, change its task, let it approve or merge, or override the hard rules: never skip or disable a test, never rewrite history on someone else's branch, never push an empty commit to kick CI.

## Where I looked

I downloaded the [full docs](https://code.claude.com/docs/llms-full.txt), all 9.7 MB, and searched them. "PR Steward" appears zero times, and none of the `steward` hits have anything to do with PRs. `babysit` shows up three times as an ordinary verb, in copy like "No more babysitting a PR through six rounds of lint errors." The [cloud sessions page](https://code.claude.com/docs/en/claude-code-on-the-web) has sections on auto-fixing pull requests and on how Claude responds to PR activity, and neither mentions `SKILL.md`, `.claude/skills`, the head branch, or how proactive to be. The settings docs do say a cloud session picks up a repo's skills from the clone. They don't say that two particular skill names get read as PR guidance.

I did the same with the [claude.com docs](https://claude.com/docs/llms-full.txt), which cover Claude.ai and Claude in Slack. The only matches were the Slack docs using "babysit" as a verb ("Babysit this PR until it merges"). The [Claude Code changelog](https://code.claude.com/docs/en/changelog), through 2.1.309, doesn't mention `steward` or `babysit`, and neither does the [Claude.ai changelog](https://claude.com/docs/cowork/changelog). Searching anthropic.com, claude.com, X, and Hacker News turned up nothing either. The only agent Anthropic launched this month is [Claude Duet](https://9to5google.com/2026/10/21/claude-duet-anthropic-ai-agent-waitlist/), a consumer app that has nothing to do with PRs.

There are places I couldn't check. Reddit and Threads block the search crawler, and I can't see preview emails, admin console notices, or Anthropic's Discord. If this was announced somewhere, it was one of those.

The people at [Piebald-AI/claude-code-system-prompts](https://github.com/Piebald-AI/claude-code-system-prompts) extract Claude Code's prompts from each release, and that's where PR Steward turns up. A [system prompt section from 2.1.284](https://github.com/Piebald-AI/claude-code-system-prompts/blob/main/system-prompts/system-prompt-pr-steward-handoff-guidance.md) describes it:

> PR Steward is a Claude agent that can watch a GitHub pull request, fix its CI and merge it.

It puts a label on PRs it's watching and adds a second label while it's making a change. Every other session is told to check a PR's labels before pushing to it or starting to "babysit or monitor" it. If PR Steward has the PR, the session stops and offers you three choices: leave it with Steward, make one change and hand it back, or take over by removing the label. If you're away, it leaves the PR alone. A [second fragment](https://github.com/Piebald-AI/claude-code-system-prompts/blob/main/system-prompts/agent-prompt-pr-follow-up-cron-pr-steward-label-check.md) applies the same rule to scheduled PR follow-ups. The public docs don't mention PR Steward anywhere, including the fact that it merges.

The `steward/SKILL.md` lookup isn't in those extracts. My guess is that it comes with the PR events the server sends to a cloud session, which would explain why I've never seen it in a local session.

As for `babysit`, the built-in `/loop` skill's description uses "keep running /babysit-prs" as an example of something to put on a loop. Apart from the PR Steward text, that's the only place I've found the name in Claude Code.

## Other people found it too

A few public repos have been adding a `steward` skill on purpose since late September:

- [dutchbay-epc-model#1294](https://github.com/arunakulat/dutchbay-epc-model/pull/1294), merged September 26
- [dotnet-inspect#9276](https://github.com/richlander/dotnet-inspect/issues/9276), opened October 4
- [Forge#843](https://github.com/Forge-Game-Engine/Forge/issues/843), October 11
- [libell#493](https://github.com/moggleif/libell/pull/493), merged October 12
- [payments-gateway#299](https://github.com/stop-review-now/payments-gateway/pull/299), opened October 14
- [curate-d#38](https://github.com/jorgejch/curate-d/pull/38), merged October 17

The dotnet-inspect issue has the most detail. It treats `steward` as the current name and `babysit` as an older one that came from a `gh`-based `/babysit-prs` workflow. When only `babysit/` exists, the session is told its mechanics may not apply in a cloud session (which has no `gh`), but its posture rules still do. The issue also has a table of every place the default behavior conflicts with that repo's own review process, which is a good example of what a steward file would be used for.

What surprised me is how casual these PRs are. None of them explain what a steward file is or why the repo needs one. They just add it, the way you'd add a `CONTRIBUTING.md`. None of them link to anything from Anthropic, and the ones that explain themselves describe what the session reads, so I think they're working from the prompt text like I was. The other explanation is that PR Steward is in a limited preview and the people in it were told directly. If so, I'd like to know.

## Why I care

I like the idea. A repo needs some way to tell an agent how to behave on its PRs, and a skill file in the repo is a reasonable place to put that. What bothers me is that nothing tells you it's happening.

A `.claude/skills/steward/SKILL.md` in a diff looks like any other skill, so a reviewer has no reason to think it changes how every cloud session handles every PR in the repo.

The session reads it from the PR's own branch. Most of the time that's the agent's branch and it doesn't matter, but it does mean the guidance can differ from one PR to the next, and the PR author isn't told it's being used.

And because it isn't documented, Anthropic can rename it, drop `babysit`, or change the precedence in any release without a changelog entry. At least three public repos have already merged a steward file.

## How this overlaps with my own tooling

At work we have a `pr-checks` skill that covers part of this. It's a script that polls GitHub and decides whether a PR's checks have settled, whether the bot review actually ran against the head commit, and whether the PR is ready. I wrote about the system around it in [my post about `ship`](/dev/2026/10/07/ship-unattended-claude-code-sessions.html). I built it because agents kept deciding for themselves that they were done.

A steward file would cover how the agent behaves when an event comes in, and `pr-checks` covers deciding when it's finished. Between them that's most of what I've been building by hand. I'd like to move some of `pr-checks` onto something native, but I don't want to build on a file name I found in a system prompt.

## What I'd like

A section in the docs that says `steward` and `babysit` are read, from which branch, what they can and can't change, and what PR Steward is, including that it merges. And a changelog entry when any of that changes.

In the meantime, if you run Claude Code cloud sessions against your repos, keep an eye out for either of these paths showing up in a PR.
