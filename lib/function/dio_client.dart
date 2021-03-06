import 'package:dio/dio.dart';
// import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:pixivic/data/common.dart';

Dio dioPixivic;

initDioClient() {
  dioPixivic = Dio(BaseOptions(
      baseUrl: 'https://pix.ipv4.host',
      connectTimeout: 150000,
      receiveTimeout: 150000,
      headers: prefs.getString('auth') == ''
          ? {'Content-Type': 'application/json'}
          : {
              'authorization': prefs.getString('auth'),
              'Content-Type': 'application/json'
            }));
  // dioPixivic.httpClientAdapter = Http2Adapter(
  //   ConnectionManager(
  //     idleTimeout: 10000,

  //     /// Ignore bad certificate
  //     onClientCreate: (_, clientSetting) =>
  //         clientSetting.onBadCertificate = (_) => true,
  //   ),
  // );
  dioPixivic.interceptors
      .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
    print(options.uri);
    print(options.headers);
    return options;
  }, onResponse: (Response response) async {
    // print(response.data);
    // BotToast.showSimpleNotification(title: response.data['message']);
    if (response.statusCode == 200 &&
        response.headers.map['authorization'] != null &&
        prefs.getString('auth') != response.headers.map['authorization'][0]) {
      prefs.setString('auth', response.headers.map['authorization'][0]);
    }
    return response;
  }, onError: (DioError e) async {
    if (e.response != null) {
      print(e.response);
      print(e.response.statusCode.toString());
      print(e.response.data);
      print(e.response.headers);
      print(e.response.request);
      if (e.response.statusCode == 400)
        BotToast.showSimpleNotification(title: '请登陆后重新加载页面');
      else if (e.response.statusCode == 500) {
        print('500 error');
      } else if (e.response.statusCode == 401 || e.response.statusCode == 403) {
        BotToast.showSimpleNotification(title: '登陆已失效，请重新登陆');
      } else if (e.response.data['message'] != '')
        BotToast.showSimpleNotification(title: e.response.data['message']);
      return false;
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      if (e.message != '') BotToast.showSimpleNotification(title: e.message);
      print(e.request);
      print(e.message);
      return false;
    }
  }));
}
