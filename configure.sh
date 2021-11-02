#!/bin/sh

HADOOP_HOME=${HOME}/scratch/hadoop-3.3.0
ALLUXIO_HOME=${HOME}/scratch/alluxio-2.6.2
SPARK_HOME=${HOME}/scratch/spark-3.2.0-bin-hadoop3.2
NODE_IP_PREFIX=10.149
N_SPECIAL_NODES=3

RESERVE_N=5
RESERVE_T=00:15:00


### Read script arguments
while getopts ":n:" opt; do
	case $opt in
		n)
			if [ $OPTARG -lt $N_SPECIAL_NODES ]; then
				echo: "ERROR: Amount of reserved nodes must >= N_SPECIAL_NODES, exiting..."
				exit_abnormal
			fi
			RESERVE_N=$OPTARG
		;;
	esac
done

### Reserve required amount of nodes
module load prun
reservationID=$(preserve -# $RESERVE_N -t $RESERVE_T | grep number | grep -Eo '[0-9]{1,10}')
sleep 2 #sometimes getting the reservation takes a bit


### Get list of node numbers and extract their IP suffixes, stripping away leading zeroes
#nodeNumberList=$(preserve -llist | grep $reservationID | awk '{$1=$2=$3=$4=$5=$6=$7=$8=""; print $0}'  | awk 'BEGIN { first=1; last=5}{for (i = first;i<last;i++){print $i}print $last}'|grep -Eo '[0-9]{1,3}')
nodeList=$(preserve -llist | grep ddps2110 | tail -1| cut -f 9-)
echo $nodeList

### Populate list of node IPs
for node in $nodeList; do
	nodeNum=${node:4} #Strip the characters 'node'
	temp=${nodeNum::1} #Store the first of the three numbers
	nodeNum=${nodeNum:1:2} #Strip the first of the three numbers
	if [[ ${nodeNum::1} == 0 ]]; then #strip second number if it is zero
		nodeNum=${nodeNum:1}
	fi
	nodeIPList+=(${NODE_IP_PREFIX}.${temp}.${nodeNum})
done
echo "nodeIPList: ${nodeIPList[@]} (done)"


### Determine IP addresses of special nodes
nameNodeIP=${nodeIPList[0]}
alluxioMasterIP=${nodeIPList[1]}
sparkMasterIP=${nodeIPList[2]}


### Set up Hadoop config files(sed command is some real magic)
sed -i "/<name>fs.defaultFS<\/name>/!b;n;c<value>hdfs:\/\/${nameNodeIP}:8020<\/value>" ${HADOOP_HOME}/etc/hadoop/core-site.xml
sed -i "/<name>yarn.resourcemanager.hostname<\/name>/!b;n;c<value>${nameNodeIP}<\/value>" ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
#sed -i "/.*${NODE_IP_PREFIX}.*/c <value>hdfs:\/\/${NODE_IP_PREFIX}$nameNodeIP:8020<\/value>\/" ${HADOOP_HOME}/etc/hadoop/core-site.xml
#sed -i "/.*${NODE_IP_PREFIX}.*/c <value>${NODE_IP_PREFIX}${nameNodeIP}<\/value>" ${HADOOP_HOME}/etc/hadoop/yarn-site.xml


### Clear then populate Hadoop worker file with reserved nodes, except for $N_SPECIAL_NODES
 > ${HADOOP_HOME}/etc/hadoop/workers
for ip in ${nodeIPList[@]:$N_SPECIAL_NODES}; do
	echo "${ip}" >> ${HADOOP_HOME}/etc/hadoop/workers
done


### Set up Alluxio config files
sed -i "/.*alluxio.master.hostname*/c alluxio.master.hostname=${alluxioMasterIP}" ${ALLUXIO_HOME}/conf/alluxio-site.properties
sed -i "/.*alluxio.master.mount.table.root.ufs.*/c alluxio.master.mount.table.root.ufs=hdfs:\/\/${nameNodeIP}" ${ALLUXIO_HOME}/conf/alluxio-site.properties


### Clear then populate Alluxio master and slave files
 > ${ALLUXIO_HOME}/conf/workers
 > ${ALLUXIO_HOME}/conf/masters
echo "${alluxioMasterIP}" >> ${ALLUXIO_HOME}/conf/masters
echo "master ${alluxioMasterIP}"
for ip in ${nodeIPList[@]:${N_SPECIAL_NODES}}; do
     	echo "${ip}" >> ${ALLUXIO_HOME}/conf/workers
done


### Set up Spark config files
sed -i "s/SPARK_MASTER_HOST=.*/SPARK_MASTER_HOST=${sparkMasterIP}/; t; s/^/SPARK_MASTER_HOST=${sparkMasterIP}/" ${SPARK_HOME}/conf/spark-env.sh


### Populate Spark worker file
 > ${SPARK_HOME}/conf/workers
for ip in ${nodeIPList[@]:${N_SPECIAL_NODES}}; do
	echo "${ip}" >> ${SPARK_HOME}/conf/workers
done


### Execute startup scripts
#Execute Hadoop (HDFS+YARN) startup script on namenode
#ssh ddps2110@${nameNodeIP} "~/startHDFS.sh -f"

#Execute Alluxio startup script on Alluxio master
#ssh ddps2110@${alluxioMasterIP} "~/startAlluxio.sh"

# Execute Spark startup script on spark master
#ssh ddps2110@${sparkMasterIP} "~/startSpark.sh"


### Echo information
echo "Successfully initialized cluster consisting of ${RESERVE_N} nodes"
echo "HDFS NameNode: ${nameNodeIP}"
echo "Alluxio master: ${alluxioMasterIP}"
echo "Spark master: ${sparkMasterIP}"
