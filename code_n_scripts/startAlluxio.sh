#!/bin/bash
# Start Alluxio master daemon on this node and worker
# daemons on all worker nodes
# By Jochem Ram (s2040328)

ALLUXIO_HOME=${HOME}/scratch/alluxio-2.6.2
SLAVE_DATA_DIR=/dev/shm/ddps2110_ramdisk/alluxio


### Create data directory on slave nodes
${ALLUXIO_HOME}/bin/alluxio-workers.sh mkdir -p ${SLAVE_DATA_DIR}

### Echo classpath for debugging
echo $CLASSPATH

### Start Alluxio master and slaves
${ALLUXIO_HOME}/bin/alluxio-start.sh all Mount -f
