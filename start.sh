#!/bin/bash

# Connect with Jenkins master and start
echo "command: java -jar /opt/slave.jar -jnlpUrl $1 -secret $2"
java -jar /opt/slave.jar \
     -jnlpUrl $1 \
     -secret $2
