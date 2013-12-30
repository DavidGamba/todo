package controllers

import play.api.libs.concurrent.Execution.Implicits._
import play.api.mvc.{Action, Controller, SimpleResult, ResponseHeader}
import play.api.i18n.Messages
import play.api.libs.iteratee.Enumerator

import models.Media

object Medias extends Controller {

  // TODO: Make errors i18n

  def song(name: String) = {
    get_file( Media.get_song_filename(name) )
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
}
