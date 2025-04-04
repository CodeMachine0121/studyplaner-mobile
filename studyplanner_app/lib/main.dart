import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:webview_flutter/webview_flutter.dart';
// Import platform-specific implementations
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize WebView if on mobile platforms and not on web
  if (!kIsWeb && (io.Platform.isAndroid || io.Platform.isIOS)) {
    initWebViewPlatform();
  }
  runApp(const MyApp());
}

void initWebViewPlatform() {
  // Initialize WebView for the current platform
  if (WebViewPlatform.instance == null) {
    if (io.Platform.isAndroid) {
      WebViewPlatform.instance = AndroidWebViewPlatform();
    } else if (io.Platform.isIOS) {
      WebViewPlatform.instance = WebKitWebViewPlatform();
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Planner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WebViewPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController? controller;
  bool isLoading = true;
  bool isMobileDevice = !kIsWeb && (io.Platform.isAndroid || io.Platform.isIOS);
  final String targetUrl = 'http://localhost:8080';

  @override
  void initState() {
    super.initState();
    
    if (isMobileDevice) {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              if (progress == 100) {
                setState(() {
                  isLoading = false;
                });
              }
            },
            onPageStarted: (String url) {
              setState(() {
                isLoading = true;
              });
            },
            onPageFinished: (String url) {
              setState(() {
                isLoading = false;
              });
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('Web resource error: ${error.description}');
            },
          ),
        )
        ..loadRequest(Uri.parse(targetUrl));
    } else {
      // For desktop platforms, we don't initialize the controller
      controller = null;
      // Set loading to false since we're not actually loading a WebView
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Planner'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (isMobileDevice)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                controller?.reload();
              },
            ),
        ],
      ),
      body: isMobileDevice ? _buildMobileView() : _buildDesktopView(),
    );
  }

  Widget _buildMobileView() {
    return Stack(
      children: [
        if (controller != null) WebViewWidget(controller: controller!),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildDesktopView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.desktop_mac, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'WebView is not supported on this platform.',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          const Text(
            'Please use a mobile device or access directly in a browser:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Text(
            targetUrl,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              final Uri url = Uri.parse(targetUrl);
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                debugPrint('Could not launch $url');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not open $targetUrl')),
                  );
                }
              }
            },
            child: const Text('Open in Browser'),
          ),
        ],
      ),
    );
  }
}
