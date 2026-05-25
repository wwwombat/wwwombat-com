---
title: "Browser AI vs. Terminal AI: What Changed When I Moved My Dev Workflow to the CLI"
date: 2026-05-24
draft: true
tags: ["claude-code", "ai", "workflow", "automation", "developer-tools"]
categories: ["Workflow"]
summary: "I built an entire website through a browser-based AI conversation. Then I switched to a terminal-first agent. Here's what each approach actually gets right — and where each one falls apart."
ShowToc: true
TocOpen: false
---

I built this site — the one you're reading right now — through a browser conversation with Claude. The Hugo scaffold, the PaperMod theme, the custom CSS, the GitHub Actions pipeline, all of it. Copy-paste, download, screenshot, repeat.

Then I installed Claude Code and did the same kind of work from my terminal.

This isn't a product review. It's a workflow comparison from someone who used both approaches on the same project, back to back.

## The Browser Workflow: What I Built

*TODO: Summarize the wwwombat.com build process — scaffolding Hugo, configuring PaperMod, custom CSS iterations, logo placement, font exploration. Everything done through chat.*

### Where the Browser Shines

*TODO: Document the strengths —*
- *Conversational iteration on design decisions (font comparisons, branding strategy, color extraction from logo)*
- *Research and market analysis (domain registrar comparison, competitive site analysis)*
- *Strategic thinking (site architecture, content calendar, two-domain strategy)*
- *Visual feedback loop (interactive font comparison widget)*
- *Low barrier to entry — no install, no setup, just start talking*

### Where the Browser Hits Friction

*TODO: Document the pain points —*
- *File transfer overhead (download tar.gz, extract, place files manually)*
- *CSS iteration cycle (edit → download → replace → refresh → screenshot → paste back)*
- *No direct filesystem access (can't just edit in place)*
- *Context fragmentation (code in one window, terminal in another, browser in a third)*
- *The "telephone game" effect — describing errors instead of the agent seeing them directly*

## The Terminal Workflow: Same Project, Different Tool

*TODO: Document the Claude Code experience —*
- *Installation process on Windows (Node.js, npm, API key)*
- *First impressions — what it feels like to point an agent at your project*
- *The same tasks done from the CLI*

### Where the Terminal Shines

*TODO: Document the strengths —*
- *Direct filesystem access — edits happen in place, no download/upload cycle*
- *Multi-file operations (change font across config + CSS + templates in one pass)*
- *Build verification (runs hugo, sees errors, iterates without human relay)*
- *Git integration (commits, diffs, branch management)*
- *Shell access (npm install, docker compose, system commands)*

### Where the Terminal Hits Friction

*TODO: Document the pain points honestly —*
- *API cost burn rate — how much did equivalent tasks cost?*
- *Less effective for open-ended brainstorming and strategic discussion?*
- *Visual design decisions harder without rendered previews?*
- *Learning curve for prompt patterns that work in agentic mode vs. chat mode?*
- *Permission prompts and trust boundaries — helpful safety or workflow interruption?*

## Side-by-Side: The Same Task Both Ways

*TODO: Pick 2-3 concrete tasks and show the workflow comparison —*

### Task 1: Swap a Heading Font

**Browser approach:**
- *Describe the change → receive updated CSS file → download → replace file → restart server → screenshot → paste result*
- *Round trips: X*
- *Time: X minutes*

**Terminal approach:**
- *"Swap Orbitron for Share Tech Mono in the brand CSS, adjust sizing for single-weight, rebuild" → agent edits file in place → runs hugo → reports result*
- *Round trips: X*
- *Time: X minutes*

### Task 2: Add a New Blog Post Template

*TODO*

### Task 3: Debug a Build Error

*TODO*

## The Cost Question

*TODO: Real numbers —*
- *How much API credit was consumed for equivalent work?*
- *Opus vs. Sonnet tradeoffs in practice*
- *Does the time savings justify the token spend?*
- *Compare against: browser chat (included in Pro subscription) vs. Claude Code (API usage)*

## What I Actually Recommend

*TODO: The honest take —*
- *Use browser AI for: strategy, research, brainstorming, visual design decisions, content writing, learning*
- *Use terminal AI for: implementation, multi-file edits, build/test cycles, infrastructure automation, repetitive tasks*
- *The best workflow probably uses both — think in the browser, build in the terminal*
- *The meta-point: knowing which tool to reach for is itself a skill worth developing*

## What This Means for the Lab

*TODO: Connect back to wwwombat mission —*
- *How this informs the consulting practice (advising clients on AI workflow adoption)*
- *The broader pattern: AI tools are workflow-specific, not universal*
- *What I'm changing in my own setup going forward*

---

*This is the second post in the wwwombat lab series. Previously: [Building a Zero-Cost Private AI Lab on Consumer Hardware](/posts/building-a-zero-cost-private-ai-lab/).*
