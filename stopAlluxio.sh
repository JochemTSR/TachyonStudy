#!/bin/sh
# Stop all Alluxio daemons in a cluster. 
# To be run from master node.

ALLUXIO_HOME=~/scratch/alluxio-2.6.2/

### Stop all Alluxio daemons
${ALLUXIO_HOME}/bin/alluxio-stop.sh all
