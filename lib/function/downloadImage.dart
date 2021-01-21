import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';

// import 'package:path_provider/path_provider.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'package:pixivic/function/image_url.dart';
import 'package:pixivic/data/common.dart';

class DownloadImage {
  final String url;
  final ValueChanged<int> onProgressUpdate;
  final String platform;

  int progress;
  String imageId;
  String fileName;
  String path;
  int size;
  String mimeType;
  int androidProgress;
  bool isVip = false;

  DownloadImage(this.url, this.platform,
      {this.fileName, this.onProgressUpdate}) {
    if (prefs.getInt('permissionLevel') > 2) isVip = true;
    print('start download');

    ImageDownloader.callback(
        onProgressUpdate: (String imageId, int progressNow) {
      progress = progressNow;
      print(progress);
    });

    if (platform == 'ios')
      _iOSDownload();
    else if (platform == 'android') _androidDownloadWithFlutterDownloader();
  }

  void dispose() {
    print('download disposed');
  }

  _iOSDownload() async {
    BotToast.showSimpleNotification(
        title: isVip ? '开始下载,请勿退出应用' : '高速通道下载中,请勿退出应用');
    try {
      Response response = await Dio().get(
        imageUrl(url, 'original'),
        options: Options(
            headers: imageHeader('original'),
            receiveTimeout: 280000,
            responseType: ResponseType.bytes),
      );
      // response.raiseForStatus();
      final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 100);
      print(result);
      BotToast.showSimpleNotification(title: '下载完成');
    } catch (e) {
      BotToast.showSimpleNotification(title: '下载失败,请检查网络');
      print(e);
    }
  }

  // _androidDownload() async {
  //   BotToast.showSimpleNotification(title: '开始下载,请勿退出应用');
  //   try {
  //     Response response = await Requests.get(url,
  //         headers: {'Referer': 'https://app-api.pixiv.net'},
  //         timeoutSeconds: 180);
  //     // response.raiseForStatus();
  //     final result = await ImageGallerySaver.saveImage(
  //         Uint8List.fromList(response.bytes()), );
  //     print(result);
  //     BotToast.showSimpleNotification(title: '下载完成');
  //   } catch (e) {
  //     BotToast.showSimpleNotification(title: '下载失败,请检查网络');
  //     print(e);
  //   }
  // }

  // _iOSDownloadWithImageDownloader() async {
  //   imageId = await ImageDownloader.downloadImage(
  //     url,
  //     headers: {'Referer': 'https://app-api.pixiv.net'},
  //     // destination: AndroidDestinationType.custom(directory: 'pixivic_images')
  //     //   ..inExternalFilesDir(),
  //   ).catchError((onError) {
  //     print(onError);
  //     BotToast.showSimpleNotification(title: '下载失败,请检查网络');
  //     // ImageDownloader.cancel();
  //     return false;
  //   });
  //   if (imageId == null) {
  //     print('image dwonload error');
  //     return false;
  //   }

  //   fileName = await ImageDownloader.findName(imageId);
  //   path = await ImageDownloader.findPath(imageId);
  //   size = await ImageDownloader.findByteSize(imageId);
  //   mimeType = await ImageDownloader.findMimeType(imageId);
  //   print(fileName);
  //   print(path);
  //   print(size);
  //   print(mimeType);
  //   BotToast.showSimpleNotification(title: '下载完成');
  //   return true;
  // }

  _androidDownloadWithFlutterDownloader() async {
    BotToast.showSimpleNotification(title: isVip ? '高速通道下载中' : '开始下载');
    String fileNameFromUrl = url.split('/').last;
    print('fileName is $fileNameFromUrl');
    // final Directory directory = await getExternalStorageDirectory();

    // final Directory picDirFolder =
    //     Directory('${directory.path}${Platform.pathSeparator}pixivic_images');
    final Directory picDirFolder = Directory(
        '${Platform.pathSeparator}storage${Platform.pathSeparator}emulated${Platform.pathSeparator}0${Platform.pathSeparator}pixivic');
    // print(picDirFolder.path);
    if (!await picDirFolder.exists()) {
      print('creating folder');
      await picDirFolder.create(recursive: true);
    }
    await FlutterDownloader.enqueue(
            url: imageUrl(url, 'original'),
            savedDir: '${picDirFolder.path}',
            showNotification: true,
            openFileFromNotification: true,
            headers: imageHeader('original'),
            fileName: fileNameFromUrl)
        .catchError((onError) {
      print(onError);
      BotToast.showSimpleNotification(title: '下载失败,请检查网络');
      return false;
    });
  }
}
