#!/bin/sh

# Default display name
DNAME="${SYNOPKG_PKGNAME}"

if [ "$SYNOPKG_DSM_VERSION_MAJOR" -lt 7 ]; then
  # define SYNOPKG_PKGVAR for forward compatibility
  SYNOPKG_PKGVAR="${SYNOPKG_PKGDEST}/var"
fi

# spksrc does NOT inject these into a custom SSS_SCRIPT; define them here
LOG_FILE="${SYNOPKG_PKGVAR}/${SYNOPKG_PKGNAME}.log"
PID_FILE="${SYNOPKG_PKGVAR}/${SYNOPKG_PKGNAME}.pid"

# Source package specific variable and functions
SVC_SETUP=$(dirname $0)"/service-setup"
if [ -r "${SVC_SETUP}" ]; then
  . "${SVC_SETUP}"
fi

# Invoke shell function if available
call_func() {
  FUNC=$1
  if type "${FUNC}" 2>/dev/null | grep -q 'function' 2>/dev/null; then
    echo "Begin ${FUNC}" >>${LOG_FILE}
    eval ${FUNC} >>${LOG_FILE}
    echo "End ${FUNC}" >>${LOG_FILE}
  fi
}

start_daemon() {
  if [ "$(id -u)" -ne 0 ]; then
    # If not running as root, use the current user
    echo -e "⚠️ This package requires root privileges, please run as root!!!" | tee -a $SYNOPKG_TEMP_LOGFILE
    exit 0
  fi
  if [ -z "${SVC_QUIET}" ]; then
    if [ -z "${SVC_KEEP_LOG}" ]; then
      date >${LOG_FILE}
    else
      date >>${LOG_FILE}
    fi
  fi

  call_func "service_prestart"
}

stop_daemon() {
  if [ -z "${SVC_QUIET}" ]; then
    if [ -z "${SVC_KEEP_LOG}" ]; then
      date >${LOG_FILE}
    else
      date >>${LOG_FILE}
    fi
  fi

  call_func "service_poststop"
}

#------------------------------------------------------
# daemon_status()
#     $1: PID to check, if empty use ${PID_FILE}
# status: Checks if the service is running by verifying PID file and process
#
# Return 0 when service is running, else return 1
#------------------------------------------------------
daemon_status() {
  check_pid="$1"

  # If no PID provided, check PID file
  if [ -z "${check_pid}" ]; then
    if [ ! -f "${PID_FILE}" ]; then
      return 1
    fi
    check_pid=$(cat "${PID_FILE}" 2>/dev/null)
  fi

  return 0
}

#------------------------------------------------------
# wait_for_status()
#      $1: expected return from daemon_status() call
#      $2: timeout (e.g. number of loop to be done)
#      $3: PID to check being passed to daemon_status()
# counter: Number of 1sec iteration to wait until
#          the return value from daemon_status()
#          match expected value
#
# Wait for a duration of $counter seconds for the
# return value from daemon_status().  If it match
# return 0 else return 1 if wait time is over.
#------------------------------------------------------
wait_for_status() {
  # default value: 20 seconds
  counter=${2}
  counter=${counter:=20}
  while [ ${counter} -gt 0 ]; do
    daemon_status ${3}
    [ $? -eq $1 ] && return
    let counter=counter-1
    sleep 1
  done
  return 1
}

container_status() {
  [ -x "$(command -v docker 2>/dev/null)" ] || return 1
  if docker inspect -f '{{.State.Running}}' kodi 2>/dev/null | grep -q true; then
    return 0
  fi
  return 1
}

case $1 in
  start)
    if container_status; then
      echo "${DNAME} is already running" >>${LOG_FILE}
      exit 0
    else
      echo "Starting ${DNAME} ..." >>${LOG_FILE}
      start_daemon
      exit $?
    fi
    ;;
  stop)
    if container_status; then
      echo "Stopping ${DNAME} ..." >>${LOG_FILE}
      stop_daemon
      exit $?
    else
      echo "${DNAME} is not running" >>${LOG_FILE}
      exit 0
    fi
    ;;
  status)
    if container_status; then
      echo "${DNAME} is running"
      exit 0
    else
      echo "${DNAME} is not running"
      exit 3
    fi
    ;;
  log)
    # log output for DSM < 6
    if [ -n "${LOG_FILE}" ] && [ -r "${LOG_FILE}" ]; then
      # Shorten long logs to last 100 lines
      TEMP_LOG_FILE="${SYNOPKG_PKGVAR}/${SYNOPKG_PKGNAME}_temp.log"
      # Clear any previous log
      echo "Full log: ${LOG_FILE}" >"${TEMP_LOG_FILE}"
      tail -n100 "${LOG_FILE}" >>"${TEMP_LOG_FILE}"
      echo "${TEMP_LOG_FILE}"
    fi
    exit 0
    ;;
  *)
    exit 1
    ;;
esac
