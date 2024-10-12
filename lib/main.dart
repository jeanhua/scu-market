import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scu_market/Core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'detailPage.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: "SCU market",
      home: IndexPage(),
    );
  }
}

class IndexPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return IndexPageState();
  }
}

class IndexPageState extends State<IndexPage>{

  //底部导航栏
  final List<BottomNavigationBarItem> bottomNavItems = [
    const BottomNavigationBarItem(
        backgroundColor: Colors.blue,
        icon: Icon(Icons.home),
        label: "帖子"
    ),
    const BottomNavigationBarItem(
        backgroundColor: Colors.blue,
        icon: Icon(Icons.money),
        label: "资源"
    ),
    const BottomNavigationBarItem(
        backgroundColor: Colors.blue,
        icon: Icon(Icons.image),
        label: "画廊"
    ),
  ];

  int currentIndex = 0;
  final pages = [const marketPage(), const resPage(),const galleryPage()];
  @override
  void initState() {
    super.initState();
    currentIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SCU market"),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: bottomNavItems,
        currentIndex: currentIndex,
        type: BottomNavigationBarType.shifting,
        onTap: (index) {
          _changePage(index);
        },
      ),
      body: pages[currentIndex],
    );
  }

  /*切换页面*/
  void _changePage(int index) {
    /*如果点击的导航项不是当前项  切换 */
    if (index != currentIndex) {
      setState(() {
        currentIndex = index;
      });
    }
  }
}

class marketPage extends StatefulWidget {
  const marketPage({super.key});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return marketPageState();
  }
}

class marketPageState extends State<marketPage> {
  int messageSize = 15;
  ScrollController messageViewController = ScrollController();
  var loadingContext = null;

  @override
  initState() {
    // TODO: implement initState
    super.initState();
    Core.updatePage = updatePage;
    Core.getMessage(messageSize);
  }

  updatePage() {
    closeLoadingDialog(context);
    setState(() {});
  }

  Future<void> refresh() async {
    showLoadingDialog(context);
    Core.getMessage(messageSize);
  }

  safeString(String text,int maxLength){
    if(text.length>maxLength){
      return "${text.substring(0,maxLength)}...";
    }
    return text;
  }

  // 显示加载对话框
  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击遮罩不关闭对话框
      builder: (BuildContext context) {
        loadingContext = context;
        return const AlertDialog(
          content: SizedBox(
            width: 100.0,
            height: 100.0,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  // 关闭加载对话框
  void closeLoadingDialog(BuildContext context) {
    if(loadingContext!=null){
      Navigator.of(loadingContext).pop();
      loadingContext = null;
    }
  }

  MessageItem(dynamic message) {
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
    return Padding(
        padding: const EdgeInsets.all(5),
        child:GestureDetector(
          onTap: (){
            // 点击事件
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>DetailPage(detail: message)));
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(150, 255, 255, 255),
              borderRadius: BorderRadius.circular(10),
            ),
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
                    Text(
                      "${safeString(message["user"]["nickname"], 10)} ",
                      style: const TextStyle(fontSize: 20),
                    ),
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
                          "${safeString(message["title"], 10)}",
                          style: const TextStyle(fontSize: 20),
                          overflow: TextOverflow.fade,
                        ))
                  ],
                ),
                // 内容
                Row(
                  children: [
                    Expanded(
                        child: Text(
                          "${safeString(message["content"], 20)}",
                          overflow: TextOverflow.fade,
                        ))
                  ],
                ),
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
                    Text("${message['reading']}次浏览 "),
                    Text(Core.timeAgo(message['created_at'])),
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
                )
              ],
            ),
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.blueAccent,
          ),
          child: RefreshIndicator(
              onRefresh: refresh,
              child: ListView.builder(
                  controller: messageViewController,
                  itemCount: Core.message.length + 1,
                  itemBuilder: (context, index) {
                    if (index == Core.message.length - 1) {
                      messageSize += 10;
                      Core.getMessage(messageSize);
                    }
                    if(index == Core.message.length){
                      return const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [CircularProgressIndicator()],
                      );
                    }
                    else{
                      return MessageItem(Core.message[index]);
                    }
                  })),
        ),
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
                  refresh();
                },
                icon: const Icon(
                  Icons.refresh,
                  size: 50,
                  color: Colors.redAccent,
                )),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 130,
          child: Container(
            decoration: BoxDecoration(
                color: const Color.fromARGB(150, 255, 255, 255),
                borderRadius: BorderRadius.circular(50),
                boxShadow: const [
                  BoxShadow(color: Colors.transparent, blurRadius: 5)
                ]),
            child: IconButton(
                onPressed: () {
                  messageViewController.animateTo(
                    0,
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                  );
                },
                icon: const Icon(
                  Icons.arrow_upward,
                  size: 50,
                  color: Colors.redAccent,
                )),
          ),
        ),
      ],
    );
  }
}


class resPage extends StatefulWidget{
  const resPage({super.key});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return resPageState();
  }
}

class resPageState extends State<resPage>{
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   webviewController.setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  var webviewController = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onHttpError: (HttpResponseError error) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse('https://www.res.jeanhua.cn/'));

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: [
        WebViewWidget(controller: webviewController),
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
                  launchUrl(Uri.parse("https://www.res.jeanhua.cn/"));
                  Clipboard.setData(const ClipboardData(text: "https://www.res.jeanhua.cn/")).then((_) {
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
    );
  }
}

class galleryPage extends StatefulWidget{
  const galleryPage({super.key});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return galleryPageState();
  }
}

class galleryPageState extends State<galleryPage>{
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  var webviewController = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onHttpError: (HttpResponseError error) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse('http://gallery.jeanhua.cn'));

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: [
        WebViewWidget(controller: webviewController),
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
                  launchUrl(Uri.parse("http://gallery.jeanhua.cn"));
                  Clipboard.setData(const ClipboardData(text: "http://gallery.jeanhua.cn")).then((_) {
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
    );
  }
}