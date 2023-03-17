FROM debian:latest

# Install dependencies
RUN apt-get update && \
        apt-get install -y \
        bash \
        httpie \
        jq \
        gnupg \
        lsb-release \
        curl

# Install gh CLI
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0 && \
        echo "deb https://cli.github.com/packages $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/github-cli.list && \
        apt-get update && \
        apt-get install gh

# Copy entrypoint script and sample push event
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY sample_push_event.json /sample_push_event.json

# Make entrypoint script executable
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
