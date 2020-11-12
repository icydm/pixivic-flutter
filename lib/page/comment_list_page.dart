import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_screenutil/screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'package:pixivic/provider/comment_list_model.dart';
import 'package:pixivic/provider/meme_model.dart';
import 'package:pixivic/widget/papp_bar.dart';
import 'package:pixivic/data/texts.dart';
import 'package:pixivic/page/user_detail_page.dart';
import 'package:pixivic/widget/meme_box.dart';

class CommentListPage extends StatelessWidget {
  CommentListPage(
      {this.comments,
      @required this.illustId,
      this.replyToId = 0,
      this.replyToName = '',
      this.replyParentId = 0,
      this.isReply = false});

  CommentListPage.reply(
      {@required this.comments,
      @required this.illustId,
      @required this.replyToId,
      @required this.replyToName,
      @required this.replyParentId,
      this.isReply = false});

  final List comments;
  final int illustId;
  final int replyToId;
  final String replyToName;
  final int replyParentId;
  final bool isReply;

  final TextZhCommentCell texts = TextZhCommentCell();
  final ScreenUtil screen = ScreenUtil();

  @override
  Widget build(BuildContext context) {
    // CommentListModel commentListModel =
    //     CommentListModel(illustId, replyToId, replyToName, replyParentId);

    return GestureDetector(
        onTap: () {
          //键盘移除焦点
          FocusScope.of(context).requestFocus(FocusNode());
          // commentListModel.replyFocus.unfocus();
          // FocusScopeNode currentFocus = FocusScope.of(context);

          // if (!currentFocus.hasPrimaryFocus) {
          //   currentFocus.unfocus();
          // }
          // if (commentListModel.isMemeMode) commentListModel.flipMemeMode();
        },
        child: Scaffold(
          appBar: PappBar(
            title: texts.comment,
          ),
          body: ChangeNotifierProvider<CommentListModel>(
            // : commentListModel,
            create: (_) =>  CommentListModel(illustId, replyToId, replyToName, replyParentId),
            child: Selector<CommentListModel, CommentListModel>(
                shouldRebuild: (pre, next) => false,
                selector: (context, provider) => provider,
                builder: (context, commentListModel, _) {
                  print("列表selector");
                  return Container(
                    color: Colors.white,
                    child: Stack(
                      children: <Widget>[
                        Selector<CommentListModel, List>(
                            selector: (context, provider) =>
                                provider.commentList,
                            builder: (context, commentList, _) {
                              print("listSelector");
                              return commentList != null
                                  ? Positioned(
                                      // top: screen.setHeight(5),
                                      child: Container(
                                      width: screen.setWidth(324),
                                      height: screen.setHeight(576),
                                      margin: EdgeInsets.only(
                                          bottom: screen.setHeight(35)),
                                      child: ListView.builder(
                                          controller:
                                              commentListModel.scrollController,
                                          shrinkWrap: true,
                                          itemCount: commentList.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return commentParentCell(
                                                commentList[index],
                                                context,
                                                commentListModel);
                                          }),
                                    ))
                                  : Container();
                            }),
                        Selector<CommentListModel, bool>(
                            selector: (context, provider) =>
                                provider.isMemeMode,
                            builder: (context, isMemeMode, _) {
                              return AnimatedPositioned(
                                duration: Duration(milliseconds: 100),
                                bottom: 0.0,
                                left: 0.0,
                                right: 0.0,
                                child: Column(
                                  children: [
                                    bottomCommentBar(commentListModel),
                                    isMemeMode == true
                                        ? AnimatedContainer(
                                            duration:
                                                Duration(milliseconds: 1000),
                                        curve: Curves.bounceInOut,
                                            child: MemeBox(),
                                          )
                                        : Container()
                                  ],
                                ),
                              );
                            })
                        // AnimatedPositioned(
                        //   duration: Duration(milliseconds: 100),
                        //   bottom:
                        //       tuple2.item2 ? ScreenUtil().setHeight(256) : 0.0,
                        //   left: 0.0,
                        //   right: 0.0,
                        //   child: bottomCommentBar(commentListModel),
                        // ),
                        // AnimatedPositioned(
                        //   duration: Duration(milliseconds: 100),
                        //   bottom:
                        //       tuple2.item2 ? 0.0 : -ScreenUtil().setHeight(256),
                        //   left: 0.0,
                        //   right: 0.0,
                        //   child: MemeBox(),
                        // )
                      ],
                    ),
                  );
                }),
          ),
        ));
  }

  Widget bottomCommentBar(CommentListModel commentListModel) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(
          bottom: screen.setHeight(5),
          left: screen.setWidth(5),
          right: screen.setWidth(5)),
      width: screen.setWidth(324),
      height: screen.setHeight(35),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Material(
            color: Colors.white,
            child: InkWell(
              child: FaIcon(
                FontAwesomeIcons.smile,
                color: Colors.pink[300],
              ),
              onTap: () {
                commentListModel.flipMemeMode();
              },
            ),
          ),
          Container(
              width: ScreenUtil().setWidth(262),
              height: ScreenUtil().setHeight(25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color(0xFFF4F3F3F3),
              ),
              margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(5),
                right: ScreenUtil().setWidth(5),
              ),
              child: Selector<CommentListModel, String>(
                selector: (context, provider) => provider.hintText,
                builder: (context, hintString, _) {
                  return TextField(
                    focusNode: commentListModel.replyFocus,
                    controller: commentListModel.textEditingController,
                    autofocus: isReply ? true : false,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: hintString,
                        hintStyle: TextStyle(fontSize: 14),
                        contentPadding: EdgeInsets.only(
                            left: ScreenUtil().setWidth(8),
                            bottom: ScreenUtil().setHeight(9))),
                  );
                },
              )),
          Material(
            color: Colors.white,
            child: InkWell(
              child: FaIcon(FontAwesomeIcons.paperPlane),
              onTap: () {
                commentListModel.reply();
              },
            ),
          ),
        ],
      ),
    );
  }

  // 单条回复
  Widget commentParentCell(
      Map commentAllData, BuildContext context, commentListModel) {
    bool hasSub = commentAllData['subCommentList'] == null ? false : true;

    return Container(
        width: screen.setWidth(324),
        child: Container(
          padding: EdgeInsets.only(
              left: screen.setHeight(7),
              right: screen.setHeight(7),
              top: screen.setHeight(10)),
          alignment: Alignment.topLeft,
          child: Column(
            children: <Widget>[
              commentBaseCell(commentAllData, context, commentListModel),
              hasSub
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: commentAllData['subCommentList'].length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return commentSubCell(
                            commentAllData['subCommentList'][index],
                            context,
                            commentListModel);
                      })
                  : Container(),
              SizedBox(width: screen.setWidth(300), child: Divider())
            ],
          ),
        ));
  }

  // 楼中楼
  Widget commentSubCell(
      Map commentEachSubData, BuildContext context, commentListModel) {
    return Container(
      padding:
          EdgeInsets.only(left: screen.setWidth(15), top: screen.setHeight(7)),
      child: commentBaseCell(commentEachSubData, context, commentListModel),
    );
  }

  // 基础的展示条
  Widget commentBaseCell(Map data, BuildContext context, commentListModel) {
    String avaterUrl =
        'https://static.pixivic.net/avatar/299x299/${data['replyFrom']}.jpg';

    return Container(
        child: Column(children: <Widget>[
      Material(
          color: Colors.white,
          child: InkWell(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                    right: ScreenUtil().setWidth(8),
                  ),
                  child: GestureDetector(
                    child: CircleAvatar(
                        // backgroundColor: Colors.white,
                        radius: ScreenUtil().setHeight(14),
                        backgroundImage: NetworkImage(avaterUrl,
                            headers: {'referer': 'https://pixivic.com'})),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return UserDetailPage(
                            data['replyFrom'], data['replyFromName']);
                      }));
                    },
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: ScreenUtil().setHeight(5)),
                    Text(
                      data['replyFromName'],
                      style: TextStyle(fontSize: 12),
                    ),
                    Container(
                      width: screen.setWidth(235),
                      alignment: Alignment.centerLeft,
                      child: commentContentDisplay(context, data),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        top: ScreenUtil().setHeight(4),
                      ),
                      child: Row(
                        children: <Widget>[
                          Text(
                            DateFormat("yyyy-MM-dd")
                                .format(DateTime.parse(data['createDate'])),
                            strutStyle: StrutStyle(
                              fontSize: 12,
                              height: ScreenUtil().setWidth(1.3),
                            ),
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          SizedBox(
                            width: ScreenUtil().setWidth(5),
                          ),
                          GestureDetector(
                            child: Text(
                              texts.reply,
                              strutStyle: StrutStyle(
                                fontSize: 12,
                                height: ScreenUtil().setWidth(1.3),
                              ),
                              style: TextStyle(
                                  color: Colors.blue[600], fontSize: 12),
                            ),
                            onTap: () {
                              commentListModel.replyToId = data['replyFrom'];
                              commentListModel.replyToName =
                                  data['replyFromName'];
                              data['parentId'] == 0
                                  ? commentListModel.replyParentId = data['id']
                                  : commentListModel.replyParentId =
                                      data['parentId'];
                              if (commentListModel.replyFocus.hasFocus)
                                commentListModel.replyFocusListener();
                              else
                                commentListModel.replyFocus.requestFocus();
                            },
                          )
                        ],
                      ),
                    )
                  ],
                )
              ])))
    ]));
  }

  Widget commentContentDisplay(BuildContext context, Map data) {
    String content = data['content'];

    if (content[0] == '[' &&
        content[content.length - 1] == ']' &&
        content.contains('_:')) {
      String memeStr = content.substring(1, content.length - 1).split('_')[1];
      String memeId = memeStr.substring(1, memeStr.length - 1);
      String memeHead = memeId.split('-')[0];
      // print(memeHead);
      // print(memeId);
      Widget image = Container(
        width: ScreenUtil().setWidth(50),
        height: ScreenUtil().setWidth(50),
        child: Image(image: AssetImage('image/meme/$memeHead/$memeId.webp')),
      );
      return data['replyToName'] == ''
          ? image
          : Row(
              children: [
                Text(
                  '@${data['replyToName']}',
                  softWrap: true,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(8),
                ),
                image
              ],
            );
    } else {
      return Text(
        data['replyToName'] == ''
            ? data['content']
            : '@${data['replyToName']}: ${data['content']}',
        softWrap: true,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      );
    }
  }

