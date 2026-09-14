#!/usr/bin/env bash
#
# Copyright (C) 2022 Ing <https://github.com/wjz304>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

COMPOSE_FILE="${SYNOPKG_PKGDEST}/docker/docker-compose.yml"

validate_preinst() {
  # use install_log to write to installer log file.
  install_log "validate_preinst ${SYNOPKG_PKG_STATUS}"
}

validate_preuninst() {
  # use install_log to write to installer log file.
  install_log "validate_preuninst ${SYNOPKG_PKG_STATUS}"
}

validate_preupgrade() {
  # use install_log to write to installer log file.
  install_log "validate_preupgrade ${SYNOPKG_PKG_STATUS}"
}

service_preinst() {
  # use echo to write to the installer log file.
  echo "service_preinst ${SYNOPKG_PKG_STATUS}"

  if ! command -v docker >/dev/null 2>&1; then
    echo "docker not found (Container Manager not installed?)" >>"${LOG_FILE}"
    return 1
  fi
  docker pull wjz304/chromium-desktop:latest >>"${LOG_FILE}" 2>&1
}

service_postinst() {
  # use echo to write to the installer log file.
  echo "service_postinst ${SYNOPKG_PKG_STATUS}"

  mkdir -p "${SYNOPKG_PKGVAR}/home"
}

service_preuninst() {
  # use echo to write to the installer log file.
  echo "service_preuninst ${SYNOPKG_PKG_STATUS}"

  if ! command -v docker >/dev/null 2>&1; then
    echo "docker not found (Container Manager not installed?)" >>"${LOG_FILE}"
    return 1
  fi
  docker rm -f chromium-desktop >/dev/null 2>&1 || true
}

service_postuninst() {
  # use echo to write to the installer log file.
  echo "service_postuninst ${SYNOPKG_PKG_STATUS}"

  if ! command -v docker >/dev/null 2>&1; then
    echo "docker not found (Container Manager not installed?)" >>"${LOG_FILE}"
    return 1
  fi
  docker rmi -f wjz304/chromium-desktop:latest >/dev/null 2>&1 || true
}

service_preupgrade() {
  # use echo to write to the installer log file.
  echo "service_preupgrade ${SYNOPKG_PKG_STATUS}"

  if ! command -v docker >/dev/null 2>&1; then
    echo "docker not found (Container Manager not installed?)" >>"${LOG_FILE}"
    return 1
  fi
  docker pull wjz304/chromium-desktop:latest >>"${LOG_FILE}" 2>&1
}

service_postupgrade() {
  # use echo to write to the installer log file.
  echo "service_postupgrade ${SYNOPKG_PKG_STATUS}"

  mkdir -p "${SYNOPKG_PKGVAR}/home"
}

# REMARKS:
# installer variables are not available in the context of service start/stop
# The regular solution is to use configuration files for services

service_prestart() {
  # use echo to write to the service log file.
  echo "service_prestart: Before service start"

  if ! command -v docker >/dev/null 2>&1; then
    echo "docker not found (Container Manager not installed?)" >>"${LOG_FILE}"
    return 1
  fi
  docker rm -f chromium-desktop >/dev/null 2>&1 || true
  docker compose -f "${COMPOSE_FILE}" up -d --remove-orphans >>"${LOG_FILE}" 2>&1

  # /etc/nginx/conf.d/alias.*.conf or /usr/syno/share/nginx/conf.d/dsm.*.conf
  ln -s ${SYNOPKG_PKGDEST}/etc/alias.chromium-desktop.conf /etc/nginx/conf.d/alias.chromium-desktop.conf

  if nginx -t >/dev/null 2>&1; then
    systemctl reload nginx
  else
    rm -f /etc/nginx/conf.d/alias.chromium-desktop.conf
    echo "nginx configuration error"
  fi

  # 等待 noVNC unix socket 文件在宿主机就绪
  SOCK_FILE="${SYNOPKG_PKGVAR}/chromium-desktop.sock"
  for _i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
    [ -S "${SOCK_FILE}" ] && break
    sleep 1
  done
  # 确保 nginx(http 用户)能连接该 socket：目录可遍历
  chmod 777 "${SOCK_FILE}" >/dev/null 2>&1 || true
  sleep 2
  echo "service_prestart: done" >>"${LOG_FILE}"
}

service_poststop() {
  # use echo to write to the service log file.
  echo "service_poststop: After service stop"

  rm -f /etc/nginx/conf.d/alias.chromium-desktop.conf
  systemctl reload nginx

  if ! command -v docker >/dev/null 2>&1; then
    echo "docker not found (Container Manager not installed?)" >>"${LOG_FILE}"
    return 1
  fi
  docker compose -f "${COMPOSE_FILE}" down >>"${LOG_FILE}" 2>&1 || true

  echo "service_poststop: After service stop"
}
