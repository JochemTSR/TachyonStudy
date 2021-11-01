#!/bin/sh
# Script that benchmarks filesystem performance of memHDFS compared to Alluxio.
# Should be run from namenode of running HDFS+YARN+Alluxio cluster.

ALLUXIO_HOME=~/scratch/alluxio-2.6.2
HADOOP_HOME=~/scratch/hadoop-3.3.0
ALLUXIO_PORT=19998
HADOOP_PORT=8020
N_FILES_PER_NODE=32
WRITE_SIZE=1GB

HDFS_OUT_FILE=~/dfsio_hfds.txt
ALLUXIO_OUT_FILE=~/dfsio_alluxio.txt

### Bench the performance on MemHDFS...
# Stop HDFS and YARN daemons if running
./stopHDFS.sh

# Edit config file to use HDFS filesystem
#sed -i "/<name>fs.defaultFS<\/name>/!b;n;c<value>hdfs:\/\/${nameNodeIP}:8020<\/value>" ${HADOOP_HOME}/etc/hadoop/core-site.xml 
sed -i "s/<value>alluxio:\/\//<value>hdfs:\/\//" ${HADOOP_HOME}/etc/hadoop/core-site.xml
sed -i "s/${ALLUXIO_PORT}/${HADOOP_PORT}/" ${HADOOP_HOME}/etc/hadoop/core-site.xml
# Start HDFS under Ramdisk and YARN daemons
#./startHDFS.sh -f -r
./startHDFS.sh -f

# Run benchmark from all workers
> $HDFS_OUT_FILE
#${HADOOP_HOME}/sbin/workers.sh "${HADOOP_HOME}/bin/hadoop jar ${HADOOP_HOME}/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.3.0-tests.jar TestDFSIO -write -nrFiles $N_FILES_PER_NODE -fileSize $WRITE_SIZE -resfile $HDFS_OUT_FILE" 
${HADOOP_HOME}/bin/hadoop jar ${HADOOP_HOME}/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.3.0-tests.jar TestDFSIO -write -nrFiles $N_FILES_PER_NODE -fileSize $WRITE_SIZE -resfile $HDFS_OUT_FILE

### ...Then bench the performance on Alluxio
# Stop HDFS, YARN and Alluxio daemons if running
./stopHDFS.sh
./stopAlluxio.sh

# Edit Hadoop configuration file to use Alluxio filesystem
#sed -i "/<name>fs.defaultFS<\/name>/!b;n;c<value>alluxio:\/\/${nameNodeIP}:8020<\/value>/" ${HADOOP_HOME}/etc/hadoop/core-site.xml 
sed -i "s/<value>hdfs:\/\//<value>alluxio:\/\//" ${HADOOP_HOME}/etc/hadoop/core-site.xml
sed -i "s/${HADOOP_PORT}/${ALLUXIO_PORT}/" ${HADOOP_HOME}/etc/hadoop/core-site.xml
# Start HDFS, YARN and Alluxio daemons
./startHDFS.sh -f
./startAlluxio.sh

# Add Alluxio client jar to Hadoop classpath
export HADOOP_CLASSPATH=${ALLUXIO_HOME}/client/alluxio-2.6.2-client.jar:${HADOOP_CLASSPATH}

# Run the benchmark from all workers
> $ALLUXIO_OUT_FILE
# ${HADOOP_HOME}/sbin/workers.sh "${HADOOP_HOME}/bin/hadoop jar ${HADOOP_HOME}/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.3.0-tests.jar TestDFSIO -write -nrFiles $N_FILES_PER_NODE -fileSize $WRITE_SIZE -resfile $ALLUXIO_OUT_FILE \
# -libjars ${ALLUXIO_HOME}/client/alluxio-2.6.2-client.jar"
${HADOOP_HOME}/bin/hadoop jar ${HADOOP_HOME}/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.3.0-tests.jar TestDFSIO -Dalluxio.user.file.writetype.default=MUST_CACHE -libjars ${ALLUXIO_HOME}/client/alluxio-2.6.2-client.jar -write -nrFiles $N_FILES_PER_NODE -fileSize $WRITE_SIZE -resfile $ALLUXIO_OUT_FILE
