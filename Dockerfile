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

COPY <<EOF /docker-init.sh
cat /config/cassandra.yaml | sed 's/GossipingPropertyFileSnitch/SimpleSnitch/' | grep -v batchlog_endpoint_strategy > /config/cassandra-debezium.yaml
nc -vz -w 2 127.0.0.1 7000
exec $@
EOF

RUN chmod +x /docker-init.sh
ENTRYPOINT /docker-init.sh
# Run the Cassandra connector
CMD [ \
  "java", "--add-exports", "java.base/jdk.internal.misc=ALL-UNNAMED", "--add-exports", "java.base/jdk.internal.ref=ALL-UNNAMED", "--add-exports", "java.base/sun.nio.ch=ALL-UNNAMED", "--add-exports", "java.management.rmi/com.sun.jmx.remote.internal.rmi=ALL-UNNAMED", "--add-exports", "java.rmi/sun.rmi.registry=ALL-UNNAMED", "--add-exports", "java.rmi/sun.rmi.server=ALL-UNNAMED", "--add-exports", "java.sql/java.sql=ALL-UNNAMED", "--add-opens", "java.base/java.lang.module=ALL-UNNAMED", "--add-opens", "java.base/jdk.internal.loader=ALL-UNNAMED", "--add-opens", "java.base/jdk.internal.ref=ALL-UNNAMED", "--add-opens", "java.base/jdk.internal.reflect=ALL-UNNAMED", "--add-opens", "java.base/jdk.internal.math=ALL-UNNAMED", "--add-opens", "java.base/jdk.internal.module=ALL-UNNAMED", "--add-opens", "java.base/jdk.internal.util.jar=ALL-UNNAMED", "--add-opens=java.base/sun.nio.ch=ALL-UNNAMED", "--add-opens", "jdk.management/com.sun.management.internal=ALL-UNNAMED", "--add-opens=java.base/java.io=ALL-UNNAMED", \
  "-Dcassandra.storagedir=/var/lib/cassandra", "-Dlog4j.rootLogger=INFO, stdout, file", \
  "-jar", "/opt/debezium/debezium-connector-jar-with-dependencies.jar", "/etc/debezium/debezium.conf" \
  ]
