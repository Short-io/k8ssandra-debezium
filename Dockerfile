FROM cassandra:5.0

# Set environment variables
ENV DEBEZIUM_VERSION=3.0.7.Final
ENV DEBEZIUM_CONNECTOR_CASSANDRA_JAR=debezium-connector-cassandra-5-${DEBEZIUM_VERSION}-jar-with-dependencies.jar
ENV MAVEN_CENTRAL=https://repo1.maven.org/maven2/io/debezium/debezium-connector-cassandra-5/$DEBEZIUM_VERSION
RUN set -eux;     apt-get update;     DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends  openssl netcat; rm -rf /var/lib/apt/lists/* # buildkit
# Set working directory
WORKDIR /opt/debezium

# Download Debezium Cassandra Connector JAR
RUN mkdir -p /opt/debezium && curl -L -o /opt/debezium/debezium-connector-jar-with-dependencies.jar $MAVEN_CENTRAL/$DEBEZIUM_CONNECTOR_CASSANDRA_JAR
RUN ln -sf /config /opt/cassandra/conf && ln -sf /config /etc/cassandra
# Expose Kafka Connect REST API port
EXPOSE 8083

COPY <<EOF /docker-entrypoint.sh
#!/bin/bash
cat /config/cassandra.yaml | sed 's/GossipingPropertyFileSnitch/SimpleSnitch/' | grep -v batchlog_endpoint_strategy > /config/cassandra-debezium.yaml
while ! nc -v -z 127.0.0.1 9042; do   
  sleep 1
done
exec "\$@"
EOF

COPY run-script.sh /run-script.sh

RUN chmod +x /docker-entrypoint.sh /run-script.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
# Run the Cassandra connector
CMD ["/run-script.sh"]
