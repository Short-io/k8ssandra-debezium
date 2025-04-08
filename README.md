# k8ssandra-debezium

Debezium sidecar for k8ssandra. Example K8ssandra cluster CRD:

```yaml
    apiVersion: k8ssandra.io/v1alpha1
    kind: K8ssandraCluster
    metadata:
      name: example
      namespace: k8ssandra-operator
    spec:
      auth: true
      cassandra:
        config:
          cassandraYaml:
            cdc_enabled: true
        datacenters:
        - containers:
          - image: ghcr.io/short-io/k8ssandra-debezium:v0.1.0
            imagePullPolicy: IfNotPresent
            name: debezium
            ports:
            - containerPort: 8083
              name: debezium-http
              protocol: TCP
            resources:
              requests:
                cpu: 250m
                memory: 512Mi
            volumeMounts:
            - mountPath: /var/lib/cassandra
              name: server-data
            - mountPath: /config
              name: server-config
            - mountPath: /etc/debezium
              name: debezium-credentials
          extraVolumes:
            volumes:
            - name: debezium-credentials
              secret:
                secretName: debezium-credentials
          metadata:
            name: us
          serverVersion: 5.0.3
```

It also needs to have debezium config mounted to /etc/debezium via secret or configmap.

Here is example secret:

```yaml
apiVersion: v1
stringData:
  application.conf: |
    datastax-java-driver {
      advanced.auth-provider {
          class = PlainTextAuthProvider
          username = cassandra-user
          password = cassandra-password
      }
    }
  debezium.conf: |
    connector.name=links_connector
    commit.log.relocation.dir=/var/lib/cassandra/debezium/relocation/
    http.port=8000
    
    cassandra.config=/config/cassandra-debezium.yaml
    cassandra.driver.config.file=/etc/debezium/application.conf
    cassandra.hosts=127.0.0.1
    cassandra.port=9042
    
    kafka.producer.bootstrap.servers=kafka.default.svc.cluster.local:9093
    kafka.producer.security.protocol=SASL_SSL
    kafka.producer.ssl.endpoint.identification.algorithm=
    kafka.producer.sasl.mechanism=SCRAM-SHA-512
    kafka.producer.ssl.truststore.type=PEM
    kafka.producer.sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username="debezium" password="debezium-password";
    kafka.producer.retries=3
    kafka.producer.retry.backoff.ms=1000
    kafka.producer.compression.type=gzip
    topic.prefix=debezium
    
    key.converter=org.apache.kafka.connect.json.JsonConverter
    value.converter=org.apache.kafka.connect.json.JsonConverter
    key.converter.schemas.enable=false
    value.converter.schemas.enable=false
    offset.backing.store.dir=/var/lib/cassandra/debezium/offsets
    
    snapshot.consistency=ONE
    snapshot.mode=NEVER
  exporter.yaml: |
    rules:
    - pattern: ".*"
kind: Secret
metadata:
  name: debezium-credentials
  namespace: k8ssandra-operator
type: Opaque
```
