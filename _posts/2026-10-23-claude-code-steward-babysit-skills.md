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

I couldn't find either name anywhere in Anthropic's documentation. Two days later I still can't.

## What the instructions say

This applies when a cloud session is driving a PR: one it opened, or one you asked it to watch with [auto-fix](https://code.claude.com/docs/en/claude-code-on-the-web). Each time a check fails or a reviewer comments, the session gets an event and decides what to do with it. Out of the box that's a fairly aggressive "drive it to green" posture: push a fix for red CI, address review comments, keep going.

A `steward` skill changes that posture. It can make the agent more conservative or more thorough, or teach it your team's conventions. It can't do everything, though. The instructions are explicit that the file can only tighten or clarify. It can't grant the agent more access, redirect its task, let it approve or merge, or override any of the hard "never" rules: never skip or disable a test, never rewrite history on someone else's branch, never push an empty commit just to kick CI.

So it's not a jailbreak. It's a steering wheel that nobody told you was installed.

## What I looked for

**The docs.** I downloaded the [full docs](https://code.claude.com/docs/llms-full.txt) (all 9.7 MB) and searched them. "PR Steward" appears zero times, and `steward` doesn't appear in any sense that's relevant here. `babysit` shows up three times, all as a plain verb in copy like "No more babysitting a PR through six rounds of lint errors." The [cloud sessions page](https://code.claude.com/docs/en/claude-code-on-the-web) has sections on auto-fixing pull requests and on how Claude responds to PR activity. Neither mentions `SKILL.md`, `.claude/skills`, the head branch, or how proactive to be. The settings docs say a cloud session picks up the repo's skills from the clone, which is true, but that's not the same as saying two specific skill names get special treatment.

**The changelog.** The whole [Claude Code changelog](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md), through 2.1.309, never mentions `steward` or `babysit`.

**Extracted prompts.** The people at [Piebald-AI/claude-code-system-prompts](https://github.com/Piebald-AI/claude-code-system-prompts) pull Claude Code's prompts out of each release, and this is where PR Steward turns up. A [system prompt section from 2.1.284](https://github.com/Piebald-AI/claude-code-system-prompts/blob/main/system-prompts/system-prompt-pr-steward-handoff-guidance.md) describes it directly:

> PR Steward is a Claude agent that can watch a GitHub pull request, fix its CI and merge it.

It labels PRs it's watching, and adds a second label while it's making a change. Every other session is told to check a PR's labels before pushing to it, or before starting to "babysit or monitor" it. If PR Steward has the PR, the session has to stop and offer you three choices: leave it with Steward, make one change and hand back, or take over by removing the label. If you're away, it leaves the PR alone. A [companion fragment](https://github.com/Piebald-AI/claude-code-system-prompts/blob/main/system-prompts/agent-prompt-pr-follow-up-cron-pr-steward-label-check.md) applies the same rule to scheduled PR follow-ups.

So Claude Code's own prompt tells it about an Anthropic agent that merges PRs, and the public docs don't mention it at all.

The `steward/SKILL.md` lookup itself isn't in those extracts. I'd guess it rides along with the PR events the server sends to a cloud session, not the CLI's built-in prompt, which would also explain why a local session never sees it.

**`babysit`.** The built-in `/loop` skill's own description uses "keep running /babysit-prs" as an example of something you might put on a loop. Outside the PR Steward text, that's the only trace of the name in Claude Code that I've found.

## Other people found it too

I'm not the first. A few public repos have been adding a `steward` skill on purpose for a month or so:

- [dutchbay-epc-model#1294](https://github.com/arunakulat/dutchbay-epc-model/pull/1294) (merged September 26)
- [dotnet-inspect#9276](https://github.com/richlander/dotnet-inspect/issues/9276) (opened October 4)
- [Forge#843](https://github.com/Forge-Game-Engine/Forge/issues/843) (October 11)
- [libell#493](https://github.com/moggleif/libell/pull/493) (merged October 12)

The dotnet-inspect issue is the most thorough write-up I've seen. Its read is that `steward` is the current name and `babysit` is the older one, which came from a `gh`-based `/babysit-prs` workflow. When only `babysit/` exists, its mechanics may not apply in a cloud session (which has no `gh`), but its posture rules still do. It also has a nice table of where the default drive-to-green behavior conflicts with that repo's own review process. That's exactly the kind of thing these files are for.

None of these cite Anthropic. Everyone's working from the prompt text.

## Why it bothers me

The feature is good. Repos really do need a way to tell an agent how to behave on a PR, and a skill file in the repo is a reasonable place for that. My problem is that it's invisible.

- **Nobody reviewing the file knows what it does.** A `.claude/skills/steward/SKILL.md` in a diff looks like any other skill. A reviewer has no reason to know it quietly changes how every cloud session drives every PR in the repo.
- **It's read from the head branch, not main.** Whatever is on the PR's branch is what steers the agent watching that PR. Usually that's the agent's own branch, so it's fine. But it means the guidance can change from one PR to the next, and the PR author gets no notice that it's in play.
- **Undocumented means unstable.** Someone at Anthropic can rename it, drop `babysit`, or change the precedence in any release, and there's no changelog entry to tell you. At least two public repos already depend on it, and more are planning to.

## The overlap with my own tooling

At work I already have something that covers part of this. Our `pr-checks` skill is a script that polls GitHub and decides deterministically whether a PR's checks have settled, whether the bot review actually ran against the head commit, and whether the PR is ready. I wrote about the bigger system around it in [my post about `ship`](/dev/2026/10/07/ship-unattended-claude-code-sessions.html). The point was to stop agents from deciding for themselves that they were done.

`steward` covers the other half: how the agent behaves once an event arrives. Together they're most of what I've been building by hand. I'd happily move some of `pr-checks` onto something native, but I'm not going to build on a file name I found in a system prompt.

## What I'd like

Just a docs section. Say that `steward` and `babysit` are read, from which branch, what they can and can't change, and what PR Steward is, including that it merges. Then mention it in the changelog when any of that changes.

Until then, if you run Claude Code cloud sessions against your repos, it's worth knowing these two paths exist, and worth noticing when one shows up in a PR.
