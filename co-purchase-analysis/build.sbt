scalaVersion := sys.env.getOrElse("SCALA_VERSION", "2.12.10")

name := "co-purchase-analysis"
organization := "it.unibo.cs.scp"
version := "1.0"

libraryDependencies += "org.scala-lang.modules" %% "scala-parser-combinators" % "2.3.0"
libraryDependencies += "org.apache.spark" %% "spark-core" % "3.5.3"
libraryDependencies += "org.apache.spark" %% "spark-sql" % "3.5.3"
