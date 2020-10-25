import 'package:flutter/material.dart';

// import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'package:tuple/tuple.dart';
import 'package:random_color/random_color.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:pixivic/page/pic_detail_page.dart';
import 'package:pixivic/data/common.dart';
import 'package:pixivic/provider/pic_page_model.dart';
import 'package:pixivic/widget/markheart_icon.dart';

// 可以作为页面中单个组件或者单独页面使用的pic瀑布流组件,因可以作为页面，故不归为widget
class PicPage extends StatefulWidget {
  @override
  _PicPageState createState() => _PicPageState();

  PicPage({
    this.picDate,
    this.picMode,
    this.relatedId = 0,
    this.jsonMode = 'home',
    this.searchKeywords,
    this.isManga,
    this.artistId,
    this.userId,
    this.spotlightId,
    this.collectionId,
    this.onPageScrolling,
    this.onPageTop,
    this.onPageStart,
    this.isScrollable = true,
  });

  PicPage.home({
    @required this.picDate,
    @required this.picMode,
    this.relatedId,
    this.jsonMode = 'home',
    this.searchKeywords,
    this.isManga,
    this.artistId,
    this.userId,
    this.spotlightId,
    this.collectionId,
//    @required this.onPageScrolling,
    this.onPageScrolling,
    this.onPageTop,
    this.onPageStart,
    this.isScrollable = true,
  });

  PicPage.related({
    @required this.relatedId,
    this.picDate,
    this.picMode,
    this.jsonMode = 'related',
    this.searchKeywords,
    this.isManga,
    this.artistId,
    this.userId,
    this.spotlightId,
    this.collectionId,
    this.onPageScrolling,
    @required this.onPageTop,
    @required this.onPageStart,
    this.isScrollable = true,
  });

  PicPage.search({
    @required this.searchKeywords,
    this.picDate,
    this.picMode,
    this.jsonMode = 'search',
    this.relatedId,
    this.userId,
    this.isManga = false,
    this.artistId,
    this.collectionId,
    this.spotlightId,
    this.onPageScrolling,
    this.onPageTop,
    this.onPageStart,
    this.isScrollable = true,
  });

  PicPage.artist({
    this.searchKeywords,
    this.picDate,
    this.picMode,
    this.jsonMode = 'artist',
    this.relatedId,
    this.userId,
    this.isManga = false,
    @required this.artistId,
    this.spotlightId,
    this.collectionId,
    this.onPageScrolling,
    @required this.onPageTop,
    @required this.onPageStart,
    this.isScrollable = true,
  });

  PicPage.followed({
    this.searchKeywords,
    this.picDate,
    this.picMode,
    this.jsonMode = 'followed',
    this.relatedId,
    @required this.userId,
    this.isManga = false,
    this.artistId,
    this.spotlightId,
    this.collectionId,
    this.onPageScrolling,
    this.onPageTop,
    this.onPageStart,
    this.isScrollable = true,
  });

  PicPage.bookmark({
    this.searchKeywords,
    this.picDate,
    this.picMode,
    this.jsonMode = 'bookmark',
    this.relatedId,
    @required this.userId,
    this.collectionId,
    this.isManga = false,
    this.artistId,
    this.spotlightId,
    this.onPageScrolling,
    this.onPageTop,
    this.onPageStart,
    this.isScrollable = true,
  });

  PicPage.spotlight({
    this.searchKeywords,
    this.picDate,
    this.picMode,
    this.jsonMode = 'spotlight',
    this.relatedId,
    this.userId,
    this.collectionId,
    @required this.spotlightId,
    this.isManga = false,
    this.artistId,
    this.onPageScrolling,
    this.onPageTop,
    this.onPageStart,
    this.isScrollable = true,
  });

  PicPage.history({
    this.searchKeywords,
    this.picDate,
    this.picMode,
    this.jsonMode = 'history',
    this.relatedId,
    this.userId,
    this.spotlightId,
    this.collectionId,
    this.isManga = false,
    this.artistId,
    this.onPageScrolling,
    this.onPageTop,
    this.onPageStart,
    this.isScrollable = true,
  });

  PicPage.oldHistory({
    this.searchKeywords,
    this.picDate,
    this.picMode,
    this.jsonMode = 'oldhistory',
    this.relatedId,
    this.userId,
    this.spotlightId,
    this.collectionId,
    this.isManga = false,
    this.artistId,
    this.onPageScrolling,
    this.onPageTop,
    this.onPageStart,
    this.isScrollable = true,
  });

  PicPage.userdetail({
    this.searchKeywords,
    this.picDate,
    this.picMode,
    this.jsonMode = 'userdetail',
    this.relatedId,
    @required this.userId,
    this.spotlightId,
    this.collectionId,
    this.isManga = false,
    this.artistId,
    this.onPageScrolling,
    this.onPageTop,
    this.onPageStart,
    this.isScrollable = true,
  });

