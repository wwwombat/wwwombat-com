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
