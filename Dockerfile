# blacktail

FROM alpine:3.4
MAINTAINER Sven M. Resch <sven.resch@beanstream.com>

# Install platform dependencies & setup flask application
RUN mkdir -p /deploy/app
COPY testrunner.sh /deploy/
ADD app /deploy/app/

RUN apk add --no-cache --update python3 \
  && python3 -m ensurepip \
  && rm -rf /usr/lib/python*/ensurepip \
  && rm -rf /root/.cache \
  && apk add --no-cache --update \
     build-base python3-dev \
     nginx supervisor \
  && pip3 install --upgrade pip \
  && pip3 install virtualenv gunicorn \
  && pip3 install -r /deploy/app/requirements.txt \
  && apk del \
    build-base python3-dev \
  && apk add logrotate \
  && rm -rf /var/cache/apk/*

# Setup nginx
RUN mkdir -p /run/nginx \
  && mkdir -p /etc/nginx/sites-available \
  && mkdir /etc/nginx/sites-enabled \
  && rm -f /etc/nginx/sites-enabled/default
COPY flask.conf /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/flask.conf /etc/nginx/sites-enabled/flask.conf
COPY nginx.conf /etc/nginx/nginx.conf

# Setup supervisord
RUN mkdir -p /var/log/supervisor/conf.d
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Start processes
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