  PicPage.collection({
    this.searchKeywords,
    this.picDate,
    this.picMode,
    this.jsonMode = 'collection',
    this.relatedId,
    this.userId,
    @required this.collectionId,
    this.spotlightId,
    this.isManga = false,
    this.artistId,
    this.onPageScrolling,
    this.onPageTop,
    this.onPageStart,
    this.isScrollable = true,
  });

  final String picDate;
  final String picMode;
  final num relatedId;
  final String artistId;
  final String spotlightId;
  final String userId;
  final String collectionId;
  final String searchKeywords;
  final bool isManga;
  final bool isScrollable;

  // jsonMode could be set to 'home, related, Spotlight, tag, artist, search...'
  final String jsonMode;

  // hide naviagtor bar when page is scrolling
  final ValueChanged<bool> onPageScrolling;

  // related page 中，用户返回到了顶部
  final VoidCallback onPageTop;

  // related page 中，用户开始下滑
  final VoidCallback onPageStart;

// pageModel.picList - 图片的JSON文件列表
// picTotalNum - pageModel.picList 中项目的总数（非图片总数，因为单个项目有可能有多个图片）
// 针对最常访问的 Home 页面，临时变量记录于 common.dart

//  List pageModel.picList = [];

}

class _PicPageState extends State<PicPage> {
  PicPageModel picPageModel;

  @override
  void initState() {
    picPageModel = PicPageModel(
        context: context,
        jsonMode: widget.jsonMode,
        picMode: widget.picMode,
        picDate: widget.picDate,
        userId: widget.userId,
        spotlightId: widget.spotlightId,
        relatedId: widget.relatedId,
        collectionId: widget.collectionId,
        artistId: widget.artistId,
        searchKeywords: widget.searchKeywords,
        onPageTop: widget.onPageTop,
        onPageStart: widget.onPageStart,
        onPageScrolling: widget.onPageScrolling,
        isManga: widget.isManga,
        isScrollable: widget.isScrollable);
    super.initState();
  }

