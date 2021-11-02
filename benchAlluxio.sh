#!/bin/sh
# Script that benchmarks filesystem performance of memHDFS compared to Alluxio.
# Should be run from namenode of running HDFS cluster

ALLUXIO_HOME=~/scratch/alluxio-2.6.2
ALLUXIO_PORT=19998
N_FILES=64
WRITE_SIZE=1GB
ALLUXIO_OUT_FILE=~/dfsio_alluxio.txt


### Stop HDFS, YARN and Alluxio daemons if running
./stopHDFS.sh
./stopAlluxio.sh


### Edit Hadoop configuration file to use Alluxio filesystem
sed -i "s/<value>hdfs:\/\//<value>alluxio:\/\//" ${HADOOP_HOME}/etc/hadoop/core-site.xml
sed -i "s/${HADOOP_PORT}/${ALLUXIO_PORT}/" ${HADOOP_HOME}/etc/hadoop/core-site.xml


### Start HDFS, YARN and Alluxio daemons
./startHDFS.sh -f
./startAlluxio.sh


### Add Alluxio client jar to Hadoop classpath
export HADOOP_CLASSPATH=${ALLUXIO_HOME}/client/alluxio-2.6.2-client.jar:${HADOOP_CLASSPATH}


### Run the benchmark from all workers
${HADOOP_HOME}/bin/hadoop jar ${HADOOP_HOME}/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.3.0-tests.jar TestDFSIO -Dalluxio.user.file.writetype.default=MUST_CACHE -libjars ${ALLUXIO_HOME}/client/alluxio-2.6.2-client.jar -write -nrFiles $N_FILES -fileSize $WRITE_SIZE -resfile $ALLUXIO_OUT_FILE
