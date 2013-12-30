package controllers

import play.api.mvc.{Action, Controller, Flash,Result}
import play.api.i18n.Messages

import models.Media

object Medias extends Controller {

  // TODO: Make errors i18n

  def song(name: String) = {
    val mymeType: String = name.split('.').drop(1).lastOption match {
      case Some("mp3") => "audio/mpeg"
      case _ => "audio/mpeg"
    }
    get_file(name, mymeType)
  }

  def video(name: String) = {
    val mymeType: String = name.split('.').drop(1).lastOption match {
      case Some("mpeg") => "video/mpeg"
      case Some("mp4")  => "video/mp4"
      case Some("ogg")  => "video/ogg"
      case Some("webm") => "video/webm"
      case _ => "video/mpeg"
    }
    get_file(name, mymeType)
  }

  def image(name: String) = {
    val mymeType: String = name.split('.').drop(1).lastOption match {
      case Some("jpg")  => "image/jpeg"
      case Some("jpeg") => "image/jpeg"
      case Some("png")  => "image/png"
      case Some("gif")  => "image/gif"
      case _ => "image/jpeg"
    }
    get_file(name, mymeType)
  }

  def get_file(name: String, mimeType: String) = Action { implicit request =>
    import java.lang.IllegalArgumentException
    import java.io.FileNotFoundException
    try {
      val type_image = "^image/.*".r
      val type_audio = "^audio/.*".r
      val type_video = "^video/.*".r
      val my_file: Array[Byte] = mimeType match {
        case type_audio() => Media.get_song(name)
        case type_image() => Media.get_image(name)
        case type_video() => Media.get_video(name)
      }
      Ok(my_file).as(mimeType)
    }
    catch {
      case e: IllegalArgumentException =>
        BadRequest("Could not retrieve file. Error: " + e.getMessage)
      case e: FileNotFoundException =>
        BadRequest("Could not find file. Error: " + e.getMessage)
    }
  }
}
