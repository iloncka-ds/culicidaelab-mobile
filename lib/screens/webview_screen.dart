import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Import AppLocalizations if you need to localize strings within this screen,
// like a loading message or error message, though for a simple WebView,
// the title is passed in.
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const WebViewScreen({Key? key, required this.title, required this.url}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _loadingError;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
            // You can add a LinearProgressIndicator if you want
            print('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _loadingError = null;
            });
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            print('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _loadingError = '''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''';
            });
            print(_loadingError);
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) { // Example: prevent navigation to youtube
              print('blocking navigation to $request');
              return NavigationDecision.prevent;
            }
            print('allowing navigation to $request');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    // final localizations = AppLocalizations.of(context)!; // If needed for internal strings

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          // Optional: Add refresh button for WebView
          if (!_isLoading && _loadingError == null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _controller.reload(),
            ),
        ],
      ),
      body: Stack(
        children: [
          if (_loadingError != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      "Failed to load page", // Should be localized: localizations.webViewFailedToLoad,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.url,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                     const SizedBox(height: 16),
                    ElevatedButton(
                        onPressed: () => _controller.loadRequest(Uri.parse(widget.url)),
                        child: const Text("Retry") // Should be localized
                    )
                    // For debugging, you could display _loadingError
                    // Text(_loadingError!, style: TextStyle(color: Colors.red.shade300)),
                  ],
                ),
              ),
            )
          else
            WebViewWidget(controller: _controller),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}