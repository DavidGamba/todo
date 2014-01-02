package controllers

import play.api.libs.concurrent.Execution.Implicits._
import play.api.mvc.{Action, Controller, SimpleResult, ResponseHeader}
import play.api.i18n.Messages
import play.api.libs.iteratee.Enumerator

import models.Media

object Medias extends Controller {

  // TODO: Make errors i18n

  def song(name: String) = {
    val filename = Media.get_song_filename(name)
    val file = new java.io.File(filename)
    if (file.isDirectory)
      get_files(file.listFiles)
    else
      get_file(filename)
  }

  def video(name: String) = {
    get_file( Media.get_video_filename(name) )
  }

  def image(name: String) = {
    get_file( Media.get_image_filename(name) )
  }

  def get_file(name: String) = Action { implicit request =>
    import java.lang.IllegalArgumentException
    import java.io.FileNotFoundException
    try {
      val file = new java.io.File(name)
      val fileContent: Enumerator[Array[Byte]] = Enumerator.fromFile(file)
      SimpleResult(
        header = ResponseHeader(200, Map(CONTENT_LENGTH -> file.length.toString)),
        body = fileContent
      )
    }
    catch {
      case e: IllegalArgumentException =>
        BadRequest("Could not retrieve file. Error: " + e.getMessage)
      case e: FileNotFoundException =>
        BadRequest("Could not find file. Error: " + e.getMessage)
    }
  }

  // TODO: when playing several audio files together, you can't go to a
  // previous point in time regardless of the content-length.
  def get_files(files: Array[java.io.File]) = Action { implicit request =>
    import java.lang.IllegalArgumentException
    import java.io.FileNotFoundException
    import scala.collection.JavaConverters._
    try {
      val length_array = for (file <- files) yield file.length
      val length = length_array.sum + 100

      val inputStream_array = for (file <- files) yield
        new java.io.FileInputStream(file)

      val inputStream_iterator = inputStream_array.toIterator

      val sequence = new java.io.SequenceInputStream(inputStream_iterator.asJavaEnumeration)
      val fileContent: Enumerator[Array[Byte]] = Enumerator.fromStream(sequence)
      SimpleResult(
        header = ResponseHeader(200, Map(CONTENT_LENGTH -> length.toString)),
        body = fileContent
      )
    }
    catch {
      case e: IllegalArgumentException =>
        BadRequest("Could not retrieve file. Error: " + e.getMessage)
      case e: FileNotFoundException =>
        BadRequest("Could not find file. Error: " + e.getMessage)
    }
  }

}
