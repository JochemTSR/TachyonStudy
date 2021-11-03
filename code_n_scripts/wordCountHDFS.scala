//Simple WordCount Spark job that measures the execution time.
//By Jochem Ram (s2040328)

val startTime = System.nanoTime()
val textFile = sc.textFile("hdfs://10.149.3.6/user/ddps2110/testfile.txt")
val counts = textFile.flatMap(line => line.split(" "))
                 .map(word => (word, 1))
                 .reduceByKey(_ + _)
counts.saveAsTextFile("hdfs://10.149.3.6/user/ddps2110/wordCountResult")
val endTime = System.nanoTime()
println("Elapsed time: " + (endTime - startTime ) / 1000000 + " ms.")
