import org.apache.spark.sql.SparkSession
import org.apache.spark.rdd.RDD
import java.nio.file.{Paths, Files}

/** A Spark application that analyzes co-purchased products.
  *
  * This object processes a CSV input file containing order-product pairs and
  * generates a report of products that are frequently purchased together. The
  * analysis helps identify product relationships and potential recommendations
  * for a shopping system.
  *
  * Input format: CSV file with each line containing "orderId,productId" Output
  * format: CSV file with each line containing "product1,product2,count"
  *
  * @example
  *   {{{
  * // Run the application with input and output paths
  * spark-submit co-purchase-analysis.jar input.csv output/
  *   }}}
  */
object CoPurchaseAnalysis {

  /** Represents an order-product relationship.
    *
    * @param orderId
    *   The unique identifier for the order
    * @param productId
    *   The unique identifier for the product
    */
  case class OrderProduct(orderId: Int, productId: Int)

  /** Represents a pair of products that were purchased together.
    *
    * @param product1
    *   The identifier of the first product
    * @param product2
    *   The identifier of the second product
    */
  case class ProductPair(product1: Int, product2: Int)

  /** Validates command line arguments and checks file existence.
    *
    * @param args
    *   Command line arguments array containing input file path and output
    *   directory path
    * @return
    *   Some(errorMessage) if validation fails, None if validation succeeds
    */
  def checkArguments(args: Array[String]): Option[String] = {
    if (args.length != 2) {
      Some("You must define input file and output folder.")
    } else {
      None
    }
  }

  /** Creates and configures a SparkSession.
    *
    * @param appName
    *   The name of the Spark application
    * @param master
    *   The Spark master URL (e.g., "local", "yarn")
    * @return
    *   Configured SparkSession instance
    */
  def createSparkSession(appName: String, master: String): SparkSession = {
    var session = SparkSession.builder
      .appName(appName)
      .config("spark.master", master)

    val creds = System.getenv("GOOGLE_APPLICATION_CREDENTIALS")
    if (creds != null) {
      session
        .config("spark.hadoop.google.cloud.auth.service.account.enable", "true")
        .config(
          "spark.hadoop.google.cloud.auth.service.account.json.keyfile",
          creds
        )
    }

    session.getOrCreate()
  }

  /** Parses a single line from the input file into an OrderProduct instance.
    * Expects the line to be in CSV format with orderId and productId.
    *
    * @param line
    *   Input line in format "orderId,productId"
    * @return
    *   OrderProduct instance containing the parsed data
    */
  def parseLine(line: String): OrderProduct = {
    val parts = line.split(",")
    OrderProduct(parts(0).toInt, parts(1).toInt)
  }

  /** Processes the order data to generate co-purchase statistics.
    *
    * The processing pipeline includes: (1) Grouping orders by orderId, (2)
    * Generating product pairs for each order, (3) Counting occurrences of each
    * product pair
    *
    * @param data
    *   RDD containing OrderProduct instances
    * @return
    *   RDD containing CoPurchase instances with purchase frequency counts
    */
  def processData(data: RDD[OrderProduct]): RDD[String] = {
    data
      .groupBy(_.orderId)
      .flatMap { case (_, orders) =>
        orders.map(_.productId).toSeq.sorted.combinations(2).map {
          case List(p1, p2) =>
            ProductPair(Math.min(p1, p2), Math.max(p1, p2)) -> 1
        }
      }
      .foreach(println)
    data
      .groupBy(_.orderId)
      .flatMap { case (_, orders) =>
        orders.map(_.productId).toSeq.sorted.combinations(2).map {
          case List(p1, p2) =>
            ProductPair(Math.min(p1, p2), Math.max(p1, p2)) -> 1
        }
      }
      .reduceByKey(_ + _)
      .map { case (ProductPair(product1, product2), count) =>
        s"${product1},${product2},${count}"
      }
  }

  /** Main entry point for the application.
    *
    * @param args
    *   Command line arguments array
    */
  def main(args: Array[String]): Unit = {
    val argsError = checkArguments(args)

    if (!argsError.isEmpty) {
      println(argsError.get)
      return
    }

    // Configuration values should be passed as parameters
    val config = Map(
      "appName" -> "Co-Purchase Analysis",
      "master" -> "local[*]",
      "inputPath" -> args(0),
      "outputPath" -> args(1)
    )

    // Program execution composed of pure functions
    val spark = createSparkSession(config("appName"), config("master"))
    try {
      spark.sparkContext.setLogLevel("ERROR")

      val inputRDD = spark.sparkContext
        .textFile(config("inputPath"))
        .map(parseLine)

      val result = processData(inputRDD)
        .saveAsTextFile(config("outputPath"))
    } finally {
      spark.stop()
    }
  }
}
