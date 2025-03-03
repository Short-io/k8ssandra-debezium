FROM eclipse-temurin:17-jre-alpine

# Set environment variables
ENV DEBEZIUM_VERSION=3.0.7.Final
ENV DEBEZIUM_CONNECTOR_CASSANDRA_JAR=debezium-connector-cassandra-5-${DEBEZIUM_VERSION}-jar-with-dependencies.jar
ENV MAVEN_CENTRAL=https://repo1.maven.org/maven2/io/debezium/debezium-connector-cassandra-5/$DEBEZIUM_VERSION

# Install necessary dependencies
RUN apk add --no-cache curl

# Set working directory
WORKDIR /opt/debezium

# Download Debezium Cassandra Connector JAR
RUN mkdir -p /opt/debezium && curl -L -o /opt/debezium/debezium-connector-jar-with-dependencies.jar $MAVEN_CENTRAL/$DEBEZIUM_CONNECTOR_CASSANDRA_JAR

# Expose Kafka Connect REST API port
EXPOSE 8083

COPY <<EOF /usr/share/nginx/html/index.html
(your index page goes here)
EOF

# Run the Cassandra connector
CMD ["sh", "-c", "cat /config/cassandra.yaml | grep -v batchlog_endpoint_strategy > /config/cassandra-debezium.yaml && echo \"hints_directory: /var/lib/cassandra/hints\ncommitlog_directory: /var/lib/cassandra/commitlog/\" >> /config/cassandra-debezium.yaml && java --add-exports java.base/jdk.internal.misc=ALL-UNNAMED --add-exports java.base/jdk.internal.ref=ALL-UNNAMED --add-exports java.base/sun.nio.ch=ALL-UNNAMED --add-exports java.management.rmi/com.sun.jmx.remote.internal.rmi=ALL-UNNAMED --add-exports java.rmi/sun.rmi.registry=ALL-UNNAMED --add-exports java.rmi/sun.rmi.server=ALL-UNNAMED --add-exports java.sql/java.sql=ALL-UNNAMED --add-opens java.base/java.lang.module=ALL-UNNAMED --add-opens java.base/jdk.internal.loader=ALL-UNNAMED --add-opens java.base/jdk.internal.ref=ALL-UNNAMED --add-opens java.base/jdk.internal.reflect=ALL-UNNAMED --add-opens java.base/jdk.internal.math=ALL-UNNAMED --add-opens java.base/jdk.internal.module=ALL-UNNAMED --add-opens java.base/jdk.internal.util.jar=ALL-UNNAMED --add-opens=java.base/sun.nio.ch=ALL-UNNAMED --add-opens jdk.management/com.sun.management.internal=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED -jar /opt/debezium/debezium-connector-jar-with-dependencies.jar /etc/debezium/debezium.conf"]
