FROM alpine

RUN apk update && \
        apk add --no-cache \
        bash \
        httpie \
        jq \
        gh && \
        which bash && \
        which http && \
        which jq && \
        which gh

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY sample_push_event.json /sample_push_event.json

# Make entrypoint script executable
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
