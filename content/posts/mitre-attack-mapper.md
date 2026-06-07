---
title: "Building a MITRE ATT&CK Mapper for Open WebUI"
date: 2026-06-07
draft: false
tags: ["security", "mitre-attack", "threat-intelligence", "open-webui", "python", "stix"]
categories: ["Security Tools"]
summary: "The ATT&CK v14+ STIX data model quietly dropped the flat detection and data source fields every older tool relied on. Here's what broke, why it was silent, and how the detection-strategy graph fixes it."
ShowToc: true
TocOpen: false
---

The MITRE ATT&CK framework is invaluable for threat analysis — but querying it well is harder than it looks. The STIX 2.1 data format ATT&CK ships in changed significantly in v14, and a tool that worked against older data will silently return empty detection fields against the current bundle.

This post documents the ATT&CK Mapper I built for the wwwombat lab: an Open WebUI tool function that lets you query ATT&CK techniques by name or keyword, returning technique details, data sources, and detection strategies — all from inside a local AI session, with no external API calls.

## What It Does

ATT&CK Mapper is an Open WebUI tool function. You describe a behavior, a technique name, or a tactic, and it returns matching ATT&CK techniques with:

- Technique ID and full name
- Description
- Associated tactics
- Data sources (what log sources or sensors would capture this behavior)
- Detection guidance

The intent is to close the gap between raw incident data and structured threat intelligence. When you're analyzing a syslog entry, a suspicious script, or an access pattern and want to know where it falls in ATT&CK — and what your detection stack should be logging to catch it — the mapper surfaces that without leaving the Open WebUI session.

## The v14+ STIX Problem

MITRE ATT&CK publishes its data as STIX 2.1 bundles. In version 13 and earlier, detection information and data source references were stored as flat properties on each technique object:

```json
{
  "type": "attack-pattern",
  "name": "Phishing",
  "x_mitre_detection": "Monitor email gateway logs for...",
  "x_mitre_data_sources": [
    "Application Log: Application Log Content",
    "Network Traffic: Network Traffic Content"
  ]
}
```

In v14, MITRE restructured the data model. Detection strategies became their own STIX objects — `x-mitre-data-component` nodes connected to techniques via `detects` relationships. The flat `x_mitre_detection` and `x_mitre_data_sources` properties were removed.

Any tool that reads these flat properties directly will return empty strings for detection and an empty array for data sources on v14+ data — silently, with no error. The technique lookup succeeds, the data just isn't there, and if you're not reading the raw STIX you might not notice for a while.

This is the problem the initial mapper had. The technique names and IDs were correct; the detection and data source fields came back blank on every query.

### Fixing It: Graph Traversal

The first pass (v1.2.0) added a defensive fallback — if `x_mitre_detection` is absent, note it rather than crash. That fixed the crash, but detection data was still missing.

v1.3.0 fixed it properly by walking the graph:

```python
def get_detection_info(technique_id, stix_bundle):
    # Find all 'detects' relationships pointing at this technique
    relationships = [
        obj for obj in stix_bundle["objects"]
        if obj.get("type") == "relationship"
        and obj.get("relationship_type") == "detects"
        and obj.get("target_ref") == technique_id
    ]

    data_sources = []
    detection_notes = []

    for rel in relationships:
        # Resolve the source data component object
        component = next(
            (obj for obj in stix_bundle["objects"] if obj["id"] == rel["source_ref"]),
            None
        )
        if component:
            data_sources.append(component.get("name", ""))
            if rel.get("description"):
                detection_notes.append(rel["description"])

    return data_sources, detection_notes
```

The `detects` relationship objects carry the detection guidance in their `description` field. The data component objects carry the log source names. Walking the graph is what the v14+ data model actually requires.

## The Search Ranking Problem

With the data structure fixed, the next issue was search quality.

The initial implementation searched both technique names and descriptions using substring matching, but ranked all results equally. Searching for "phishing" returned T1566 (Phishing) buried somewhere in a list of techniques whose descriptions merely mentioned phishing in passing — not surfaced first.

The fix was a specificity ranking applied to each match:

| Priority | Condition | Example |
|----------|-----------|---------|
| 1 | Exact name match | "Phishing" → T1566 |
| 2 | Name starts with query | "Phish" → T1566 |
| 3 | Name contains query | Spearphishing sub-techniques |
| 4 | Description-only match | Techniques that mention phishing contextually |

v1.4.0 separated name matches from description matches. v1.5.0 added within-name ranking (exact → starts-with → contains). The practical effect: "phishing" now surfaces T1566 as the first result, with the spearphishing sub-techniques immediately below, before anything that merely references the word.

## Current State

The mapper is part of the `open-webui-security-toolkit` repo. The ATT&CK STIX bundle is loaded as a knowledge base directly in Open WebUI; the tool function queries it at inference time. No external API calls, no rate limits, no network dependency.

Current version: **v1.5.0**

Working:
- Full ATT&CK v14+ technique lookup
- Detection strategy and data source resolution via graph traversal
- Ranked search with name and description specificity

On the roadmap:
- Sub-technique to parent technique navigation
- Tactic-filtered search (techniques under a specific tactic only)
- ATT&CK Navigator-compatible export for heatmap generation

The repo is at [github.com/wwwombat/open-webui-security-toolkit](https://github.com/wwwombat/open-webui-security-toolkit).
