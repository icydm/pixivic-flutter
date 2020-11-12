import 'package:flutter/material.dart';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import 'package:pixivic/data/common.dart';
import 'package:pixivic/data/texts.dart';
import 'package:pixivic/function/dio_client.dart';
import 'package:pixivic/provider/meme_model.dart';

class CommentListModel with ChangeNotifier {
  int illustId;
  int replyToId;
  int currentPage = 1;
  int replyParentId;
  List commentList;
  List jsonList;
  ScrollController scrollController;
  bool loadMoreAble = true;
  bool isMemeMode = false;
  bool isReplyAble = true;
  String replyToName;
  String hintText;
  TextEditingController textEditingController;
  FocusNode replyFocus;
  TextZhCommentCell texts = TextZhCommentCell();

  CommentListModel(
      this.illustId, this.replyToId, this.replyToName, this.replyParentId) {
    scrollController = ScrollController()..addListener(_autoLoading);
    textEditingController = TextEditingController();
    replyFocus = FocusNode()..addListener(replyFocusListener);

    this.hintText = texts.addCommentHint;

    //初始化Model时拉取评论数据
    loadComments(this.illustId).then((value) {
      commentList = value;
      notifyListeners();
    });
  }

  // 根据回复框的焦点做判断
  replyFocusListener() {
    if (replyFocus.hasFocus) {
      print('replyFocus on focus');
      if(isMemeMode)
        flipMemeMode();
      if (replyToName != '') {
        print('replyFocusListener: replyParentId is $replyParentId');
        hintText = '@$replyToName:';
        notifyListeners();
      }
    } else if (!replyFocus.hasFocus) {
      print('replyFocus released');

      replyToId = 0;
      replyToName = '';
      replyParentId = 0;
      hintText = texts.addCommentHint;
      // print(textEditingController.text);
      notifyListeners();
    }
  }

  reply() async {
    if (isReplyAble) {
      if (prefs.getString('auth') == '') {
        BotToast.showSimpleNotification(title: texts.pleaseLogin);
        return false;
      }

      if (textEditingController.text == '') {
        BotToast.showSimpleNotification(title: texts.commentCannotBeBlank);
        return false;
      }

      isReplyAble = false;

      String url = 'https://api.pixivic.com/illusts/$illustId/comments';
      CancelFunc cancelLoading;
      Map<String, dynamic> payload = {
        'content': textEditingController.text,
        'parentId': replyParentId.toString(),
        'replyFromName': prefs.getString('name'),
        'replyTo': replyToId.toString(),
        'replyToName': replyToName
      };

      await dioPixivic.post(
        url,
        data: payload,
        onReceiveProgress: (count, total) {
          cancelLoading = BotToast.showLoading();
        },
      );
      cancelLoading();

      textEditingController.text = '';
      replyToId = 0;
      replyToName = '';
      replyParentId = 0;

      loadComments(illustId).then((value) {
        commentList = value;
        notifyListeners();
      });
      isReplyAble = true;
      return true;
    } else {
      return false;
    }
  }

  replyMeme(String memeGroup, String memeId) {
    if (prefs.getString('auth') == '') {
      BotToast.showSimpleNotification(title: texts.pleaseLogin);
      return false;
    }
  }

  //自动加载数据
  _autoLoading() {
    if ((scrollController.position.extentAfter < 500) && loadMoreAble) {
      print("Load Comment");
      loadMoreAble = false;
      currentPage++;
      print('current page is $currentPage');
      try {
        loadComments(illustId, page: currentPage).then((value) {
          if (value.length != 0) {
            commentList = commentList + value;
            notifyListeners();
            loadMoreAble = true;
          }
        });
      } catch (err) {
        print('=========getJsonList==========');
        print(err);
        print('==============================');
        if (err.toString().contains('SocketException'))
          BotToast.showSimpleNotification(title: '网络异常，请检查网络(´·_·`)');
        loadMoreAble = true;
      }
    }
  }

//请求数据
  loadComments(int illustId, {int page = 1}) async {
    String url =
        'https://api.pixivic.com/illusts/$illustId/comments?page=$page&pageSize=10';
    var dio = Dio();
    Response response = await dio.get(url);
    if (response.statusCode == 200 && response.data['data'] != null) {
      // print(response.data);
      jsonList = response.data['data'];
      return jsonList;
    } else if (response.statusCode == 200 && response.data['data'] == null) {
      print('comments: null but 200');
      return jsonList = [];
    } else {
      BotToast.showSimpleNotification(title: response.data['message']);
    }
  }

  flipMemeMode() {
    isMemeMode = !isMemeMode;
    notifyListeners();
  }

  @override
  void dispose() {
    commentList = null;
    textEditingController.dispose();
    replyFocus.dispose();
    super.dispose();
  }
}
