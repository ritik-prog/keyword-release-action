FROM alpine/git:v2.26.2

RUN apk update && \
        apk add --no-cache \
        bash \
        httpie \
        jq \
        which bash && \
        which http && \
        which jq

RUN wget https://github.com/cli/cli/releases/download/v1.0.0/gh_1.0.0_linux_386.tar.gz -O ghcli.tar.gz
RUN tar --strip-components=1 -xf ghcli.tar.gz

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY sample_push_event.json /sample_push_event.json

# Make entrypoint script executable
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
