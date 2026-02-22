.PHONY: build clean mcp-build validate

build: mcp-build
	bash build/generate.sh

mcp-build:
	@if command -v node >/dev/null 2>&1; then \
		cd mcp-server && npm install --silent && npx tsc; \
	else \
		echo "SKIP: Node.js not found, skipping MCP server build"; \
	fi

validate: build
	bash test/validate-install.sh

clean:
	rm -rf dist/
	rm -rf mcp-server/dist/
