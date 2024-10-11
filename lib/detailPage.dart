import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.detail});
  final dynamic detail;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DetailPageState(message: detail);
  }
}

class DetailPageState extends State<DetailPage> {
  DetailPageState({required this.message});
  final dynamic message;
  var remarks = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRemarks();
  }

  void notice_dialog(String noticeText, [String title = "提示"]) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content: Text(
            noticeText,
            style: const TextStyle(fontSize: 20),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> getRemarks() async {
    final params = {
      'topic_id': '${message['id']}',
    };
    final url = Uri.parse('https://u.xiaouni.com/user-api/comment/list')
        .replace(queryParameters: params);
    final res = await http.get(url);
    final status = res.statusCode;
    if (status != 200) throw Exception('http.get error: statusCode= $status');
    var result = jsonDecode(res.body);
    remarks.clear();
    for (var it in result['data']['list']) {
      remarks.add(it);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var imageNums = 0;
    var headImage;
    try {
      imageNums = (message['images'] as List).length;
    } catch (e) {
      imageNums = 0;
    }
    try {
      var imageUrl = message["user"]["portrait"] as String;
      headImage = Image.network(
        imageUrl,
        fit: BoxFit.fill,
      );
    } catch (e) {
      headImage = const Icon(Icons.person);
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text("scu market"),
        ),
        body: Stack(
          children: [
            Container(
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(color: Colors.blue),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: headImage,
                            ),
                          ),
                          Expanded(
                              child: Text(
                                "${(message["user"]["nickname"])} ",
                                style: const TextStyle(fontSize: 20),
                                overflow: TextOverflow.fade,
                              )),
                          Text(
                            "${message["user"]["leaver_name"]}",
                            style: const TextStyle(
                              color: Colors.black,
                              backgroundColor: Colors.green,
                            ),
                          )
                        ],
                      ),
                      // 标题
                      Row(
                        children: [
                          Expanded(
                              child: Text(
                                "${message["title"]}",
                                style: const TextStyle(fontSize: 25),
                                overflow: TextOverflow.fade,
                              ))
                        ],
                      ),
                      // 内容
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(
                                  "${message["content"]}",
                                  overflow: TextOverflow.fade,
                                  style: const TextStyle(fontSize: 18),
                                ))
                          ],
                        ),
                      ),
                      imageNums == 0
                          ? const Divider()
                          : Padding(
                          padding: const EdgeInsets.all(20),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.teal,
                                borderRadius: BorderRadius.circular(15)),
                            child: ListView.builder(
                                addAutomaticKeepAlives: true,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: imageNums,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 150,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(10)),
                                    child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    HeroPhotoViewWrapper(
                                                      imageProvider: NetworkImage(
                                                          message['images'][index]),
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Hero(
                                            tag: message['images'][index],
                                            child: Image.network(
                                              message['images'][index],
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                        )),
                                  );
                                }),
                          )),
                      Row(
                        children: [
                          const Icon(Icons.image),
                          Expanded(
                              child: Text(
                                "$imageNums张图片  ${message['school']['name']}  #${message['classify']['name']}",
                                overflow: TextOverflow.fade,
                              ))
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.remove_red_eye),
                          Text("${message['reading']}次浏览"),
                          Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Icon(
                                    Icons.thumb_up,
                                    size: 20,
                                  ),
                                  Text("${message['art_like']}"),
                                  const Icon(
                                    Icons.message,
                                    size: 20,
                                  ),
                                  Text("${message['comment_count']}"),
                                ],
                              ))
                        ],
                      ),
                      const Text(
                        "评论",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: remarks.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            var remark = remarks[index];
                            return Padding(
                              padding: const EdgeInsets.all(2),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white54,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(15),
                                            child: Image.network(
                                              remark['user']['portrait'],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${remark['user']['nickname']} ",
                                          style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.blueAccent),
                                        ),
                                        Text(
                                          "${remark["user"]["leaver_name"]}",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            backgroundColor: Colors.green,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: Text(
                                              "${remark['content']}",
                                              overflow: TextOverflow.fade,
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                            ))
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          })
                    ],
                  ),
                )),
            Positioned(
              right: 0,
              bottom: 50,
              child: Container(
                decoration: BoxDecoration(
                    color: const Color.fromARGB(150, 255, 255, 255),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: const [
                      BoxShadow(color: Colors.transparent, blurRadius: 5)
                    ]),
                child: IconButton(
                    onPressed: () {
                      // 跳转原帖
                      launchUrl(Uri.parse("https://u.xiaouni.com/mobile/pages/pd/pd?id=${message['id']}"));
                      Clipboard.setData(ClipboardData(text: "https://u.xiaouni.com/mobile/pages/pd/pd?id=${message['id']}")).then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('已复制链接到粘贴板!')),
                        );
                      });
                    },
                    icon: const Icon(
                      Icons.remove_red_eye,
                      size: 50,
                      color: Colors.redAccent,
                    )),
              ),
            )
          ],
        )
    );
  }
}

class HeroPhotoViewWrapper extends StatelessWidget {
  final ImageProvider imageProvider;

  const HeroPhotoViewWrapper({
    Key? key,
    required this.imageProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Preview'),
      ),
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: PhotoView(
          imageProvider: imageProvider,
          heroAttributes: PhotoViewHeroAttributes(tag: imageProvider),
        ),
      ),
    );
  }
}
