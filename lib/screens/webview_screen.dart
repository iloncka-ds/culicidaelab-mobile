import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const WebViewScreen({Key? key, required this.title, required this.url}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? _webViewController;
  PullToRefreshController? _pullToRefreshController;
  double _progress = 0;
  String? _error;

  @override
  void initState() {
    super.initState();

    _pullToRefreshController = PullToRefreshController(
      onRefresh: () async {
        if (Theme.of(context).platform == TargetPlatform.android) {
          _webViewController?.reload();
        } else if (Theme.of(context).platform == TargetPlatform.iOS) {
          _webViewController?.loadUrl(
              urlRequest: URLRequest(url: await _webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _webViewController?.reload();
            },
          )
        ],
      ),
      body: Stack(
        children: [
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      "Failed to load page",
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _webViewController?.reload();
                        setState(() {
                          _error = null;
                        });
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            )
          else
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              pullToRefreshController: _pullToRefreshController,
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() {
                  _progress = 0;
                });
              },
              onLoadStop: (controller, url) {
                _pullToRefreshController?.endRefreshing();
                setState(() {
                  _progress = 1;
                });
              },
              onProgressChanged: (controller, progress) {
                if (progress == 100) {
                  _pullToRefreshController?.endRefreshing();
                }
                setState(() {
                  _progress = progress / 100;
                });
              },
              onLoadError: (controller, url, code, message) {
                _pullToRefreshController?.endRefreshing();
                setState(() {
                  _error = "Error: $message (Code: $code)";
                });
              },
              onLoadHttpError: (controller, url, statusCode, description) {
                _pullToRefreshController?.endRefreshing();
                setState(() {
                  _error = "HTTP Error: $description (Code: $statusCode)";
                });
              },
              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                // This is the insecure part that bypasses SSL certificate validation.
                // This should only be used for development/testing.
                return ServerTrustAuthResponse(
                    action: ServerTrustAuthResponseAction.PROCEED);
              },
            ),
          if (_progress < 1.0 && _error == null)
            LinearProgressIndicator(value: _progress),
        ],
      ),
    );
  }
}
