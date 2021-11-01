#!/bin/sh

HADOOP_HOME=${HOME}/scratch/hadoop-3.3.0
ALLUXIO_HOME=${HOME}/scratch/alluxio-2.6.2
NODE_IP_PREFIX=10.149
N_SPECIAL_NODES=1

RESERVE_N=33
RESERVE_T=00:15:00


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
masterNodeIP=${nodeIPList[0]}


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
sed -i "/.*alluxio.master.hostname*/c alluxio.master.hostname=${masterNodeIP}" ${ALLUXIO_HOME}/conf/alluxio-site.properties
sed -i "/.*alluxio.master.mount.table.root.ufs.*/c alluxio.master.mount.table.root.ufs=hdfs:\/\/${nameNodeIP}" ${ALLUXIO_HOME}/conf/alluxio-site.properties


### Clear then populate Alluxio master and slave files
 > /home/ddps2110/scratch/alluxio-2.6.2/conf/workers
 > /home/ddps2110/scratch/alluxio-2.6.2/conf/masters
echo "${masterNodeIP}" >> /home/ddps2110/scratch/alluxio-2.6.2/conf/masters
echo "master ${masterNodeIP}"
for ip in ${nodeIPList[@]:$N_SPECIAL_NODES}; do
     	echo "${ip}" >> /home/ddps2110/scratch/alluxio-2.6.2/conf/workers
	echo "slave ${ip}"
done


### Execute master script on HDFS namenode
#ssh ddps2110@${nameNodeIP} "~/startHDFS.sh -f"


#Uncomment the below line to start alluxio
#ssh ddps2110@${masterNodeIP} "~/startAlluxio.sh"
