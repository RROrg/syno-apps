SPK_NAME = terminal
SPK_VERS = 3.0
SPK_REV = 5
SPK_ICON = src/$(SPK_NAME).png

DEPENDS = cross/tmux cross/ttyd
SPK_DEPENDS = 
SPK_PACKAGE_ARCHS =noarch

MAINTAINER = RROrg/wjz304
DESCRIPTION = "Windowed terminal for Synology NAS, based on ttyd."
DISPLAY_NAME = Terminal

HOMEPAGE = https://github.com/RROrg/syno-apps
LICENSE  = GPLv2

DSM_UI_DIR = app
DSM_UI_CONFIG = src/app/config
DSM_APP_NAME = RROrg.Terminal.AppInstance

WIZARDS_DIR = src/wizard

STARTABLE = yes
SERVICE_SETUP = src/service-setup.sh
SSS_SCRIPT = src/start-stop-status.sh

#COPY_TARGET = nop
POST_STRIP_TARGET = terminal_strip_target

include ../../mk/spksrc.spk.mk

.PHONY: terminal_strip_target
terminal_strip_target:
	install -m 755 -d $(STAGING_DIR)/app/
	install -m 644 src/app/config $(STAGING_DIR)/app/config
	install -m 644 src/app/helptoc.conf $(STAGING_DIR)/app/helptoc.conf
	install -m 644 src/app/terminal.js $(STAGING_DIR)/app/terminal.js

	install -m 755 -d $(STAGING_DIR)/etc/
	install -m 644 src/etc/alias.terminal.conf $(STAGING_DIR)/etc/alias.terminal.conf
	install -m 644 src/etc/terminal_tmux.conf $(STAGING_DIR)/etc/terminal_tmux.conf
	install -m 644 src/etc/terminal_ttyd.conf $(STAGING_DIR)/etc/terminal_ttyd.conf

	install -m 755 -d $(STAGING_DIR)/app/help
	for language in chs enu; do \
		install -m 755 -d $(STAGING_DIR)/app/help/$${language}; \
		install -m 644 src/app/help/$${language}/terminal_index.html $(STAGING_DIR)/app/help/$${language}/terminal_index.html; \
	done
	install -m 755 -d $(STAGING_DIR)/app/texts
	for language in chs enu; do \
		install -m 755 -d $(STAGING_DIR)/app/texts/$${language}; \
		install -m 644 src/app/texts/$${language}/strings $(STAGING_DIR)/app/texts/$${language}/strings; \
	done
	install -m 755 -d $(STAGING_DIR)/app/images/
	install -m 644 src/app/images/*.png $(STAGING_DIR)/app/images/
