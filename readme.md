ConfigureCluster.sh [-n num_nodes] [-t [[hh:]mm:]ss hours, minutes, seconds
Reserves num_nodes and prepares them to run HDFS, Spark and Alluxio

startHDFS.sh [-f] [-r], startSpark.sh and startAlluxio.sh start these services. They should be run from their namenode/master node. 
Idem for the stop scripts. (except that these stop the services, of course)

To benchmark HDFS performance, run benchHDFS on the HDFS namenode.
To benchmark Alluxio performance. run benchAlluxio on Alluxio master node.
wordCountAlluxio and wordCountHDFS can be used to measure wordcount execution times on respective filesystems.

the exampleConfigs folder contains some example configuration files that (and I cannot emphasize this enough) MIGHT work
on your configuration. Hopefully they at least are useful as a starting point.

Godspeed,
Jochem Ram
