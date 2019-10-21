# Largely taken from https://sebest.github.io/post/protips-using-gunicorn-inside-a-docker-image/

FROM alpine:3.8

ENV GUNICORN_WORKER_CLASS eventlet
ENV GUNICORN_WORKERS 1
ENV GUNICORN_LOGGIN_CONFIG /app/logging.conf
ENV GUNICORN_TIMEOUT 300
ENV GUNICORN_BIND_ADDRESS 0.0.0.0
ENV GUNICORN_BIND_PORT 5000
env GUNICORN_OPTS ""
RUN apk add --no-cache \
            python3 \
            py3-gunicorn \
            python3-dev \
            g++ \
            make \
            libffi-dev \
            libcap \
            musl-dev \
            gcc \
            postgresql-dev

COPY startup.sh /opt/startup.sh
RUN chmod +x /opt/startup.sh

# TODO: add pipfile early
ADD . /app
WORKDIR /app
COPY ./docker_build/logging.conf /app/logging.conf
RUN addgroup -S -g 1337 gunicorn && \
    adduser -S -G gunicorn -u 1337 gunicorn && \
    pip3 install --upgrade pip  && \
    pip3 install pipenv && \
    mkdir -p ./cache && \
    chown gunicorn:gunicorn ./cache

RUN chown gunicorn:gunicorn /opt/startup.sh

RUN pipenv install --system

WORKDIR /app
EXPOSE 5000

USER gunicorn

ENTRYPOINT ["/bin/sh", "/opt/startup.sh"]
