---
title: "Building a Zero-Cost Private AI Lab on Consumer Hardware"
date: 2026-05-24
draft: true
tags: ["homelab", "ai", "proxmox", "gpu-passthrough", "docker", "privacy"]
categories: ["Lab Build"]
summary: "How I built a fully self-hosted AI inference environment with GPU passthrough, hardened containers, and zero-trust edge access — on hardware you can buy at Micro Center."
ShowToc: true
TocOpen: false
---

Every managed AI service wants your data on their servers. For security research, that's a non-starter.

I needed an environment where I could feed sensitive assets — firewall syslogs, vulnerability maps, proprietary scripts — into large language models without any of it leaving my physical control. No API calls to OpenAI. No data residency questions. No compliance gray areas.

So I built one.

This post walks through the full architecture: bare-metal hypervisor, GPU passthrough, containerized inference stack, and zero-trust edge access. Total cloud hosting cost: **$0/month**.

## The Hardware

*TODO: Sanitized hardware specs — keep it reproducible without doxxing the exact build.*

The core constraint was fitting meaningful local inference into a consumer budget. The key decisions:

- A CPU with enough cores to dedicate a meaningful allocation to the AI VM without starving the hypervisor
- Enough RAM to avoid OOM kills during heavy inference (this will become important later)
- A GPU with sufficient VRAM for quantized 7B-8B parameter models

## Phase 1: Hypervisor & Firmware

*TODO: Proxmox install, BIOS hardening (SVM/IOMMU), Ventoy workflow.*

## Phase 2: GPU Passthrough

*TODO: The q35 machine type, PCIe isolation, headless NVIDIA drivers. The part everyone Googles and nobody explains well.*

## Phase 3: The Container Stack

*TODO: Docker + nvidia-container-runtime, the compose blueprint, Ollama + Open WebUI architecture.*

## What Broke (And How I Fixed It)

This is the section that would have saved me hours if someone else had written it first.

### The LVM Trap

*TODO: Ubuntu's default 50% allocation, the df -h moment, lvextend + resize2fs.*

### The OOM Killer

*TODO: 16GB ceiling, swap expansion to 12GB, uninstalling Stable Diffusion to reclaim VRAM headroom.*

### Docker's File Descriptor Ceiling

*TODO: SonicWall syslog ingestion crashing at 1,024 fd limit, daemon.json ulimits fix.*

### The Localhost Loop

*TODO: Open WebUI trying to reach Ollama at localhost instead of host.docker.internal.*

## Edge Access Without Open Ports

*TODO: Cloudflare Zero Trust Tunnel — no port forwarding, encrypted sessions directly into containers.*

## What's Next

*TODO: LiteLLM gateway, isolated attack range, SSO consolidation.*

---

*This is the first post in a series documenting the wwwombat lab. Next up: a deep dive into GPU passthrough on Proxmox — the gotchas nobody warns you about.*
