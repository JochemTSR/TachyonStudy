#!/bin/sh
# Stops all HDFS and YARN daemons in a cluster.
# To be run from master node.

HADOOP_HOME=~/scratch/hadoop-3.3.0

### Stop HDFS and YARN daemons
${HADOOP_HOME}/sbin/stop-dfs.sh
${HADOOP_HOME}/sbin/stop-yarn.sh
