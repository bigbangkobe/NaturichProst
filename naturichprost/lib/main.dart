import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
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
    logger.d("初始化函数");
    init();
  }

  Future<void> init() async {
    String deviceId = await getDeviceId();
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
        ..loadRequest(Uri.parse('$url&fbc=$fbc&deviceId=$deviceId'));
      print("url:$url" ",fbc=$fbc");
    });
  }

  //获得设备码
  Future<String> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId = '';

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id; // 设备的唯一标识符
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor!; // 设备的唯一标识符
    }
    logger.d("deviceId=$deviceId");
    return deviceId;
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
