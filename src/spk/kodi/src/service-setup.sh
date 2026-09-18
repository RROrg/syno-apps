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
  docker pull wjz304/kodi:latest >>"${LOG_FILE}" 2>&1
}

service_postinst() {
  # use echo to write to the installer log file.
  echo "service_postinst ${SYNOPKG_PKG_STATUS}"

  mkdir -p "${SYNOPKG_PKGVAR}/kodi"
  echo "NETWORK_HOST=${wizard_network_host:-true}" >"${SYNOPKG_PKGVAR}/kodi.conf"
}

service_preuninst() {
  # use echo to write to the installer log file.
  echo "service_preuninst ${SYNOPKG_PKG_STATUS}"

  if ! command -v docker >/dev/null 2>&1; then
    echo "docker not found (Container Manager not installed?)" >>"${LOG_FILE}"
    return 1
  fi
  docker rm -f kodi >/dev/null 2>&1 || true
}

service_postuninst() {
  # use echo to write to the installer log file.
  echo "service_postuninst ${SYNOPKG_PKG_STATUS}"

  if ! command -v docker >/dev/null 2>&1; then
    echo "docker not found (Container Manager not installed?)" >>"${LOG_FILE}"
    return 1
  fi
  docker rmi -f wjz304/kodi:latest >/dev/null 2>&1 || true
}

service_preupgrade() {
  # use echo to write to the installer log file.
  echo "service_preupgrade ${SYNOPKG_PKG_STATUS}"

  if ! command -v docker >/dev/null 2>&1; then
    echo "docker not found (Container Manager not installed?)" >>"${LOG_FILE}"
    return 1
  fi
  docker pull wjz304/kodi:latest >>"${LOG_FILE}" 2>&1
}

service_postupgrade() {
  # use echo to write to the installer log file.
  echo "service_postupgrade ${SYNOPKG_PKG_STATUS}"

  mkdir -p "${SYNOPKG_PKGVAR}/kodi"
  echo "NETWORK_HOST=${wizard_network_host:-true}" >"${SYNOPKG_PKGVAR}/kodi.conf"
}

# REMARKS:
# installer variables are not available in the context of service start/stop
# The regular solution is to use configuration files for services

service_prestart() {
  # use echo to write to the service log file.
  echo "service_prestart: Before service start"

  NETWORK_HOST="true"
  if [ -f "${SYNOPKG_PKGVAR}/kodi.conf" ]; then
    source "${SYNOPKG_PKGVAR}/kodi.conf"
  fi
  if [ "${NETWORK_HOST:-true}" = "true" ]; then
    sed -i 's/network_mode: .*/network_mode: host/' "${COMPOSE_FILE}"
  else
    sed -i 's/network_mode: .*/network_mode: bridge/' "${COMPOSE_FILE}"
  fi

  if ! command -v docker >/dev/null 2>&1; then
    echo "docker not found (Container Manager not installed?)" >>"${LOG_FILE}"
    return 1
  fi
  docker rm -f kodi >/dev/null 2>&1 || true
  docker compose -f "${COMPOSE_FILE}" up -d --remove-orphans >>"${LOG_FILE}" 2>&1
}

service_poststop() {
  # use echo to write to the service log file.
  echo "service_poststop: After service stop"

  if ! command -v docker >/dev/null 2>&1; then
    echo "docker not found (Container Manager not installed?)" >>"${LOG_FILE}"
    return 1
  fi
  docker compose -f "${COMPOSE_FILE}" down >>"${LOG_FILE}" 2>&1 || true

  echo "service_poststop: After service stop"
}
