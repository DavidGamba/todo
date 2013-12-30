package models

import play.api.Play.current
import models.Binary

object Media extends Binary {
  def get_song_filename(id: String) : String = {
    "songs/" + id
  }
  def get_video_filename(id: String) : String = {
    "videos/" + id
  }
  def get_image_filename(id: String) : String = {
    "images/" + id
  }
}
