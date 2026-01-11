.PHONY: help test test-docker build-docker clean check show

help:
	@echo "NixUp CI/CD Testing"
	@echo ""
	@echo "Available targets:"
	@echo "  make test         - Run tests locally (requires Nix)"
	@echo "  make test-docker  - Run tests in Docker container"
	@echo "  make build-docker - Build Docker test image"
	@echo "  make check        - Run nix flake check"
	@echo "  make show         - Show flake outputs"
	@echo "  make clean        - Remove test artifacts"

# Create dummy local.nix for testing
setup-test:
	@mkdir -p hosts/framework
	@if [ ! -f hosts/framework/local.nix.backup ]; then \
		if [ -f hosts/framework/local.nix ]; then \
			cp hosts/framework/local.nix hosts/framework/local.nix.backup; \
		fi; \
	fi
	@cat > hosts/framework/local.nix << 'EOF' ; \
	{ \
	  username = "testuser"; \
	  fullName = "Test User"; \
	  hostname = "test-framework"; \
	  gitUsername = "testuser"; \
	  gitEmail = "test@example.com"; \
	  hashedPassword = "$$6$$rounds=65536$$saltsaltsalt$$IvaHiRkzSKkbj.FBR6bPwHUb9RRcT6bXB6HWF3RH.lJmxlLX0eLELXLEBJXALMKGOKXOVXMLAMBCDBEFGH"; \
	}
	EOF

# Restore original local.nix
restore-local:
	@if [ -f hosts/framework/local.nix.backup ]; then \
		mv hosts/framework/local.nix.backup hosts/framework/local.nix; \
		echo "Restored original local.nix"; \
	fi

test: setup-test
	@echo "Running tests locally..."
	@./test.sh || (make restore-local; exit 1)
	@make restore-local

build-docker:
	@echo "Building Docker test image..."
	docker build -t nixup-test -f Dockerfile.test .

test-docker: build-docker
	@echo "Running tests in Docker container..."
	docker run --rm nixup-test

check:
	@echo "Running nix flake check..."
	nix flake check --show-trace

show:
	@echo "Showing flake outputs..."
	nix flake show

metadata:
	@echo "Showing flake metadata..."
	nix flake metadata

clean: restore-local
	@echo "Cleaning up test artifacts..."
	@docker rmi nixup-test 2>/dev/null || true
	@echo "Done"
