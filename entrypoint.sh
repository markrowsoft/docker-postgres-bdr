#!/bin/bash
set -e
source ${PG_APP_HOME}/functions

[[ ${DEBUG} == true ]] && set -x

# allow arguments to be passed to postgres
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$@"
  set --
elif [[ ${1} == postgres || ${1} == $(which postgres) ]]; then
  EXTRA_ARGS="${@:2}"
  set --
fi

# default behaviour is to launch postgres
if [[ -z ${1} ]]; then
  map_uidgid

  create_datadir
  create_certdir
  create_logdir
  create_rundir

  set_resolvconf_perms
  { echo; echo "shared_preload_libraries = 'bdr'";
			echo "wal_level = 'logical'";
			echo "track_commit_timestamp = on";
			echo "max_wal_senders = 10";
			echo "max_replication_slots = 10";
			echo "max_worker_processes = 10";
			echo "default_sequenceam = 'bdr'";
		} >> "$PG_DATADIR"/postgresql.conf
  configure_postgresql

  echo "Starting PostgreSQL ${PG_VERSION}..."
  exec start-stop-daemon --start --chuid ${PG_USER}:${PG_USER} \
    --exec ${PG_BINDIR}/postgres -- -D ${PG_DATADIR} ${EXTRA_ARGS}
else
  exec "$@"
fi

