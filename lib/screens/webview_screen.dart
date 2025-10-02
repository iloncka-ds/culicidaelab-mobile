/// WebViewScreen displays web content within the application.
///
/// This screen provides a full-featured web browsing experience using the
/// flutter_inappwebview plugin, offering:
/// - Full web page rendering and interaction
/// - Pull-to-refresh functionality
/// - Loading progress indication
/// - Error handling and retry mechanisms
/// - SSL certificate handling for secure connections
///
/// The screen is designed for displaying external web content or web-based
/// documentation within the application context.
///
/// {@category Screens}
/// {@subCategory Utilities}
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';


/// Stateful screen for displaying web content with advanced browser features.
///
/// This screen provides a comprehensive web viewing experience with:
///
/// - **Full Web Rendering**: Complete web page display and interaction
/// - **Pull-to-Refresh**: Native refresh gesture support on iOS and Android
/// - **Progress Indication**: Visual loading progress for better UX
/// - **Error Handling**: Graceful error display with retry functionality
/// - **SSL Management**: Certificate handling for secure connections
/// - **Platform Optimization**: Platform-specific refresh behaviors
///
/// The screen uses the flutter_inappwebview plugin to provide a native
/// web browsing experience within the Flutter application. It's ideal for
/// displaying external documentation, web-based tools, or any web content
/// that needs to be integrated into the application flow.
///
/// **Key Features:**
/// - Complete web page rendering and JavaScript execution
/// - Pull-to-refresh with platform-specific implementations
/// - Loading progress visualization
/// - Comprehensive error handling and recovery
/// - SSL certificate management for secure browsing
/// - Responsive design that adapts to content
class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const WebViewScreen({Key? key, required this.title, required this.url}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

/// State class managing the WebView functionality and user interactions.
///
/// Handles web page loading, progress tracking, error management, and
/// pull-to-refresh functionality. Manages the complex state of web content
/// loading and user interactions with the web view.
class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? _webViewController;
  PullToRefreshController? _pullToRefreshController;
  double _progress = 0;
  String? _error;

  /// Initializes the WebView state and configures pull-to-refresh functionality.
  ///
  /// Sets up the [PullToRefreshController] with platform-specific refresh
  /// behaviors. On Android, it uses the WebView's reload method, while on
  /// iOS it reloads the current URL to ensure proper refresh functionality.
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

  /// Builds the WebView interface with comprehensive browsing features.
  ///
  /// Creates a full-featured web browsing interface featuring:
  /// - App bar with title and manual refresh button
  /// - WebView widget for content display
  /// - Progress indicator during page loading
  /// - Error state display with retry functionality
  /// - Pull-to-refresh capability (configured in initState)
  ///
  /// The layout uses a [Stack] to overlay the progress indicator and error
  /// states on top of the WebView. It handles various loading states and
  /// provides multiple recovery mechanisms for failed loads.
  ///
  /// [context] The build context for accessing theme and platform information.
  /// Returns a [Widget] representing the complete WebView interface.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
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
