import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';

class Thumbnail {
  Future<Uint8List?> loadThumbnail(String url, {int quality = 50}) => VideoThumbnail.thumbnailData(
      //video: Constants().baseUrlImage + url, imageFormat: ImageFormat.WEBP, quality: quality);
      video: url, imageFormat: ImageFormat.WEBP, quality: quality);
}