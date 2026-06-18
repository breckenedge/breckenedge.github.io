---
layout: post
title: "Agentic Code Review at Scale"
date: 2026-06-17 12:00:00 -0600
categories: dev
---

# Introduction

This isn't your typical post about drooping in someone else's Github plugin. Reliable code review is an extraordinarily complex problem, and each business is going to have their own way of doing things.

This year, I'm trying to share as much as possible about how agents are getting more and more done for me. I hope that this helps all other folks out there who are also going though the uphevals rocking our profession. This post isn't about whether or not engineers can be 100% replaced with AI. I'm faced with trying to do as much, or more, with fewer teammates around to accomplish them. One that seems to have really unlocked reliable velocity improvements is moving more code review over to agents.

I've long been dissatisfied with 'peer review' as it's normally practiced by most engineering teams I've been on. Whenever I could, I've eliminated the requirement code review, but not necessarily the practice. It slows flow and getting fast feedback. It's led to many rounds of yak shaving. Engineers get hung up on the size of review. I don't necessarily think it's led to outcomes that warrant the effort. It seems like an ideal job to hand over to AI: no one I know really likes _doing_ it.

# My Workflow

Providing as much context as you can to the agent is important for getting valuable results. For me, in my present position, that means an agent that can retrieve information from Jira, Figma, Sentry, DataDog, CirleCI, the repo's own history, agreed upon patterns, organizational context, as well as team's comments straight from the GitHub PR so that the same ground isn't relitigated over and over again.

It's also a problem that's worth bringing out the "big guns" for. An inaccurate code review costs so much more than no review at all: it can mislead engineers and cause a lot of development churn. So even though I don't have the hard data to back up my preferences, I've usually been more impressed with Codex's ability to perform comprehensive and valid reviews with minimal mistakes. Codex is often more holistic in its reviews. It isn't always perfect, but to me, it's better than Claude, so my workflow has been to have Codex do a first pass with all the aforementioned context connections, with a second opinion from Claude. This two-agent flow is much better than either agent working alone, and Claude is particularly good at eliminating Codex's false positives.

Do things still slip through? Yes. I don't have the resources to do extensive studies, but if I had to put a number on it, I'd say it was about 90% reliable. By reading the results of the code review, I get closer to about 95%, which is about as good as a human doing the full process from end to end.

