import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';

import 'package:pixivic/biz/PixivSuggestions/service/PixivSuggestionsService.dart';
import 'package:pixivic/common/config/GetItConfig.dart';
import 'package:pixivic/common/do/PixivSuggestions.dart';

import 'package:pixivic/function/dio_client.dart';

class SuggestionBar extends StatefulWidget {
  @override
  SuggestionBarState createState() => SuggestionBarState();

  SuggestionBar(this.searchKeywordsIn, this.onCellTap, this.key);

  final String searchKeywordsIn;
  final ValueChanged<String> onCellTap;
  final Key key;
}

class SuggestionBarState extends State<SuggestionBar> {
  String searchKeywords;
  List<PixivSuggestions> suggestions;

  @override
  void initState() {
    print('SuggestionBar Created');
    searchKeywords = widget.searchKeywordsIn;
    _loadSuggestions().then((value) {
      setState(() {
        suggestions = value;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    print('SuggestionBar Disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (suggestions != null) {
      return AnimatedContainer(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeInOutExpo,
        height: ScreenUtil().setHeight(36),
        width: ScreenUtil().setWidth(324),
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              var keywordsColumn;
              if (suggestions[index].keywordTranslated != '') {
                keywordsColumn = Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      suggestionsKeywordsText(suggestions[index].keyword),
                      suggestionsKeywordsText(
                          suggestions[index].keywordTranslated),
                    ]);
              } else {
                keywordsColumn =
                    suggestionsKeywordsText(suggestions[index].keyword);
              }

              return GestureDetector(
                onTap: () {
                  widget.onCellTap(suggestions[index].keyword);
                },
                child: Container(
                  margin: EdgeInsets.all(ScreenUtil().setWidth(2)),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(3)),
                    color: Color(0xFFB9EEE5),
                  ),
                  // width: ScreenUtil().setWidth(80),
                  padding: EdgeInsets.all(ScreenUtil().setWidth(4)),
                  child: Center(
                    child: keywordsColumn,
                  ),
                ),
              );
            }),
      );
    } else {
      return Center();
    }
  }

  Widget suggestionsKeywordsText(String suggestions) {
    return Text(
      suggestions,
      strutStyle: StrutStyle(
        fontSize: 10,
      ),
      style: TextStyle(color: Colors.white, fontSize: 10),
    );
  }

  _loadSuggestions() async {
    print('reloading suggestions');
    List jsonList;
    Response response;

    String urlPixiv = '/keywords/$searchKeywords/pixivSuggestions';
    // String urlPixivic =
    //     'https://pix.ipv4.host/keywords/$searchKeywords/suggestions';

    try {
      return getIt<PixivSuggestionsService>()
          .queryPixivSuggestions(searchKeywords)
          .then((value) => value.data);
    } catch (e) {
      print(e);
    }
  }

  void reloadSearchWords(String value) async {
    this.searchKeywords = value;
    _loadSuggestions().then((value) {
      setState(() {
        if (value != null) this.suggestions = value;
      });
    });
  }
}
