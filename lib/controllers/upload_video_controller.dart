import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:tiktok_tutorial/constants.dart';
import 'package:tiktok_tutorial/models/video.dart';
import 'package:video_compress/video_compress.dart';

class UploadVideoController extends GetxController {
  _compressVideo(String videoPath) async {
    try {
      final compressedVideo = await VideoCompress.compressVideo(
        videoPath,
        quality: VideoQuality.MediumQuality,
      );
      return compressedVideo!.file;
    } catch (e) {
      try {
        final compressedVideo = await VideoCompress.compressVideo(
          videoPath,
          quality: VideoQuality.LowQuality,
        );
        return compressedVideo!.file;
      } catch (e) {
        return File(videoPath);
      }
    }
  }

  Future<String> _uploadVideoToStorage(String id, String videoPath) async {
    Reference ref = firebaseStorage.ref().child('videos').child(id);

    UploadTask uploadTask = ref.putFile(await _compressVideo(videoPath));
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  _getThumbnail(String videoPath) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videoPath);
    return thumbnail;
  }

  Future<String> _uploadImageToStorage(String id, String videoPath) async {
    Reference ref = firebaseStorage.ref().child('thumbnails').child(id);
    UploadTask uploadTask = ref.putFile(await _getThumbnail(videoPath));
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  // upload video
  uploadVideo(String songName, String caption, String videoPath) async {
    String uid = firebaseAuth.currentUser!.uid;
    DocumentSnapshot userDoc =
        await firestore.collection('users').doc(uid).get();    // get id

    DateTime _now = DateTime.now();

    String videoId = uid + _now.year.toString() + _now.month.toString() + _now.day.toString() + _now.hour.toString() + _now.minute.toString() + _now.second.toString();

    String videoUrl = await _uploadVideoToStorage("Video $videoId", videoPath);
    String thumbnail = await _uploadImageToStorage("Video $videoId", videoPath);

    Video video = Video(
      username: (userDoc.data()! as Map<String, dynamic>)['name'],
      uid: uid,
      id: "Video $videoId",
      likes: [],
      commentCount: 0,
      shareCount: 0,
      songName: songName ?? '',
      caption: caption ?? '',
      videoUrl: videoUrl,
      profilePhoto: (userDoc.data()! as Map<String, dynamic>)['profilePhoto'] ?? '',
      thumbnail: thumbnail,
    );

    await firestore.collection('videos').doc('Video $videoId').set(
          video.toJson(),
        );
  }
}
