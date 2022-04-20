// ignore_for_file: prefer_const_constructors_in_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ResponseViewerPage extends StatelessWidget {
  final String data;
  ResponseViewerPage({
    Key? key,
    required this.data,
  }) : super(key: key);

  late final WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Response Viewer'),
      ),
      body: Center(
        child: WebView(
          initialUrl: '',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _webViewController = webViewController;
            loadAsset();
          },
        ),
      ),
    );
  }

  loadAsset() async {
    String fileHtmlContents = data;
    _webViewController.loadUrl(
        Uri.dataFromString(fileHtmlContents, mimeType: 'text/html', encoding: Encoding.getByName('utf-8')).toString());
  }
}
