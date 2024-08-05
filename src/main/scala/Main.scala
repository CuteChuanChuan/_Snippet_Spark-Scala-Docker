import org.apache.spark.sql.SparkSession

object Main {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession.builder
      .appName("WordCount")
      .master("local[*]")
      .getOrCreate()
    
    val sc = spark.sparkContext
    
    val inputFile = "data/input.txt"
    val textFile = sc.textFile(inputFile)
    
    val counts = textFile.flatMap(line => line.split(" "))
      .map(word => (word, 1))
      .reduceByKey(_ + _)
    
    counts.collect().foreach(println)
    
    spark.stop()
  }
}
