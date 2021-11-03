#!/bin/sh
# To be run on Spark master node
# Starts master daemon on current node and
# worker daemons on all worker nodes

SPARK_HOME=~/scratch/spark-3.2.0-bin-hadoop3.2

### Start all daemons
${SPARK_HOME}/sbin/stop-all.sh
