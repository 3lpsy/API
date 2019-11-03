# Largely taken from https://sebest.github.io/post/protips-using-gunicorn-inside-a-docker-image/

FROM alpine:3.10

# alternatively could be flask
ENV GUNICORN_SERVER gunicorn 
ENV GUNICORN_WORKER_CLASS eventlet
ENV GUNICORN_WORKERS 1
ENV GUNICORN_LOGGIN_CONFIG /app/logging.conf
ENV GUNICORN_TIMEOUT 300
ENV GUNICORN_BIND_ADDRESS 0.0.0.0
ENV GUNICORN_BIND_PORT 5000
ENV GUNICORN_DEBUG 0
ENV GUNICORN_RELOAD 0
ENV GUNICORN_OPTS ""

# removed, put in pipenv py3-gunicorn \

RUN apk add --no-cache \
            python3 \
            python3-dev \
            g++ \
            make \
            libffi-dev \
            libcap \
            musl-dev \
            gcc \
            postgresql-dev 

RUN ln -s /usr/bin/python3 /usr/bin/python
COPY startup.sh /opt/startup.sh
RUN chmod +x /opt/startup.sh
RUN mkdir /app
COPY Pipfile /app/Pipfile
COPY Pipfile.lock /app/Pipfile.lock

# TODO: add pipfile early, otherwise any changes to files cause pipenv to retrigger?
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

ADD . /app
RUN chmod +x /app/app.py

WORKDIR /app
EXPOSE 5000

USER gunicorn

ENTRYPOINT ["/bin/sh", "/opt/startup.sh"]
