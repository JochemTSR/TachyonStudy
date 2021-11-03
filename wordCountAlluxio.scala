//Simple WordCount script for Spark that outputs the time the job took.
//By Jochem Ram (s2040328)

val startTime = System.nanoTime()
val textFile = sc.textFile("alluxio://10.149.3.6:19998/user/ddps2110/testfile.txt")
val counts = textFile.flatMap(line => line.split(" "))
                 .map(word => (word, 1))
                 .reduceByKey(_ + _)
counts.saveAsTextFile("alluxio://10.149.3.6:19998/user/ddps2110/wordCountResult")
val endTime = System.nanoTime()
println("Elapsed time: " + (endTime - startTime ) / 1000000 + " ms.")
