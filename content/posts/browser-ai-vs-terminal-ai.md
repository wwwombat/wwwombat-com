---
title: "Browser AI vs. Terminal AI: What Changed When I Moved My Dev Workflow to the CLI"
date: 2026-05-24
draft: false
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

When I decided to stand up wwwombat.com, I started in Claude.ai — no install, no setup, just a conversation.

By the end of it I had a technology decision (Hugo + PaperMod, deployed to Cloudflare Pages), a site architecture with five sections and a two-domain strategy, a custom CSS file with a brand palette extracted from my logo, three font families chosen through an interactive comparison widget the AI built inline, and a complete `hugo.yaml` with navigation, profile mode, and syntax highlighting configured.

The entire session happened inside a browser tab. Files came over as downloads, then got placed manually. Commands got copy-pasted into a terminal window. The AI described what to do; I executed it.

### Where the Browser Shines

**Strategic and architectural thinking.** When I asked whether wwwombat.com or wwwombat.tech should host the research site, the response wasn't a yes/no — it was a positioning analysis. The .com for credibility and audience building, the .tech for commercial conversion, with competitive references to Troy Hunt and Daniel Miessler as working examples of the model. That kind of synthesis requires judgment. Browser AI delivers it.

**Visual and creative iteration.** I described my logo — a wombat in a green ring with a circuit-board aesthetic — and got back a full CSS color palette: `#4EB067` for the primary green, `#6FD8C6` for the visor cyan, `#0a0e0b` for the OLED-friendly near-black. When I wanted to compare heading fonts, the AI built an interactive HTML comparison widget on the spot. Trying to do that in a terminal agent would be awkward at best.

**Zero barrier to entry.** I opened a browser tab. No installation, no API keys, no configuration. For the planning phase of a project, that frictionlessness matters.

### Where the Browser Hits Friction

The friction is structural. Browser AI operates outside your filesystem, which means every file handoff is manual.

The CSS iteration cycle looked like this: describe the problem → receive a code block → copy to a file or download an artifact → replace the file in the project → restart the dev server → look at the result → screenshot → paste the screenshot back into the chat → repeat. Four to six steps per round trip.

The "telephone game" effect compounds this. When a build error appeared, I had to describe it. Paste in the error log. Explain the directory structure. Describe what the CSS currently looks like. The AI was working from my transcription of reality, not reality itself.

Multi-file changes were particularly painful. When a font decision touched the CSS, the Hugo config, and a template override, that was three separate files to coordinate and transfer manually.

## The Terminal Workflow: Same Project, Different Tool

Claude Code installs as an npm package. You point it at a directory, and it has direct access to your files.

The mental shift is significant. The agent isn't advising me on what to do — it's doing it. It reads files, edits them in place, runs build commands, checks the output, and iterates. The human relay is mostly gone.

### Where the Terminal Shines

**The debugging loop collapses.** When the site deployed but the logo wasn't showing, I didn't describe the problem. The agent read the PaperMod template source, found `{{ .imageUrl | absURL }}`, understood that `absURL` generates absolute URLs from the `baseURL`, and traced the entire CORB issue back to a single configuration mismatch. That entire chain of reasoning happened because the agent could read the actual source files instead of my description of them.

**Multi-file edits become atomic.** "Fix the CSS @import ordering" meant the agent opened the file, moved the `@import` above the comment block, saved it, and confirmed. No download, no manual edit, no re-upload.

**Build verification closes the loop.** After every change, `hugo --minify` runs. If there's a warning or an error, the agent sees it directly. No screenshot, no copy-paste, no relay.

**Shell access removes blockers.** The site was missing `favicon-32x32.png` and `favicon-16x16.png`. The agent checked for ImageMagick — not installed. Installed `sharp` via npm in a temp directory, wrote a Node.js resize script targeting the logo, executed it, verified the output file sizes, and committed the result. The whole task was one instruction.

### Where the Terminal Hits Friction

**Cost is real and visible.** API usage on Claude Code charges per token. A focused implementation session is efficient. A wandering brainstorming session is not what it's optimized for, and you'll feel that in the billing. The economics favor clear, bounded tasks over open-ended exploration.

**Permission prompts interrupt flow.** Claude Code asks for confirmation before executing potentially destructive or external operations. This is the right design — it stopped me from pushing before I'd reviewed a diff — but it changes the rhythm. You're approving tool calls, not just reading responses.

**Open-ended exploration feels off.** When I wanted to think through content strategy or the two-domain architecture, the terminal felt like the wrong register. Agentic mode is optimized for execution. Thinking-out-loud sessions belong in chat.

## Side-by-Side: The Same Task Both Ways

### Task: Debug a Missing Logo

**Browser approach:**
1. Notice the logo is missing on the deployed site
2. Screenshot the page, paste into chat
3. Describe the CORB error from dev tools
4. Paste the `hugo.yaml` config into the conversation
5. Receive a theory, receive updated config
6. Replace the file manually, rebuild, check

**Terminal approach:**
1. "The homepage is missing the logo"
2. Agent checks `git ls-files static/` — file is tracked and present
3. Agent reads the PaperMod template, finds `{{ .imageUrl | absURL }}`
4. Agent checks `baseURL` in `hugo.yaml`, identifies the origin mismatch
5. Agent updates the config, commits, pushes

The terminal path was five steps with no manual file operations. The browser path was six, each requiring a file transfer or copy-paste.

### Task: Fix a CSS @import Warning

**Browser approach:** Paste the browser warning into chat → receive an explanation and updated CSS → download the file → replace it manually.

**Terminal approach:** Agent reads the file, moves the `@import` above the comment block in place, confirms. One operation.

### Task: Generate Missing Favicon Files

**Browser approach:** Learn the files are missing → receive instructions to use ImageMagick or an online tool → execute manually or troubleshoot a missing dependency.

**Terminal approach:** Agent checks for ImageMagick (not found), installs `sharp` in a temp directory, runs a resize script against the logo file, verifies output sizes, stages and commits the files.

## The Cost Question

The bulk of the strategic work for this site — architecture, branding, content planning — happened in Claude.ai under a Pro subscription. Flat monthly cost, no metering.

Claude Code charges per token. A focused implementation session is cheap. A wandering exploration session is not. The practical split: use browser AI for the thinking, terminal AI for the building. Using an agentic CLI for open-ended brainstorming is like using a forklift to move a box of pencils — technically it works, but it's not what the tool is for.

## What I Actually Recommend

**Use browser AI when:**
- You're making decisions that require context and synthesis
- You're exploring a problem space you don't fully understand yet
- You're doing creative or design work — writing, color palette, naming, strategy
- You want explanation: chat mode is more educational than agentic mode

**Use terminal AI when:**
- You have a clear task and a defined outcome
- The work touches multiple files
- The work involves build systems, package managers, or shell commands
- You're debugging something and want the agent to see the actual code, not your description of it

The switch point is roughly: once you know what you want, stop talking and start doing.

## What This Means for the Lab

Most AI workflow advice treats "AI tools" as a monolith. Use AI for this, don't use it for that. The more useful framing is: which AI workflow fits this specific task?

The browser/terminal distinction is one dimension. There's also the question of which tasks benefit from human oversight versus which ones are safe to let run — a question I'll keep returning to as the lab evolves and as I advise clients on where to put these tools in their own stacks.

For now: the site is live. The pipeline works. It was built with both approaches, which is exactly as it should be.
