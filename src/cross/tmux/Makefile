PKG_NAME = tmux
PKG_VERS = 3.7c
PKG_EXT = tar.gz
PKG_DIST_NAME = $(PKG_VERS).$(PKG_EXT)
PKG_DIST_SITE = https://github.com/tmux/tmux/archive/
PKG_DIST_FILE = $(PKG_NAME)-$(PKG_VERS).$(PKG_EXT)
PKG_DIR = $(PKG_NAME)-$(PKG_VERS)

DEPENDS = cross/libevent cross/ncursesw

HOMEPAGE = https://github.com/tmux/tmux
COMMENT  = tmux is a terminal multiplexer, allowing multiple terminal sessions to be accessed simultaneously in a single window.
LICENSE  = ISC

GNU_CONFIGURE = 1
PRE_CONFIGURE_TARGET = tmux_pre_configure
CONFIGURE_ARGS = 

include ../../mk/spksrc.cross-cc.mk


.PHONY: tmux_pre_configure
tmux_pre_configure:
	@$(RUN) ./autogen.sh
