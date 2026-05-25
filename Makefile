# wwwombat.com - Hugo site automation
# Usage:
#   make new POST="my-post-title"   → Create a new draft post
#   make serve                      → Local dev server with drafts
#   make build                      → Production build
#   make clean                      → Remove build artifacts

.PHONY: serve build clean new deploy

# Local development server (includes drafts, future posts)
serve:
	hugo server --buildDrafts --buildFuture --navigateToChanged

# Production build (minified, no drafts)
build:
	hugo --minify

# Create a new blog post (usage: make new POST="my-post-slug")
new:
ifndef POST
	$(error Usage: make new POST="my-post-slug")
endif
	hugo new content posts/$(POST).md
	@echo "✓ Created content/posts/$(POST).md"
	@echo "  Edit it, then set draft: false when ready to publish."

# Remove build artifacts
clean:
	rm -rf public/ resources/_gen/ .hugo_build.lock
	@echo "✓ Cleaned build artifacts."

# Quick git commit and push (triggers CI/CD deploy)
# Usage: make deploy MSG="add new post about gpu passthrough"
deploy:
ifndef MSG
	$(error Usage: make deploy MSG="commit message")
endif
	git add -A
	git commit -m "$(MSG)"
	git push origin main
	@echo "✓ Pushed to main. GitHub Actions will deploy to Cloudflare Pages."
