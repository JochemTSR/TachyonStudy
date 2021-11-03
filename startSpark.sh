#!/bin/sh
# To be run on Spark master node. Starts master daemon on current node and
# worker daemons on all worker nodes
# By Jochem Ram (s2040328)

SPARK_HOME=~/scratch/spark-3.2.0-bin-hadoop3.2

### Start all daemons
${SPARK_HOME}/sbin/start-all.sh
