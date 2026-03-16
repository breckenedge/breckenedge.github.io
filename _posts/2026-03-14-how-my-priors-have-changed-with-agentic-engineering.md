---
layout: post
title: "How my priors have changed with agentic engineering"
date: 2026-03-14 12:00:00 -0700
categories: dev
---

A lot of the opinions I've held about software architecture were formed in a world where humans wrote every line. That world is gone. Here's where I've had to update my thinking.

## Microservices

For years I was a majestic monolith advocate. My reasoning was simple: microservices introduce cognitive overhead that small teams can't afford. Context-switching between services — different codebases, different deployment pipelines, different failure modes — slows engineers down. A well-structured monolith was almost always the right call unless you had a large team that could dedicate ownership to individual services.

I've reversed on this. Agents don't context-switch the way humans do. A smaller, focused codebase is actually a better fit for how agents reason — they have an easier time holding the whole thing in context. The glue code that microservices require (clients, contracts, serialization) used to be a real cost. Now it isn't. Agents write it without complaint, and it doesn't show up in delivery timelines.

There's also a parallelism argument. Monorepos are naturally linear when it comes to PRs — multiple agents working in the same repo are going to step on each other. Separate repos let agents work in parallel without blocking each other. If you're running multiple agents and expecting to ship more per day, that independence matters.

## React

I've never been a React fan. My main complaints were the boilerplate, the context-switching between frontend and backend, and the sheer volume of JavaScript required to do anything useful. A full-stack Rails engineer shouldn't need to know about component lifecycle and state management just to ship a feature.

Those complaints haven't disappeared, but they've lost most of their weight. The boilerplate problem is gone when an agent is writing the boilerplate. The context-switching problem is gone when the agent is doing the switching. It's more useful to think of every engineering team as being 5–10x larger than it used to be — and at that scale, the cost-benefit of React starts to look different.

React won the frontend JS wars. It's still easy to hire for. People expect real-time, native-feeling experiences on the web, and client-side rendering has been the most reliable way to deliver that. Rails with Hotwire has its place, but I've seen enough Hotwire spaghetti to know it isn't a free lunch either. I'm not saying React is great. JavaScript still sucks. But the calculus has shifted enough that I've stopped reflexively steering people away from it.

## Change is cheap now

One of the quieter shifts is in how I think about technical debt and migration costs. Porting a codebase from one framework to another, swapping out an ORM, upgrading a major dependency — these used to be week-long projects that required careful planning and a dedicated sprint. They're now hours of work.

The prerequisite is good test coverage. If your team has maintained a solid TDD discipline, an agent can swap out an implementation, run the test suite, and iterate until it passes. The tests are the spec. What used to require deep familiarity with both the old and new system is now mostly a matter of giving the agent a clear target and letting it work.

This changes how I think about accepting technical debt. The cost of "we'll fix it later" has dropped considerably. Later is a lot sooner than it used to be.

## Libraries

The left-pad incident from years ago became a kind of shorthand for over-reliance on external dependencies — engineers importing a package that was, literally, a single function padding a string. The lesson most people took was "be more careful about what you import." The lesson I'm taking now is different: the math on dependencies has changed at every scale.

Agents are naturally inclined to write things themselves rather than reach for an import. A small, purpose-built utility that lives in your codebase is something the agent can read, modify, and reason about. A third-party library is a black box it has to infer from documentation and usage patterns. That instinct toward ownership makes sense.

This extends to larger libraries too. An agent can maintain an abstraction tailored exactly to your application — no unnecessary surface area, no fighting the API design someone else chose for different constraints. There's also been less pull toward publishing and sharing these abstractions in the community. When any team can generate a well-fitted solution in minutes, the motivation to extract and maintain a general-purpose library weakens.

I'm not saying never use libraries. But I'm much more willing to write it myself than I used to be.

## Native apps

The same logic that's making me reconsider microservices applies to mobile. React Native's pitch was always about sharing code and team across iOS and Android — one codebase, one set of engineers. The hidden cost was the experience. Apps built on React Native feel like apps built on React Native. The performance ceiling is lower, the native integrations are messier, and users notice even when they can't articulate why.

That tradeoff made sense when maintaining two separate native codebases meant double the engineering cost. Agents change the math. Swift and Kotlin are well-documented, heavily represented in training data, and agents work in them naturally. The cross-platform complexity that made React Native appealing — context-switching between two platforms, two build systems, two sets of platform idioms — is the kind of complexity agents absorb without complaint.

If the cost of going native is now roughly the same as the cost of React Native, you should just go native. The experience is better and always will be.

## Architecture

This one cuts the other direction. Everything I've said above might suggest that architectural decisions matter less — that you can just let agents figure it out. The opposite is true. Good architecture has never been more important.

Agents will take shortcuts. Not out of laziness — they just optimize locally, for what works right now, in this context. A clever structural decision that prevents a whole class of future problems isn't something an agent is naturally going to reach for. You won't always catch it in a diff or a PR. The code will be correct, the tests will pass, and the debt will accumulate invisibly.

There's also the blindspot problem. Agents are trained on common patterns. Anything unconventional — a clever technique, an unusual architecture, something that works but that most codebases don't do — is going to give them trouble. I ran into this recently with a Rails controller action that renders CSS for customizable stylesheets. The agent kept getting it wrong. Not because the problem is hard, but because it had almost certainly never encountered that pattern in training. The asset compilation pipeline, the way Rails handles MIME types for non-HTML responses, the interaction with the browser cache — none of it is in the standard playbook. Once I gave it the context explicitly, it got there. But it needed that context every time, unless it was documented somewhere it would reliably read.

The implication is that we can all afford to be architecture astronauts now. The implementation work is handled. Spend the time you used to spend writing boilerplate thinking hard about structure instead. And document your unusual patterns — not just for future engineers, but for the agents working in your codebase.
