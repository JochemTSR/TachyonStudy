#!/bin/sh

HADOOP_HOME=${HOME}/scratch/hadoop-3.3.0
ALLUXIO_HOME=${HOME}/scratch/alluxio-2.6.2
NODE_IP_PREFIX=10.149.
N_SPECIAL_NODES=2

RESERVE_N=5
RESERVE_T=00:15:00


### Reserve required amount of nodes
module load prun
reservationID=$(preserve -# $RESERVE_N -t $RESERVE_T | grep number | grep -Eo '[0-9]{1,10}')
sleep 2 #sometimes getting the reservation takes a bit


### Get list of node numbers and extract their IP suffixes, stripping away leading zeroes
nodeNumberList=$(preserve -llist | grep $reservationID | awk '{$1=$2=$3=$4=$5=$6=$7=$8=""; print $0}'  | awk 'BEGIN { first=1; last=5}{for (i = first;i<last;i++){print $i}print $last}'|grep -Eo '[0-9]{1,3}')
for val in $nodeNumberList; do
	temp=${val::1}
	val=${val:1:2} #strip first number
	if [ ${val::1} = '0' ]; then #strip second number if it is zero
		val=${val:1}
	fi
	nodeIPList+=(${temp}.${val})
done
echo "nodeIPList: ${nodeIPList[@]} (done)"


### Determine IP addresses of special nodes
nameNodeIP=${nodeIPList[0]}
masterNodeIP=${nodeIPList[1]}


### Set up Hadoop config files(sed command is some real magic)
sed -i "/.*${NODE_IP_PREFIX}.*/c <value>hdfs:\/\/${NODE_IP_PREFIX}$nameNodeIP:8020<\/value>\/" ${HADOOP_HOME}/etc/hadoop/core-site.xml
sed -i "/.*${NODE_IP_PREFIX}.*/c <value>${NODE_IP_PREFIX}${nameNodeIP}<\/value>" ${HADOOP_HOME}/etc/hadoop/yarn-site.xml


### Clear then populate Hadoop worker file with reserved nodes, except for $N_SPECIAL_NODES
 > ${HADOOP_HOME}/etc/hadoop/workers
for ip in ${nodeIPList[@]:$N_SPECIAL_NODES}; do
	echo "${NODE_IP_PREFIX}${ip}">>${HADOOP_HOME}/etc/hadoop/workers
done


### Set up Alluxio config files
sed -i "/.*alluxio.master.hostname*/c alluxio.master.hostname=${NODE_IP_PREFIX}${masterNodeIP}" ${ALLUXIO_HOME}/conf/alluxio-site.properties
sed -i "/.*alluxio.master.mount.table.root.ufs.*/c alluxio.master.mount.table.root.ufs=hdfs:\/\/${NODE_IP_PREFIX}${nameNodeIP}" ${ALLUXIO_HOME}/conf/alluxio-site.properties


### Clear then populate Alluxio master and slave files
 > /home/ddps2110/scratch/alluxio-2.6.2/conf/workers
 > /home/ddps2110/scratch/alluxio-2.6.2/conf/masters
echo "${NODE_IP_PREFIX}${masterNodeIP}">>/home/ddps2110/scratch/alluxio-2.6.2/conf/masters
echo "master ${NODE_IP_PREFIX}${masterNodeIP}"
for ip in ${nodeIPList[@]:$N_SPECIAL_NODES}; do
     	echo "${NODE_IP_PREFIX}${ip}">>/home/ddps2110/scratch/alluxio-2.6.2/conf/workers
	echo "slave ${NODE_IP_PREFIX}${ip}"
done


### Execute master script on HDFS namenode
ssh ddps2110@${NODE_IP_PREFIX}${nameNodeIP} "~/startHDFS.sh -f"


#Uncomment the below line to start alluxio
ssh ddps2110@${NODE_IP_PREFIX}${masterNodeIP} "~/startAlluxio.sh"