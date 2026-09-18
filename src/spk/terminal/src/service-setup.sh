#!/usr/bin/env bash
#
# Copyright (C) 2022 Ing <https://github.com/wjz304>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

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
}

service_postinst() {
  # use echo to write to the installer log file.
  echo "service_postinst ${SYNOPKG_PKG_STATUS}"

  mkdir -p "${SYNOPKG_PKGVAR}"
  cat >"${SYNOPKG_PKGVAR}/terminal.conf" <<EOF
WITH_TMUX=${wizard_use_tmux:-false}
USER_LOGIN=${wizard_login_root:-false}
EOF
}

service_preuninst() {
  # use echo to write to the installer log file.
  echo "service_preuninst ${SYNOPKG_PKG_STATUS}"
}

service_postuninst() {
  # use echo to write to the installer log file.
  echo "service_postuninst ${SYNOPKG_PKG_STATUS}"
}

service_preupgrade() {
  # use echo to write to the installer log file.
  echo "service_preupgrade ${SYNOPKG_PKG_STATUS}"
}

service_postupgrade() {
  # use echo to write to the installer log file.
  echo "service_postupgrade ${SYNOPKG_PKG_STATUS}"

  mkdir -p "${SYNOPKG_PKGVAR}"
  cat >"${SYNOPKG_PKGVAR}/terminal.conf" <<EOF
WITH_TMUX=${wizard_use_tmux:-false}
USER_LOGIN=${wizard_login_root:-false}
EOF
}

# REMARKS:
# installer variables are not available in the context of service start/stop
# The regular solution is to use configuration files for services

service_prestart() {
  # use echo to write to the service log file.
  echo "service_prestart: Before service start"

  # ARCH=$(uname -m)

  # 读取安装/升级向导保存的配置
  WITH_TMUX="false"
  USER_LOGIN="false"

  if [ -r "${SYNOPKG_PKGVAR}/terminal.conf" ]; then
    source "${SYNOPKG_PKGVAR}/terminal.conf"
  fi

  # ttyd 参数（Unix socket，经 nginx 反代）；用数组拼接，参考 fn-terminal 写法
  TTYDARGS=()
  TTYDARGS+=("${SYNOPKG_PKGDEST}/bin/ttyd" -a -W)
  TTYDARGS+=(-i "${SYNOPKG_PKGVAR}/terminal.sock" -b /terminal/)
  TTYDARGS+=(-t titleFixed=DSM -t allow-clipboard-read=true -t allow-clipboard-write=true -t rendererType=canvas)

  # 集成 tmux：初始化 server 并设置全局配置（参考 fn-terminal）
  if [ "${WITH_TMUX:-false}" = "true" ]; then
    "${SYNOPKG_PKGDEST}/bin/tmux" -u new-session -d -s __init__ >/dev/null 2>&1
    [ "${USER_LOGIN:-false}" = "false" ] && "${SYNOPKG_PKGDEST}/bin/tmux" -u set-option -g default-command 'login' >/dev/null 2>&1
    "${SYNOPKG_PKGDEST}/bin/tmux" -u set-option -g utf8 on >/dev/null 2>&1
    "${SYNOPKG_PKGDEST}/bin/tmux" -u set-option -g status-utf8 on >/dev/null 2>&1
    "${SYNOPKG_PKGDEST}/bin/tmux" -u set-option -g history-limit 50000 >/dev/null 2>&1
    "${SYNOPKG_PKGDEST}/bin/tmux" -u set-option -g set-clipboard on >/dev/null 2>&1
    "${SYNOPKG_PKGDEST}/bin/tmux" -u set-option -g mouse on >/dev/null 2>&1
    "${SYNOPKG_PKGDEST}/bin/tmux" -u kill-session -t __init__ >/dev/null 2>&1

    # tmux 作为执行命令，支持多会话与持久化
    TTYDARGS+=("${SYNOPKG_PKGDEST}/bin/tmux" -u new -A -s terminal)
  fi
  # 登录模式：追加 login；否则非 tmux 时以 bash 启动
  [ "${USER_LOGIN:-false}" = "false" ] && TTYDARGS+=(login) || { [ "${WITH_TMUX:-false}" = "true" ] || TTYDARGS+=(bash); }

  # 清理上一实例残留的 socket 文件，确保 nginx 反代可用
  rm -f "${SYNOPKG_PKGVAR}/terminal.sock" 2>/dev/null

  # 以私有库/terminfo 路径启动 ttyd（后台运行，记录 PID）
  LD_LIBRARY_PATH="${SYNOPKG_PKGDEST}/bin:${SYNOPKG_PKGDEST}/lib:$LD_LIBRARY_PATH" \
    TERMINFO="${SYNOPKG_PKGDEST}/share/terminfo" \
    nohup "${TTYDARGS[@]}" >${LOG_FILE} 2>&1 &
  echo $! >"${PID_FILE}"

  # ttyd 创建的 Unix socket 默认属主 root:root 且权限为 660，
  # nginx 以 http 用户运行，无法 connect 会导致 502。这里等待 socket 出现后放开权限。
  for _i in 1 2 3 4 5; do
    [ -S "${SYNOPKG_PKGVAR}/terminal.sock" ] && break
    sleep 1
  done
  chmod 666 "${SYNOPKG_PKGVAR}/terminal.sock" 2>/dev/null || true

  # /etc/nginx/conf.d/alias.*.conf or /usr/syno/share/nginx/conf.d/dsm.*.conf
  ln -s ${SYNOPKG_PKGDEST}/etc/alias.terminal.conf /etc/nginx/conf.d/alias.terminal.conf

  if nginx -t >/dev/null 2>&1; then
    systemctl reload nginx
  else
    rm -f /etc/nginx/conf.d/alias.terminal.conf
    echo "nginx configuration error"
  fi
}

service_poststop() {
  # use echo to write to the service log file.
  echo "service_poststop: After service stop"

  rm -f /etc/nginx/conf.d/alias.terminal.conf
  systemctl reload nginx

  # 运行时无 wizard 变量，显式读取配置判断是否集成 tmux
  WITH_TMUX="false"
  if [ -r "${SYNOPKG_PKGVAR}/terminal.conf" ]; then
    . "${SYNOPKG_PKGVAR}/terminal.conf"
  fi
  if [ "${WITH_TMUX:-false}" = "true" ]; then
    # 结束 tmux 会话，避免残留（参考 fn-terminal）
    "${SYNOPKG_PKGDEST}/bin/tmux" -u kill-session -t terminal >/dev/null 2>&1 || true
  fi
  rm -f "${SYNOPKG_PKGVAR}/terminal.sock" 2>/dev/null

  if [ -n "${PID_FILE}" ] && [ -r "${PID_FILE}" ]; then
    for pid in $(cat "${PID_FILE}"); do
      if [ -z "${SVC_QUIET}" ]; then
        date >>${LOG_FILE}
        echo "Stopping ${DNAME} service : $(ps -p${pid} -o comm=) (${pid})" >>${LOG_FILE}
      fi
      kill -TERM ${pid} >>${LOG_FILE} 2>&1
      wait_for_status 1 ${SVC_WAIT_TIMEOUT:=20} ${pid} || kill -KILL ${pid} >>${LOG_FILE} 2>&1
    done
    if [ -f "${PID_FILE}" ]; then
      rm -f "${PID_FILE}" >/dev/null
    fi
  fi
}
