import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;

class Core{
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
    for(var item in result["data"]["list"]){
      message.add(item);
    }
    updatePage();
  }

}