//  _altLoading() {
//    if ((scrollController.position.extentAfter < 500) && loadMoreAble) {
//      print(" Load Comment");
//      loadMoreAble = false;
//      currentPage++;
//      print('current page is $currentPage');
//      try {
//        commentListModel
//            .loadComments(widget.illustId, page: currentPage)
//            .then((value) {
//          if (value.length != 0) {
//            loadMoreAble = true;
//          }
//        });
//      } catch (err) {
//        print('=========getJsonList==========');
//        print(err);
//        print('==============================');
//        if (err.toString().contains('SocketException'))
//          BotToast.showSimpleNotification(title: '网络异常，请检查网络(´·_·`)');
//        loadMoreAble = true;
//      }
//    }
//  }

//  _replyFocusListener() {
//    if (replyFocus.hasFocus && replyToName != '') {
//      print('on focus');
//      setState(() {
//        hintText = '@$replyToName:';
//      });
//    } else if (!replyFocus.hasFocus) {
//      print('focus released');
//      setState(() {
//      replyToId = 0;
//      replyToName = '';
//      replyParentId = 0;
//      hintText = texts.addCommentHint;
//      // print(textEditingController.text);
//      });
//    }
//    print('replyParentId now is $replyParentId');
//  }

//  _reply() async {
//    if (prefs.getString('auth') == '') {
//      BotToast.showSimpleNotification(title: texts.pleaseLogin);
//      return false;
//    }
//
//    if (commentListModel.textEditingController.text == '') {
//      BotToast.showSimpleNotification(title: texts.commentCannotBeBlank);
//      return false;
//    }
//
//    String url = 'https://api.pixivic.com/illusts/${widget.illustId}/comments';
//    CancelFunc cancelLoading;
//    var dio = Dio();
//    Map<String, dynamic> payload = {
//      'content': commentListModel.textEditingController.text,
//      'parentId': commentListModel.replyParentId.toString(),
//      'replyFromName': prefs.getString('name'),
//      'replyTo': commentListModel.replyToId.toString(),
//      'replyToName': commentListModel.replyToName
//    };
//    Map<String, dynamic> headers = {'authorization': prefs.getString('auth')};
//    Response response = await dio.post(
//      url,
//      data: payload,
//      options: Options(headers: headers),
//      onReceiveProgress: (count, total) {
//        cancelLoading = BotToast.showLoading();
//      },
//    );
//    cancelLoading();
//    BotToast.showSimpleNotification(title: response.data['message']);
//    if (response.statusCode == 200) {
//      commentListModel.textEditingController.text = '';
//      commentListModel.replyToId = 0;
//      commentListModel.replyToName = '';
//      commentListModel.replyParentId = 0;
//      commentListModel.loadComments(widget.illustId);
////      await _loadComments();
//      return true;
//    } else {
//      return false;
//    }
//  }

//  _loadComments() async {
//    String url = 'https://api.pixivic.com/illusts/${widget.illustId}/comments';
//    var dio = Dio();
//    Response response = await dio.get(url);
//    if (response.statusCode == 200 && response.data['data'] != null) {
//      // print(response.data);
//      setState(() {
//        commentsList = response.data['data'];
//      });
//    } else if (response.statusCode == 200 && response.data['data'] == null) {
//      print('comments: null but 200');
//    } else {
//      BotToast.showSimpleNotification(title: response.data['message']);
//    }
//  }

}
