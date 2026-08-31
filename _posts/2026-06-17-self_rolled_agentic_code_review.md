---
layout: post
title: "Agentic Code Review at Scale"
date: 2026-06-17 12:00:00 -0600
categories: dev
---

# Introduction

This isn't a typical post about droping in someone else's Github plugin. Reliable code review is an extraordinarily complex problem, and each business is going to have their own way of doing things.

This year, I'm trying to share as much as possible about how agents are getting more and more done for me. I hope that this helps all other folks out there who are also going though the uphevals rocking our profession. This post isn't about whether or not engineers can be 100% replaced with AI. I'm faced with trying to do as much, or more, with fewer teammates around to accomplish them. One that seems to have really unlocked reliable velocity improvements is moving more code review over to agents.

I've long been dissatisfied with 'peer review' as it's normally practiced by most engineering teams I've been on. Whenever I could, I've eliminated the _requirement_ code review, but not necessarily the practice. Code review can slow flow and prohibit getting fast feedback about what's actually going to work in production. It's led to many rounds of yak shaving. Engineers get hung up on the size of review. I don't necessarily think it's led to outcomes that warrant the effort. It seems like an ideal job to hand over to AI: no one I know really likes _doing_ it.

# Review Quality

Code review is a problem that's worth bringing out the "big guns" for. An inaccurate code review costs so much more than no review at all: it can mislead engineers and cause a lot of development churn. So even though I don't have the hard data to back up my preferences, I've usually been more impressed with Codex's ability to perform comprehensive and valid reviews with minimal mistakes. Codex is often more holistic in its reviews. It isn't always perfect, but to me, it's better than Claude, so my workflow has been to have Codex do a first pass with all the aforementioned context connections, with a second opinion from Claude. This two-agent flow is much better than either agent working alone, and Claude is particularly good at eliminating Codex's false positives.

Do things still slip through? Yes. I don't have the resources to do extensive studies, but if I had to put a number on it, I'd say it was about 90% reliable. By reading the results of the code review, I get closer to about 95%, which is about as good as a human doing the full process from end to end.

# Providing Context

Providing as much context as you can to the agent is important for getting valuable results. For me, in my present position, that means an agent that can retrieve information from Jira, Figma, Sentry, DataDog, CirleCI, the repo's own history, shared coding patterns, organizational context, as well as the team's comments straight from the GitHub PR so that the same ground isn't reviewed more than once after decisions are made. All of these are configured via MCP, which honestly is still a pain for MCP that only supports OAuth.

# My Rube Goldberg Workflow

Sometimes I get to the end of the workflows that I've developed and think... huh, I would _never_ had started with this design. But my brain often works that way, pulling out multi-stage solutions to problems with pure intuition. I've learned to not fight this and realize that not everyone's brains work this way. It works for me. I wish I had more control over this, but alas, doing that just disrupts the process. I've come to accept that it's best to optimize _after_ I've let my brain just get all of the working parts in front of me.

Most of this is powered by Claude BTW, and I wrote zero of the workflow code.

1. An engineer (or agent) opens a PR. They can also optionally turn on an "automatically fix failing specs" triggerd via an "autofix" label. When this label is applied:
   1. If any specs fail, the last step of the CI suite tags "@claude" in a PR comment, instructing it to read the results of the CI suite and any discussions in the PR thread to try to automatically fix the failing specs. Note: This wont work with Github-actions specs due to some workflow limitations inherent to Github actions, I have to use an external CI provider (in this case, CircleCI).
   2. I give the agent an escape hatch. It is free to refuse to fix things that it things are actually broken and cannot fix. This happens about 25% of the time, especially with dependency update PRs.
2. An engineer requests review from my real-but-actually-a-bot user. (It's neat that you can tag "@claude" and "@codex" for review in PR comments, but to date, Github still doesn't allow these applications to leave a "real" review. I hope they change this soon, but for now, I have to manually set up a user account.)
3. A github workflow listens for whenever a review is requested by the bot. The workflow orchestrates first Codex to review the PR via `codex review --base main`, then follow up with a Claude review. The bot is fully driven by Github workflow actions calling out to Claude and Codex, and agents in turn use the Github API (hence the PAT) to approve or reject PRs and explain their reasoning in PR review comments.
4. If the PR is rejected during review, often I just tag "@claude" to fix the rejections. It's suprisingly good at this, and I get to skip any required local checkouts -- Claude handles it all itself in the cloud.