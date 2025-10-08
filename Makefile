DEB_VERSION ?= 1.0.12
DEB_ARCH ?= amd64
PACKAGE = omniterm
DEB_DIR = $(PACKAGE)_$(DEB_VERSION)_$(DEB_ARCH)
DIST_DIR = dist

.PHONY: deb clean install uninstall

deb:
	@echo "[Kydras] Building .deb package..."
	rm -rf $(DIST_DIR)/$(DEB_DIR)
	mkdir -p $(DIST_DIR)/$(DEB_DIR)/usr/local/bin
	mkdir -p $(DIST_DIR)/$(DEB_DIR)/usr/share/doc/$(PACKAGE)
	install -m 0755 kyboost $(DIST_DIR)/$(DEB_DIR)/usr/local/bin/
	install -m 0644 README.md $(DIST_DIR)/$(DEB_DIR)/usr/share/doc/$(PACKAGE)/
	cp -r assets $(DIST_DIR)/$(DEB_DIR)/usr/share/doc/$(PACKAGE)/assets
	mkdir -p $(DIST_DIR)/$(DEB_DIR)/DEBIAN
	cp debian/control $(DIST_DIR)/$(DEB_DIR)/DEBIAN/
	dpkg-deb --build $(DIST_DIR)/$(DEB_DIR)
	@echo "Built package: $(DIST_DIR)/$(DEB_DIR).deb"

clean:
	rm -rf $(DIST_DIR)

install:
	sudo dpkg -i $(DIST_DIR)/$(DEB_DIR).deb || true

uninstall:
	sudo apt remove $(PACKAGE) -y || true

.PHONY: release release-notes
release:
	@: $${TAG?Usage: make release TAG=vX.Y.Z}
	@echo "[Kydras] Preparing release $${TAG}"
	gh auth status >/dev/null 2>&1 || gh auth login -s repo -w
	@git diff --quiet || (echo "[Kydras] Uncommitted changes present. Commit or stash before releasing."; exit 1)
	@git fetch --all --tags
	@git -c push.followTags=false push -u origin main || true
	@git tag -a $${TAG} -m "OmniTerm $${TAG}" || true
	@git push origin $${TAG}
	@# create or update the release notes
	@gh release view $${TAG} >/dev/null 2>&1 \\
	  && gh release edit $${TAG} --title "OmniTerm $${TAG}" $(NOTES) \\
	  || gh release create $${TAG} --title "OmniTerm $${TAG}" $(NOTES)

release-notes:
	@: $${TAG?Usage: make release-notes TAG=vX.Y.Z}
	gh auth status >/dev/null 2>&1 || gh auth login -s repo -w
	gh release edit $${TAG} --title "OmniTerm $${TAG}" $(NOTES)
NOTES := $(shell [ -f launch_post.md ] && echo "$(NOTES)" || echo "")

.PHONY: verify-release
verify-release:
	@: $${TAG?Usage: make verify-release TAG=vX.Y.Z}
	gh auth status >/dev/null 2>&1 || gh auth login -s repo -w
	./scripts/verify_release.sh $${TAG}

.PHONY: nightly
nightly:
	@git fetch --all --tags
	@echo "[Kydras] Moving nightly tag to HEAD of main"
	@git tag -f nightly
	@git push origin :refs/tags/nightly 2>/dev/null || true
	@git push origin nightly
