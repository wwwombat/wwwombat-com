---
title: "The Lab"
layout: "single"
url: "/lab/"
summary: "A living document of the wwwombat private AI & cybersecurity sandbox."
ShowToc: true
TocOpen: true
ShowReadingTime: true
---

This page is a living reference architecture for the wwwombat lab — a fully self-hosted, private AI execution environment and cybersecurity analysis pipeline running on consumer hardware.

The core objective: **zero-cost, 100% private local inference** for processing sensitive data assets like security logs, vulnerability maps, and custom source code — bridged with governed cloud infrastructure only when local VRAM ceilings demand it.

*Last updated: June 2026*

## Deployment Topology

```
┌─────────────────────────────────────────────────┐
│  Bare Metal: Ryzen 9 · 32GB RAM · RTX 3080 Ti  │
│  ┌───────────────────────────────────────────┐  │
│  │  Proxmox VE (Hypervisor)                  │  │
│  │  ┌─────────────────────────────────────┐  │  │
│  │  │  Ubuntu 24.04 VM (Headless)         │  │  │
│  │  │  GPU Passthrough (PCIe/IOMMU)       │  │  │
│  │  │  ┌──────────┐  ┌──────────────────┐ │  │  │
│  │  │  │  Ollama   │  │  Open WebUI      │ │  │  │
│  │  │  │  (LLM)    │  │  (Interface)     │ │  │  │
│  │  │  └──────────┘  └──────────────────┘ │  │  │
│  │  │  ┌──────────┐  ┌──────────────────┐ │  │  │
│  │  │  │ SearXNG  │  │  Kokoro TTS      │ │  │  │
│  │  │  └──────────┘  └──────────────────┘ │  │  │
│  │  └─────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────┘  │
│                       │                         │
│            Cloudflare Zero Trust Tunnel          │
└───────────────────────┬─────────────────────────┘
                        │
                   Encrypted Edge
                    (No open ports)
```

## Infrastructure Layers

### Hypervisor

Proxmox VE running on dedicated bare-metal hardware. IOMMU enabled at firmware level for hardware isolation groups. All management access locked to internal network addresses with Linux PAM authentication.

### Compute VM

A single headless Ubuntu Server 24.04 VM with dedicated CPU core bindings, pinned memory allocations, and direct PCIe passthrough of the physical GPU. No desktop environment — server-grade NVIDIA drivers only, validated via `nvidia-smi`.

### Container Stack

Docker Engine with `nvidia-container-runtime` bridging containerized workloads directly to GPU tensor cores. The stack is managed via a single `docker-compose.yml` blueprint in a dedicated project directory.

**Active containers:**
- **Ollama** — Local LLM inference engine with full GPU acceleration
- **Open WebUI** — White-labeled browser interface (WWWOMBAT.tech branding)
- **SearXNG** — Private metasearch engine for RAG pipelines
- **Kokoro TTS** — Local text-to-speech synthesis

### Security Analysis Tools

Open WebUI tool functions that extend the local AI stack with structured security intelligence:

- **ATT&CK Mapper** — Queries the MITRE ATT&CK STIX 2.1 bundle. Resolves detection strategies and data sources via the v14+ detection-strategy graph; ranked search by name specificity. Part of `open-webui-security-toolkit`.

### Edge Access

Cloudflare Zero Trust Tunnel routes encrypted sessions directly into the container stack. No ports are forwarded on the local network perimeter. External access is authenticated through Cloudflare Access policies.

## Model Inventory

| Model | Role | Use Case |
|-------|------|----------|
| Llama 3 (8B, quantized) | Generalist baseline | Log triage, sysadmin parsing, incident documentation |
| DeepSeek-Coder (6.7B) | Code analyst | Script auditing, firewall policy parsing, syntax checking |
| Dolphin-Llama | Red team assistant | Threat modeling, penetration test conceptualization |
| nomic-embed-text | Embedding engine | Local text vectorization for search pipelines |

## Data Hygiene

A custom programmatic filter function intercepts all uploads before they reach model inference or persist to the database. The middleware uses Python regex patterns to automatically scrub administrator credentials, VPN pre-shared keys, serial numbers, and license keys — replacing them with generic mask tags in transit.

```
[User Upload] → [Filter: Regex Scrubber] → [Masked Tokens] → [LLM Inference]
                                         → [Clean Data]    → [Local DB]
```

## Roadmap

- **LiteLLM Gateway** — Hybrid architecture for cloud API fallback with hard spending budgets
- **Isolated Attack Range** — Air-gapped virtual network (vmbr1) with Kali Linux + vulnerable targets for payload testing and log generation
- **SSO Consolidation** — GitHub OAuth-backed authentication across all lab nodes

---

*This page is periodically updated as the lab evolves. For the full technical deep-dive on any component, check the [blog](/posts/).*
