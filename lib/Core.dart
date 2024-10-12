import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;

class Core {
  static List message = [];
  static late VoidCallback updatePage;
  static getMessage(int size) async {
    final params = {
      'size': '$size',
    };
    final url = Uri.parse('https://u.xiaouni.com/user-api/content/article/list')
        .replace(queryParameters: params);
    final res = await http.get(url);
    final status = res.statusCode;
    if (status != 200) throw Exception('http.get error: statusCode= $status');
    var result = jsonDecode(res.body);
    message.clear();
    for (var item in result["data"]["list"]) {
      message.add(item);
    }
    updatePage();
  }

  static getReplyDetail(String topicId,String commentId) async {
    final params = {
      'comment_id': commentId,
      "topic_id":topicId
    };
    final url = Uri.parse('https://u.xiaouni.com/user-api/replay/list')
        .replace(queryParameters: params);
    final res = await http.get(url);
    final status = res.statusCode;
    if (status != 200) throw Exception('http.get error: statusCode= $status');
    var result = jsonDecode(res.body);
    return result['data']['list'];
  }

  static String timeAgo(int timestamp) {
    DateTime now = DateTime.now();
    DateTime pastTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    // 如果时间戳比现在的时间要大，返回空字符串
    if (pastTime.isAfter(now)) {
      return '';
    }
    Duration diff = now.difference(pastTime);
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}秒前';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 30) {
      return '${diff.inDays}天前';
    } else if (diff.inDays < 365) {
      int months = (diff.inDays / 30).floor();
      return '${months}个月前';
    } else {
      int years = (diff.inDays / 365).floor();
      return '${years}年前';
    }
  }
}
