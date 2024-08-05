ThisBuild / version := "0.1.0-SNAPSHOT"

ThisBuild / scalaVersion := "2.12.18"

lazy val root = (project in file("."))
  .settings(
    name := "Spark-Scala-Docker"
  )

libraryDependencies += "org.apache.spark" %% "spark-core" % "3.4.3" % "provided"
libraryDependencies += "org.apache.spark" %% "spark-sql" % "3.4.3" % "provided"

import sbtassembly.AssemblyPlugin.autoImport._
import sbtassembly.MergeStrategy

assemblyMergeStrategy in assembly := {
  case PathList("META-INF", "io.netty.versions.properties") => MergeStrategy.discard
  case PathList("META-INF", "org/apache/logging/log4j/core/config/plugins/Log4j2Plugins.dat") => MergeStrategy.discard
  case PathList("META-INF", "versions", _*) => MergeStrategy.first
  case PathList("module-info.class") => MergeStrategy.discard
  case PathList("google", "protobuf", _*) => MergeStrategy.first
  case PathList("org", "apache", "commons", "logging", _*) => MergeStrategy.first
  case PathList("arrow-git.properties") => MergeStrategy.first
  case PathList("META-INF", xs @ _*) => MergeStrategy.discard
  case x => MergeStrategy.first
}
