FROM alpine

RUN apk add --no-cache \
        bash           \
        httpie         \
        jq             \
        curl           \
        which bash &&  \
        which http &&  \
        which jq &&    \
        which curl &&  \
        curl -L "https://github.com/cli/cli/releases/download/v2.5.1/gh_2.5.1_linux_amd64.tar.gz" | tar -xz -C /usr/local/bin --strip-components=1 gh_2.5.1_linux_amd64/bin/gh && \
        which gh

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY sample_push_event.json /sample_push_event.json

# Make entrypoint script executable
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
