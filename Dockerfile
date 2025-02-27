FROM k8ssandra/cass-management-api:5.0.3-ubi
ENV DEBEZIUM_VERSION=3.0.7.Final \
    MAVEN_CENTRAL="https://repo1.maven.org/maven2" \
    DEBEZIUM_HOME=/debezium
USER root
RUN mkdir $DEBEZIUM_HOME
RUN curl -fSL -o $DEBEZIUM_HOME/debezium-connector-cassandra.jar \
                 $MAVEN_CENTRAL/io/debezium/debezium-connector-cassandra-4/$DEBEZIUM_VERSION/debezium-connector-cassandra-4-$DEBEZIUM_VERSION-jar-with-dependencies.jar
USER cassandra:cassandra