  @override
  void didUpdateWidget(PicPage oldWidget) {
    if (widget.picDate != oldWidget.picDate ||
        widget.picMode != oldWidget.picMode ||
        widget.searchKeywords != oldWidget.searchKeywords)
      picPageModel = PicPageModel(
          context: context,
          jsonMode: widget.jsonMode,
          picMode: widget.picMode,
          picDate: widget.picDate,
          userId: widget.userId,
          spotlightId: widget.spotlightId,
          relatedId: widget.relatedId,
          collectionId: widget.collectionId,
          artistId: widget.artistId,
          searchKeywords: widget.searchKeywords,
          onPageTop: widget.onPageTop,
          onPageStart: widget.onPageStart,
          onPageScrolling: widget.onPageScrolling);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    picPageModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('build in PicPage');
    return ChangeNotifierProvider<PicPageModel>.value(
      value: picPageModel,
      child: Selector<PicPageModel, Tuple2<List, bool>>(
          selector: (BuildContext context, PicPageModel provider) {
        return Tuple2(provider.picList, provider.hasConnected);
      }, builder: (context, tuple, _) {
        print('PicPage Selector build with mode: ${widget.picMode}');
        if (tuple.item1 == null && !tuple.item2) {
          return Container(
              height: ScreenUtil().setHeight(576),
              width: ScreenUtil().setWidth(324),
              alignment: Alignment.center,
              color: Colors.white,
              child: Center(
                child: Lottie.asset('image/loading-box.json'),
              ));
        } else if (tuple.item1 == null && tuple.item2) {
          return Container(
            height: ScreenUtil().setHeight(576),
            width: ScreenUtil().setWidth(324),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Lottie.asset('image/empty-box.json',
                    repeat: false, height: ScreenUtil().setHeight(100)),
                Text(
                  '这里什么都没有呢',
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: ScreenUtil().setHeight(10),
                      decoration: TextDecoration.none),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(250),
                )
              ],
            ),
          );
        } else {
          return Container(
              padding: EdgeInsets.only(
                  left: ScreenUtil().setWidth(5),
                  right: ScreenUtil().setWidth(5)),
              color: Colors.grey[50],
              child: WaterfallFlow.builder(
                controller: picPageModel.scrollController,
                physics: picPageModel.isScrollable
                    ? ClampingScrollPhysics()
                    : NeverScrollableScrollPhysics(),
                itemCount: tuple.item1.length,
                itemBuilder: (BuildContext context, int index) {
                  return imageCell(
                      tuple.item1[index], index, context, picPageModel);
                },
                gridDelegate:
                    SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
              )
              // StaggeredGridView.countBuilder(
              //   controller: pageModel.scrollController,
              //   physics: pageModel.isScrollable
              //       ? ClampingScrollPhysics()
              //       : NeverScrollableScrollPhysics(),
              //   crossAxisCount: 2,
              //   itemCount: pageModel.picList.length,
              //   itemBuilder: (BuildContext context, int index) {
              //     return imageCell(pageModel.picList[index], index, context, pageModel);
              //   },
              //   staggeredTileBuilder: (index) => StaggeredTile.fit(1),
              //   mainAxisSpacing: 0.0,
              //   crossAxisSpacing: 0.0,
              // )

              );
        }
      }),
    );
  }

  List _picMainParameter(Map picItem) {
    // 预览图片的地址、数目、以及长宽比
    // String url = pageModel.picList[index]['imageUrls'][0]['squareMedium'];
    String previewQuality = prefs.getString('previewQuality');
    String url = picItem['imageUrls'][0][previewQuality]; //medium large
    int number = picItem['pageCount'];
    double width = picItem['width'].toDouble();
    double height = picItem['height'].toDouble();
    return [url, number, width, height];
  }

  Widget imageCell(
      Map picItem, int index, BuildContext context, PicPageModel pageModel) {
    final Color color = RandomColor().randomColor();
    Map picMapData = Map.from(picItem);
    if (picMapData['xrestict'] == 1 ||
        picMapData['sanityLevel'] > prefs.getInt('sanityLevel'))
      return Container();
    else
      return Container(
        padding: EdgeInsets.only(
          left: ScreenUtil().setWidth(5),
          right: ScreenUtil().setWidth(5),
          top: ScreenUtil().setWidth(10),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              child: ClipRRect(
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(15),
                child: GestureDetector(
                  onTap: () async {
                    // 对广告图片做区分判断
                    if (picMapData['type'] == 'ad_image') {
                      if (await canLaunch(picMapData['link'])) {
                        await launch(picMapData['link']);
                      } else {
                        BotToast.showSimpleNotification(title: '唤起网页失败');
                        throw 'Could not launch ${picMapData['link']}';
                      }
                    } else
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PicDetailPage(picMapData,
                                  index: index, getPageProvider: pageModel)));
                  },
                  child: ShaderMask(
                    shaderCallback: false
                        // TODO: 为画集设置的遮罩，勿修改
                        ? (bounds) => LinearGradient(
                                colors: [Colors.blue[200], Colors.blue[100]])
                            .createShader(bounds)
                        : (bounds) =>
                            LinearGradient(colors: [Colors.white, Colors.white])
                                .createShader(bounds),
                    child: Container(
                      // 限定constraints用于占用位置,经调试后以0.5为基准可以保证加载图片后不产生位移
                      constraints: BoxConstraints(
                        minHeight: ScreenUtil().setWidth(148) /
                            _picMainParameter(picItem)[2] *
                            _picMainParameter(picItem)[3],
                        minWidth: ScreenUtil().setWidth(148),
                      ),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Hero(
                        tag: 'imageHero' + _picMainParameter(picItem)[0],
                        child: Image(
                          image: AdvancedNetworkImage(
                            _picMainParameter(picItem)[0],
                            header: {'Referer': 'https://app-api.pixiv.net'},
                            useDiskCache: true,
                            cacheRule: CacheRule(
                                maxAge: Duration(
                                    days: prefs.getInt('previewRule'))),
                          ),
                          fit: BoxFit.fill,
                          frameBuilder:
                              (context, child, frame, wasSynchronouslyLoaded) {
                            if (wasSynchronouslyLoaded) {
                              return child;
                            }
                            return Container(
                              child: AnimatedOpacity(
                                child: frame == null
                                    ? Container(color: color)
                                    : child,
                                opacity: frame == null ? 0.3 : 1,
                                duration: const Duration(seconds: 1),
                                curve: Curves.easeOut,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              child: numberViewer(_picMainParameter(picItem)[1]),
              right: ScreenUtil().setWidth(10),
              top: ScreenUtil().setHeight(5),
            ),
            prefs.getString('auth') != '' && picMapData['type'] != 'ad_image'
                ? Positioned(
                    bottom: ScreenUtil().setHeight(5),
                    right: ScreenUtil().setWidth(5),
                    child: Container(
                        alignment: Alignment.center,
                        height: ScreenUtil().setWidth(33),
                        width: ScreenUtil().setWidth(33),
                        child: Selector<PicPageModel, bool>(
                          selector: (context, provider) =>
                              provider.picList[index]['isLiked'],
                          builder: (context, isLike, _) {
                            return MarkHeart(
                                picItem: picItem,
                                index: index,
                                getPageProvider: pageModel);
                          },
                        )))
                : Container(),
          ],
        ),
      );
  }

  Widget numberViewer(num numberOfPic) {
    return (numberOfPic != 1)
        ? Container(
            padding: EdgeInsets.all(ScreenUtil().setWidth(2)),
            decoration: BoxDecoration(
                color: Colors.black38, borderRadius: BorderRadius.circular(3)),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.content_copy,
                  color: Colors.white,
                  size: ScreenUtil().setWidth(10),
                ),
                Text(
                  '$numberOfPic',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil().setHeight(10),
                      decoration: TextDecoration.none),
                ),
              ],
            ),
          )
        : Container();
  }
}
