---
title: "Tools & Projects"
layout: "single"
url: "/projects/"
summary: "Open-source tools and projects from the wwwombat lab."
ShowToc: false
ShowReadingTime: false
---

Open-source tools and utilities built during lab operations. Everything here is available on [GitHub](https://github.com/wwwombat).

---

### ATT&CK Mapper

An Open WebUI tool function for querying the MITRE ATT&CK framework from inside a local AI session. Resolves detection strategies and data sources via the v14+ detection-strategy graph — the flat `x_mitre_detection` and `x_mitre_data_sources` fields were removed in v14 and tools that rely on them return empty results silently.

Search uses specificity ranking: exact technique name matches surface above starts-with, which surfaces above contains, which surfaces above description-only. Searching "phishing" returns T1566 first.

**Stack:** Python · MITRE ATT&CK STIX 2.1 · Open WebUI Tool API  
**Status:** Active · v1.5.0  
[View on GitHub →](https://github.com/wwwombat/open-webui-security-toolkit)

---

### NVD CVE Query Tool

A Python utility for querying the NIST National Vulnerability Database API. Includes date-range filtering, proper ISO 8601 timestamp handling, and HTTP/2 compatibility fixes for environments where `h2` causes issues.

**Stack:** Python · NIST NVD API v2.0
**Status:** Active
[View on GitHub →](https://github.com/wwwombat)

---

### Open WebUI Filter Functions

Programmatic middleware for sanitizing sensitive data before it reaches LLM inference. Uses regex pattern matching to scrub credentials, PSKs, serial numbers, and license keys from uploads in transit.

**Stack:** Python · Open WebUI Filter API
**Status:** Active
[View on GitHub →](https://github.com/wwwombat)

---

### AI Stack Docker Compose

Production-grade `docker-compose.yml` blueprint for deploying a local AI inference stack with GPU acceleration: Ollama, Open WebUI, SearXNG, and supporting services.

**Stack:** Docker · NVIDIA Container Runtime · Cloudflare Tunnel
**Status:** Active
[View on GitHub →](https://github.com/wwwombat)

---

*More projects shipping as the lab grows. Watch the [GitHub](https://github.com/wwwombat) or subscribe to the blog for updates.*
