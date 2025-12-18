FROM postgres:17-alpine3.19
LABEL authors="chipp"

RUN apk update && apk add --no-cache bash curl postgresql-client

COPY crontab /etc/crontabs/root

COPY pgpass /root/.pgpass
RUN chmod 600 /root/.pgpass

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
