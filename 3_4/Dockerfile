FROM docker:27-cli
RUN apk add --no-cache git bash
COPY builder.sh /usr/local/bin/builder.sh
RUN chmod +x /usr/local/bin/builder.sh
ENTRYPOINT ["/usr/local/bin/builder.sh"]
