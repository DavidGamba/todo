package models

import play.api.Play.current

trait Binary {
  def get_fs_binary_file(name: String) : Array[Byte] = {
    val source = scala.io.Source.fromFile(name)(scala.io.Codec.ISO8859)
    val byteArray : Array[Byte] = source.map(_.toByte).toArray
    source.close
    byteArray
  }
  def get_song(name: String) : Array[Byte] = {
    get_fs_binary_file(s"songs/${name}")
  }
  def get_image(name: String) : Array[Byte] = {
    get_fs_binary_file(s"images/${name}")
  }
  def get_video(name: String) : Array[Byte] = {
    get_fs_binary_file(s"videos/${name}")
  }
}
