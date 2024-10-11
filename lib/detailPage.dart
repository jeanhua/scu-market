import 'dart:convert';

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
        body: Container(
          decoration: const BoxDecoration(color: Colors.grey),
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
                        decoration: BoxDecoration(color: Colors.teal,borderRadius: BorderRadius.circular(15)),
                        height: 270,
                        child: ListView.builder(
                          addAutomaticKeepAlives: true,
                            itemCount: imageNums,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10)),
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
              Expanded(
                  child: ListView.builder(
                      itemCount: remarks.length,
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
                                      style: const TextStyle(fontSize: 20,color: Colors.blueAccent),
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
                      }))
            ],
          ),
        ));
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
