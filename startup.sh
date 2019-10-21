#!/bin/sh

# if no arguments passed in, run gunicorn

function gunicorn_run() {
    worker_class="${GUNICORN_WORKER_CLASS:-eventlet}"
    workers="${GUNICORN_WORKERS:-1}"
    gunicorn_logging_config="${GUNICORN_LOGGIN_CONFIG:-/app/logging.conf}"
    gunicorn_timeout="${GUNICORN_TIMEOUT:-300}"
    gunicorn_bind_address="${GUNICORN_BIND_ADDRESS:-0.0.0.0}"
    gunicorn_bind_port="${GUNICORN_BIND_PORT:-5000}"
    gunicorn_bind="${gunicorn_bind_address}:${gunicorn_bind_port}"
    gunicorn_opts="--worker-class $worker_class --workers $workers --log-config $gunicorn_logging_config --timeout $gunicorn_timeout --bind $gunicorn_bind";
    # allow for passing in custom options
    if [ ${#GUNICORN_OPTS} -gt 1 ]; then
        gunicorn_opts="${gunicorn_opts} ${GUNICORN_OPTS}"
    fi
    echo "Gunicorn Options: $gunicorn_opts";
    echo "Starting gunicorn..."
    gunicorn $gunicorn_opts app:app
}

if [ ${#@} -gt 0 ]; then
    # if arguments are passed in, just run the commands
    $@
else
    echo "Running gunicorn..."
    gunicorn_run
fi