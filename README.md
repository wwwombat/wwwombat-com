# wwwombat.com

Personal research site and technical blog for the WWWOMBAT project — private AI infrastructure & cybersecurity research.

## Stack

- **Generator:** [Hugo](https://gohugo.io/) with [PaperMod](https://github.com/adityatelange/hugo-PaperMod) theme
- **Hosting:** [Cloudflare Pages](https://pages.cloudflare.com/) (auto-deployed via GitHub Actions)
- **DNS:** Cloudflare
- **Analytics:** Cloudflare Web Analytics

## Local Development

```bash
# Install Hugo (macOS)
brew install hugo

# Install Hugo (Ubuntu/Debian)
sudo apt install hugo

# Clone with submodules (PaperMod theme)
git clone --recurse-submodules https://github.com/wwwombat/wwwombat-com.git
cd wwwombat-com

# Start dev server (includes drafts)
make serve

# Create a new post
make new POST="my-post-slug"

# Production build
make build
```

## Deployment

Pushes to `main` automatically deploy to Cloudflare Pages via GitHub Actions.

```bash
# Quick deploy workflow
make deploy MSG="add new post"
```

### First-Time Setup

1. Create a Cloudflare Pages project named `wwwombat-com`
2. Generate a Cloudflare API token with **Pages: Edit** permissions
3. Add secrets to GitHub repo settings:
   - `CLOUDFLARE_API_TOKEN`
   - `CLOUDFLARE_ACCOUNT_ID`

## Content Structure

```
content/
├── about.md          # About page
├── lab.md            # Living lab reference architecture
├── projects.md       # Tools & open-source projects
├── search.md         # PaperMod search page
└── posts/            # Blog posts (Markdown)
    └── *.md
```

## License

Content © wwwombat. Code and configuration under MIT.
