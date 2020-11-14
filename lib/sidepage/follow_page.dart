import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:lottie/lottie.dart';

import 'package:pixivic/data/common.dart';
import 'package:pixivic/data/texts.dart';
import 'package:pixivic/page/artist_page.dart';
import 'package:pixivic/page/pic_detail_page.dart';
import 'package:pixivic/widget/papp_bar.dart';
import 'package:pixivic/function/dio_client.dart';

class FollowPage extends StatefulWidget {
  @override
  _FollowPageState createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage> {
  TextZhFollowPage texts = TextZhFollowPage();
  ScrollController scrollController;
  int currentPage;
  List jsonList;
  int followTotalNum;
  bool loadMoreAble;

  @override
  void initState() {
    currentPage = 1;
    loadMoreAble = true;
    scrollController = ScrollController()..addListener(_autoLoadMore);

    _getJsonList().then((value) {
      setState(() {
        followTotalNum = value.length;
        jsonList = value;
      });
    }).catchError((e) {
      print('followPage init error: $e');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PappBar(title: '我的关注'),
      body: jsonList != null
          ? Container(
              color: Colors.white,
              child: ListView.builder(
                  shrinkWrap: true,
                  controller: scrollController,
                  itemCount: followTotalNum,
                  itemBuilder: (BuildContext context, int index) {
                    return artistCell(jsonList[index], jsonList[index]);
                  }),
            )
          : Lottie.asset('image/loading-box.json'),
    );
  }

  Widget titleCell() {
    return Container(
      color: Colors.white,
      alignment: Alignment.topLeft,
      padding: EdgeInsets.all(ScreenUtil().setHeight(5)),
      child: Text(
        texts.title,
        style: TextStyle(
            fontSize: ScreenUtil().setWidth(14),
            color: Colors.black,
            decoration: TextDecoration.none),
      ),
    );
  }

  Widget artistCell(Map cellData, Map picData) {
    return Container(
      padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(10)),
      child: Column(
        children: <Widget>[
          picsCell(picData),
          Material(
            child: InkWell(
              onTap: () {
                _routeToArtistPage(cellData);
              },
              child: Stack(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(cellData['avatar'],
                              headers: {
                                'Referer': 'https://app-api.pixiv.net'
                              }),
                        ),
                      ),
                      Text(cellData['name'],
                          style: TextStyle(
                              fontSize: ScreenUtil().setWidth(10),
                              color: Colors.black,
                              decoration: TextDecoration.none)),
                    ],
                  ),
                  Positioned(
                    top: ScreenUtil().setWidth(10),
                    right: ScreenUtil().setWidth(15),
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: _subscribeButton(cellData),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget picsCell(Map picData) {
    List<int> allIndex = [0, 1, 2];
    return Row(
      children: allIndex.map((int item) {
        return Container(
          color: Colors.grey[200],
          child: GestureDetector(
            onTap: () {
              _routeToPicDetailPage(picData['recentlyIllustrations'][item]);
            },
            child: Image.network(
              picData['recentlyIllustrations'][item]['imageUrls'][0]
                  ['squareMedium'],
              headers: {'Referer': 'https://app-api.pixiv.net'},
              width: ScreenUtil().setWidth(108),
              height: ScreenUtil().setWidth(108),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _subscribeButton(Map data) {
    bool currentFollowedState = data['isFollowed'];
    String buttonText = currentFollowedState ? texts.followed : texts.follow;

    return FlatButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
      color: Colors.blueAccent[200],
      onPressed: () async {
        String url = 'users/followed';
        var response;
        Map<String, String> body = {
          'artistId': data['id'].toString(),
          'userId': prefs.getInt('id').toString(),
          'username': prefs.getString('name'),
        };
        if (currentFollowedState) {
          response = await dioPixivic.delete(
            url,
            data: body,
          );
        } else {
          response = await dioPixivic.post(
            url,
            data: body,
          );
        }
        if (response.runtimeType != bool) {
          setState(() {
            data['isFollowed'] = !data['isFollowed'];
          });
        } else {
          BotToast.showSimpleNotification(title: texts.followError);
        }
      },
      child: Text(
        buttonText,
        style:
            TextStyle(fontSize: ScreenUtil().setWidth(10), color: Colors.white),
      ),
    );
  }

  _getJsonList() async {
    String url =
        'users/${prefs.getInt('id').toString()}/followedWithRecentlyIllusts?page=$currentPage&pageSize=30';
    var response;
    response = await dioPixivic.get(url);
    if (response.runtimeType != bool) {
      List jsonList = response.data['data'];
      if (jsonList.length < 30) loadMoreAble = false;
      return (jsonList);
    } else {
      BotToast.showSimpleNotification(title: texts.httpLoadError);
    }
  }

  _routeToArtistPage(Map data) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return ArtistPage(
          data['avatar'],
          data['name'],
          data['id'].toString(),
          isFollowed: data['isFollowed'],
          followedRefresh: (bool result) {
            setState(() {
              data['isFollowed'] = result;
            });
          },
        );
      },
    ));
  }

  _routeToPicDetailPage(Map picData) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => PicDetailPage(picData)));
  }

  _autoLoadMore() {
    if ((scrollController.position.extentAfter < 350) &&
        (currentPage < 30) &&
        loadMoreAble) {
      loadMoreAble = false;
      currentPage++;
      print('current page is $currentPage');
      _getJsonList().then((value) {
        jsonList = jsonList + value;
        followTotalNum = followTotalNum + value.length;
        setState(() {
          loadMoreAble = true;
          BotToast.showSimpleNotification(title: '摩多摩多!!!(つ´ω`)つ');
        });
      });
    }
  }
}
