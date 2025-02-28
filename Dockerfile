FROM eclipse-temurin:17-jre-alpine

# Set environment variables
ENV DEBEZIUM_VERSION=3.0.7.Final
ENV DEBEZIUM_CONNECTOR_CASSANDRA_JAR=debezium-connector-cassandra-5-$DEBEZIUM_VERSION-jar-with-dependencies.jar
ENV MAVEN_CENTRAL=https://repo1.maven.org/maven2/io/debezium/debezium-connector-cassandra-5/$DEBEZIUM_VERSION

# Install necessary dependencies
RUN apk add --no-cache curl

# Set working directory
WORKDIR /opt/debezium

# Download Debezium Cassandra Connector JAR
RUN curl -L -o $DEBEZIUM_CONNECTOR_CASSANDRA_JAR $MAVEN_CENTRAL/$DEBEZIUM_CONNECTOR_CASSANDRA_JAR \
    && mkdir -p /opt/debezium/plugins

# Move JAR file to plugins directory
RUN mv $DEBEZIUM_CONNECTOR_CASSANDRA_JAR /opt/debezium/plugins/

# Expose Kafka Connect REST API port
EXPOSE 8083

# Run the Cassandra connector
CMD ["java", "-cp", "/opt/debezium/plugins/*", "io.debezium.connector.cassandra.CassandraConnector"]
