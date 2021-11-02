#!/bin/sh
# Script that benchmarks filesystem performance of memHDFS compared to Alluxio.
# Should be run from namenode of running HDFS cluster

HADOOP_HOME=~/scratch/hadoop-3.3.0
HADOOP_PORT=8020
ALLUXIO_PORT=19998
N_REPEATS=10
N_FILES=16
WRITE_SIZE=1GB
HDFS_OUT_FILE=~/dfsio_hfds.txt


### Stop HDFS and YARN daemons if running
./stopHDFS.sh


### Edit config file to use HDFS filesystem
sed -i "s/<value>alluxio:\/\//<value>hdfs:\/\//" ${HADOOP_HOME}/etc/hadoop/core-site.xml
sed -i "s/${ALLUXIO_PORT}/${HADOOP_PORT}/" ${HADOOP_HOME}/etc/hadoop/core-site.xml


### Start HDFS under Ramdisk and YARN daemons
./startHDFS.sh -f -r


### Run benchmark from all workers
for i in $(seq 0 $N_REPEATS); do
	echo "Benchmark run ${i}" >> $HDFS_OUT_FILE
	${HADOOP_HOME}/bin/hadoop jar ${HADOOP_HOME}/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.3.0-tests.jar TestDFSIO -write -nrFiles $N_FILES -fileSize $WRITE_SIZE -resfile $HDFS_OUT_FILE
	echo "" >> $HDFS_OUT_FILE	
done
