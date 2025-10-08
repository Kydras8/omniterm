DEB_VERSION ?= 1.0.5
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
