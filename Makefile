SHELL := /bin/bash
PACKAGE := omniterm
DIST := dist

.PHONY: all install uninstall package release lint doctor

all: package

install:
	./install.sh

uninstall:
	./uninstall.sh

package:
	mkdir -p $(DIST)
	zip -r $(DIST)/$(PACKAGE)-main.zip \
		kyboost bin .zshrc.kydras .tmux.conf.kydras assets \
		thunar-open-omni.action kydras-omninterm*.desktop \
		install.sh uninstall.sh scripts README.md LICENSE \
		2>/dev/null || true
	@echo "Built $(DIST)/$(PACKAGE)-main.zip"

release:
	@if [ -z "$$TAG" ]; then echo "Usage: make release TAG=v1.0.1"; exit 1; fi
	mkdir -p $(DIST)
	zip -r $(DIST)/$(PACKAGE)-$$TAG.zip \
		kyboost bin .zshrc.kydras .tmux.conf.kydras assets \
		thunar-open-omni.action kydras-omninterm*.desktop \
		install.sh uninstall.sh scripts README.md LICENSE \
		2>/dev/null || true
	sha256sum $(DIST)/$(PACKAGE)-$$TAG.zip | tee $(DIST)/SHA256SUMS.txt
	@echo "Package ready in $(DIST). Push tag $$TAG to trigger GH release workflow."

lint:
	@command -v shellcheck >/dev/null || (echo "shellcheck not found"; exit 0)
	shellcheck -S warning kyboost || true
	@[ -d bin ] && find bin -maxdepth 1 -type f -perm -111 -exec shellcheck -S warning {} \; || true

doctor:
	./scripts/kydoctor.sh
