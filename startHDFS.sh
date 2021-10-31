#!/bin/sh
HADOOP_HOME=${HOME}/scratch/hadoop-3.3.0
NAMENODE_DATA_PATH=/local/ddps2110/namenode_data
DATANODE_DATA_PATH=/local/ddps2110/datanode_data
#NAMENODE_DATA_PATH=/local/ddps2110
#DATANODE_DATA_PATH=/local/ddps2110

#DATANODE_DISK_DATADIR=/local/ddps2110/namenode_data_dir
#DATANODE_RAM_DATADIR=/dev/shm/ddps2110_ramdisk/datanode_data_dir
DATANODE_DISK_DATADIR=/local/ddps2110/data/datanode_data
DATANODE_RAM_DATADIR=/dev/shm/ddps2110_ramdisk/datanode_data


### Create datanode data directories on disk
function create_disk_data {
	${HADOOP_HOME}/sbin/workers.sh "mkdir -p $DATANODE_DISK_DATADIR"
	${HADOOP_HOME}/sbin/workers.sh "ln -snf $DATANODE_DISK_DATADIR $DATANODE_DATA_PATH"
}


### Create datanode data directories on RAM
function create_ram_data {
	${HADOOP_HOME}/sbin/workers.sh "mkdir -p $DATANODE_RAM_DATADIR"
	${HADOOP_HOME}/sbin/workers.sh "ln -snf $DATANODE_RAM_DATADIR $DATANODE_DATA_PATH"
}


### Delete old filesystem and format a new one
function format {
	${HADOOP_HOME}/sbin/workers.sh "rm -rf $DATANODE_DISK_DATADIR $DATANODE_RAM_DATADIR"
	${HADOOP_HOME}/sbin/workers.sh "rm -rf $NAMENODE_DATA_PATH $DATANODE_DATA_PATH"
	#${HADOOP_HOME}/sbin/workers.sh "rm -r /local/ddps2110/data/datanode_data"
	echo "Y" | ${HADOOP_HOME}/bin/hdfs namenode -format
}


### Create namenode data directory
mkdir -p $NAMENODE_DATA_PATH

### Parse options
ramdisk=0
while getopts ":rf" opt; do
	case $opt in
		r)
			ramdisk=1
		;;
		f)
			format
		;;
	esac
done

if [ $ramdisk -eq 1 ]; then
	create_ram_data
else
	create_disk_data
fi

# Start namenode and datanodes
${HADOOP_HOME}/sbin/start-dfs.sh

# Start YARN resource manager and nodemanagers
${HADOOP_HOME}/sbin/start-yarn.sh
