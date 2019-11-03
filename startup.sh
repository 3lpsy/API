#!/bin/sh

# if no arguments passed in, run gunicorn

function gunicorn_run() {
    # define default opts
    gunicorn_bind_address="${GUNICORN_BIND_ADDRESS:-0.0.0.0}";
    gunicorn_bind_port="${GUNICORN_BIND_PORT:-5000}";
    gunicorn_bind="${gunicorn_bind_address}:${gunicorn_bind_port}";
    gunicorn_workers="${GUNICORN_WORKERS:-1}";
    # may want to increase timeout
    gunicorn_timeout="${GUNICORN_TIMEOUT:-20}";
    
    # set default opts
    gunicorn_opts="--workers $gunicorn_workers --timeout $gunicorn_timeout --bind $gunicorn_bind";

    # set optional opts
    # allow the ability to worker_class and log_config to empty string to skip option
    gunicorn_worker_class="${GUNICORN_WORKER_CLASS:-eventlet}";
    if [ ${#gunicorn_worker_class} -gt 0 ]; then
        gunicorn_opts="$gunicorn_opts --worker-class $gunicorn_worker_class";
    fi

    # gunicorn_logging_config="${GUNICORN_LOGGING_CONFIG:-/app/logging.conf}";
    # if [ ${#gunicorn_logging_config} -gt 0 ]; then
    #     gunicorn_opts="$gunicorn_opts --log-config $gunicorn_logging_config";
    # fi

    gunicorn_reload="${GUNICORN_RELOAD:-0}";
    gunicorn_debug="${GUNICORN_DEBUG:-0}";
    if [ "${gunicorn_debug}" == "1" ]; then
        gunicorn_opts="$gunicorn_opts --reload";
    elif [ "${gunicorn_reload}" == "1" ]; then
        gunicorn_opts="$gunicorn_opts --reload";
    fi

    # set custom options
    if [ ${#GUNICORN_OPTS} -gt 1 ]; then
        gunicorn_opts="${gunicorn_opts} ${GUNICORN_OPTS}"
    fi

    echo "Gunicorn Options: $gunicorn_opts";
    echo "Starting gunicorn...";
    exec gunicorn $gunicorn_opts app:app;
}

if [ ${#@} -gt 0 ]; then
    # if arguments are passed in, just run the commands
    $@
else
    echo "Running API Server: ${GUNICORN_SERVER}..."
    if [ "$GUNICORN_SERVER" == "flask" ]; then
        exec /app/app.py
    else
        gunicorn_run
    fi
fi