import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

var logger = Logger();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebViewPage(),
    );
  }
}

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController controller;
  late String url;
  late String fbc;

  @override
  void initState() {
    super.initState();

    loadConfig().then((_) {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              // logger.d("onProgress$progress");
            },
            onPageStarted: (String url) {
              // logger.d("onPageStarted$url");
            },
            onPageFinished: (String url) {
              // logger.d("onPageFinished$url");
            },
            onHttpError: (HttpResponseError error) {
              // logger.d("onHttpError$error");
            },
            onWebResourceError: (WebResourceError error) {
              // logger.d("onWebResourceError$error");
            },
            onNavigationRequest: (NavigationRequest request) {
              // logger.d("onNavigationRequest$request");
              // 你可以根据需要判断并拦截 URL
              return NavigationDecision.navigate;
            },
          ),
        )
        // 将 URL 和 fbc 参数拼接到加载的 URL
        ..loadRequest(Uri.parse('$url&fbc=$fbc'));
      logger.d("url:$url" ",fbc=$fbc");
    });
  }

  // 加载config.json
  Future<void> loadConfig() async {
    // 通过根目录加载config.json文件
    final String response =
        await rootBundle.loadString('assets/config/config.json');
    final Map<String, dynamic> data = json.decode(response);

    setState(() {
      url = data['url']; // 获取 URL
      fbc = data['fbc']; // 获取 fbc 参数
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0), // 设置高度为0，隐藏 AppBar
        child: SafeArea(
          top: false, // 不考虑顶部刘海区域
          child: Container(), // 空的容器
        ),
      ),
      body: WebViewWidget(controller: controller), // 使用 WebView 控制器加载网页
    );
  }
}
