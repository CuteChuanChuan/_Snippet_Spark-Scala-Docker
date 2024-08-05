#!/bin/bash

sbt clean assembly

if [ $? -ne 0 ]; then
  echo "sbt assembly failed"
  exit 1
fi

JAR_FILE=$(ls target/scala-2.12/*.jar | grep -v 'sources.jar' | grep -v 'javadoc.jar')
if [ -z "$JAR_FILE" ]; then
  echo "No JAR file found in target/scala-2.12/"
  exit 1
fi
echo "Detected JAR file: $JAR_FILE"

function container_exists {
  docker ps -a --filter "name=$1" | grep -q "$1"
}
if container_exists spark-master; then
  echo "Container spark-master already exists, using the existing container."
else
  echo "Container spark-master does not exist, starting with docker-compose."
  docker-compose up -d

  if [ $? -ne 0 ]; then
    echo "Docker Compose up failed"
    exit 1
  fi
fi

docker cp "$JAR_FILE" spark-master:/opt/bitnami/spark/data/

if [ $? -ne 0 ]; then
  echo "Copying JAR file failed"
  exit 1
fi

docker cp ./input.txt spark-master:/opt/bitnami/spark/data/

if [ $? -ne 0 ]; then
  echo "Copying input file failed"
  exit 1
fi

docker cp ./src/main/resources/log4j.properties spark-master:/opt/bitnami/spark/conf/log4j.properties


docker exec -it spark-master /opt/bitnami/spark/bin/spark-submit \
  --class Main \
  --master spark://spark-master:7077 \
  --conf "spark.driver.extraJavaOptions=-Dlog4j.configuration=file:/opt/bitnami/spark/conf/log4j.properties" \
  --conf "spark.executor.extraJavaOptions=-Dlog4j.configuration=file:/opt/bitnami/spark/conf/log4j.properties" \
  /opt/bitnami/spark/data/Spark-Scala-Docker-assembly-0.1.0-SNAPSHOT.jar

if [ $? -ne 0 ]; then
  echo "Spark job submission failed"
  exit 1
fi

echo "Script executed successfully"
