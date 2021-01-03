import 'package:injectable/injectable.dart';
import 'package:pixivic/http/client/CommentRestClient.dart';

import 'package:pixivic/common/do/Result.dart';
import 'package:pixivic/common/do/Comment.dart';

@lazySingleton
class CommentService {
  final CommentRestClient _commentRestClient;

  CommentService(this._commentRestClient);

  Future<Result<CommentList>> queryCommentInfo(
      int illustId, int page, int pageSize) {
    return _commentRestClient
        .queryCommentInfo(illustId, page, pageSize)
        .then((value) {
      List<Comment> commentList = [];
      value.data.map((s) => Comment.fromJson(s)).toList().forEach((e) {
        commentList.add(e);
      });
      value.data = commentList;
      return value;
    });
  }
}
