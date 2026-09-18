SPK_NAME = kodi
SPK_VERS = 1.0
SPK_REV = 1
SPK_ICON = src/$(SPK_NAME).png

DEPENDS = 
SPK_DEPENDS = "ContainerManager"
SPK_PACKAGE_ARCHS = noarch

# docker-project resource worker（Container Manager）仅 DSM 7.2+ 提供
REQUIRED_MIN_DSM = 7.0

MAINTAINER = RROrg/wjz304
DESCRIPTION = "Kodi media center running as a Docker container, based on wjz304/kodi."
DISPLAY_NAME = Kodi

HOMEPAGE = https://github.com/RROrg/syno-apps
LICENSE  = GPLv2

DSM_UI_DIR = app
DSM_UI_CONFIG = src/app/config
DSM_APP_NAME = RROrg.kodi

WIZARDS_DIR = src/wizard

STARTABLE = yes
SERVICE_SETUP = src/service-setup.sh
SSS_SCRIPT = src/start-stop-status.sh
CONF_DIR = src/conf

# 无依赖（DEPENDS 为空）=> install 阶段不产生文件，DSM7 的 copy_target 会因 install 目录不存在而失败。
# 所有文件均由 POST_STRIP_TARGET 直接写入 STAGING_DIR，故跳过 copy_target。
COPY_TARGET = nop
POST_STRIP_TARGET = kodi_strip_target

include ../../mk/spksrc.spk.mk

.PHONY: kodi_strip_target
kodi_strip_target:
	install -m 755 -d $(STAGING_DIR)/app/
	install -m 644 src/app/config $(STAGING_DIR)/app/config
	install -m 755 -d $(STAGING_DIR)/app/images/
	install -m 644 src/app/images/*.png $(STAGING_DIR)/app/images/

	# DSM 官方 Docker-project worker 的 compose 目录（对应 resource 中 "path": "docker"）
	install -m 755 -d $(STAGING_DIR)/docker/
	install -m 644 src/docker/docker-compose.yml $(STAGING_DIR)/docker/docker-compose.yml
