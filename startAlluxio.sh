#!/bin/bash
ALLUXIO_HOME=${HOME}/scratch/alluxio-2.6.2
SLAVE_DATA_DIR=/dev/shm/ddps2110_ramdisk/alluxio


### Create data directory on slave nodes
${ALLUXIO_HOME}/bin/alluxio-workers.sh /bin/mkdir -p ${SLAVE_DATA_DIR}
${ALLUXIO_HOME}/bin/alluxio-workers.sh /bin/echo HELLO

### Start Alluxio master and slaves
${ALLUXIO_HOME}/bin/alluxio-start.sh all Mount
