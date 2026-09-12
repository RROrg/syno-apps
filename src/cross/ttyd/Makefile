PKG_NAME = ttyd
PKG_VERS = 1.7.7
PKG_EXT =

# ttyd：不编译源码，直接从 GitHub Releases 拉取官方预编译静态二进制。
# release 文件按架构命名（ttyd.x86_64 / ttyd.aarch64 / ttyd.arm ...）
PKG_DIST_NAME = ttyd.$(PKG_DIST_ARCH)
PKG_DIST_SITE = https://github.com/tsl0922/ttyd/releases/download/$(PKG_VERS)
PKG_DIST_FILE = ttyd.$(PKG_DIST_ARCH)
PKG_DIR = $(PKG_NAME)-$(PKG_VERS)

DEPENDS =

HOMEPAGE = https://github.com/tsl0922/ttyd
COMMENT  = Share your terminal over the web
LICENSE  = MIT

INSTALL_TARGET = ttyd_install

# 该 release 提供多个架构的预编译二进制，需要多架构 digests
PKG_DIST_ARCH_LIST = x86_64 aarch64

include ../../mk/spksrc.common.mk

# 映射 spksrc 架构到 ttyd 官方 release 命名
ifeq ($(findstring $(ARCH),$(x64_ARCHS)),$(ARCH))
PKG_DIST_ARCH = x86_64
endif
ifeq ($(findstring $(ARCH),$(ARMv8_ARCHS)),$(ARCH))
PKG_DIST_ARCH = aarch64
endif


# 没有 i686 / ARMv7L / ARMv5 / PPC 的预编译二进制
UNSUPPORTED_ARCHS = $(i686_ARCHS) $(ARMv7L_ARCHS) $(ARMv5_ARCHS) $(PPC_ARCHS)

include ../../mk/spksrc.cross-install.mk

.PHONY: ttyd_install
ttyd_install:
	@install -m 755 -d $(STAGING_INSTALL_PREFIX)/bin
	@install -m 755 $(DISTRIB_DIR)/$(PKG_DIST_FILE) $(STAGING_INSTALL_PREFIX)/bin/ttyd
