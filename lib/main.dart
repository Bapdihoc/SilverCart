import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:silvercart/env.dart';
import 'package:silvercart/firebase_options.dart';
import 'package:silvercart/injection.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  showFlutterNotification(message);
  print('Handling a background message: ${message.messageId}');
}

/// Notification plugin instance
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

/// Notification channel
late AndroidNotificationChannel channel;

/// Flag to ensure plugin is initialized once
bool isFlutterLocalNotificationsInitialized = false;

/// Setup local notifications
Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) return;

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Create a notification channel for Android
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // name
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  // iOS presentation options
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  isFlutterLocalNotificationsInitialized = true;
}

/// Show a local notification manually
void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}

/// Foreground message handler
Future<void> _firebaseMessagingForegroundHandler(RemoteMessage message) async {
  showFlutterNotification(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request notification permission
  await FirebaseMessaging.instance.requestPermission();

  // Setup local notification channel
  await setupFlutterNotifications();

  // Listen to foreground messages
  FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);

  await dotenv.load(fileName: '.env');
  await configureDependencies(Environments.prod); // or Environments.dev
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isElderlyMode = false; // Có thể lấy từ SharedPreferences
  StreamSubscription<Uri>? _sub;
  AppLinks? _appLinks;

  void _toggleElderlyMode() {
    setState(() {
      _isElderlyMode = !_isElderlyMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SilverCart',
      debugShowCheckedModeBanner: false,
      theme: _isElderlyMode ? AppTheme.elderlyTheme : AppTheme.lightTheme,
      routerDelegate: AppRouter.router.routerDelegate,
      routeInformationParser: AppRouter.router.routeInformationParser,
      routeInformationProvider: AppRouter.router.routeInformationProvider,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            // Tăng text scale factor cho người cao tuổi
            textScaleFactor: _isElderlyMode ? 1.2 : 1.0,
          ),
          child: child!,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _handleInitialUri();
    _sub = _appLinks!.uriLinkStream.listen((uri) {
      log('uri2: $uri');
      // Handle custom scheme: silvercart://payment/callback?status=...
      if (uri.scheme == 'silvercart') {
        final combinedPath = '/${uri.host}${uri.path}'; // e.g. host=payment, path=/callback → /payment/callback
        if (combinedPath == '/payment/callback') {
          _handleDeepLinkOnce(uri, () {
            AppRouter.router.go('/payment/callback?status=${uri.queryParameters['status'] ?? 'success'}');
          });
          return;
        }
      }
      // Fallback for http(s) deep links where path contains payment/callback
      if (uri.path.contains('/payment/callback')) {
        _handleDeepLinkOnce(uri, () {
          AppRouter.router.go('/payment/callback?status=${uri.queryParameters['status'] ?? 'success'}');
        });
      }
    }, onError: (err) {});
  }

  Future<void> _handleInitialUri() async {
    try {
      final uri = await _appLinks?.getInitialAppLink();
      if (uri != null) {
        log('initial uri: $uri');
        if (uri.scheme == 'silvercart') {
          final combinedPath = '/${uri.host}${uri.path}';
          log('combinedPath: $combinedPath');
          if (combinedPath == '/payment/callback') {
            _handleDeepLinkOnce(uri, () {
              AppRouter.router.go('/payment/callback?status=${uri.queryParameters['status'] ?? 'success'}');
            });
            return;
          }
        }
        if (uri.path.contains('/payment/callback')) {
          _handleDeepLinkOnce(uri, () {
            AppRouter.router.go('/payment/callback?status=${uri.queryParameters['status'] ?? 'success'}');
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _handleDeepLinkOnce(Uri uri, VoidCallback onFirstHandle) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastLink = prefs.getString('last_handled_deep_link');
      final current = uri.toString();
      if (lastLink == current) {
        log('Deep link already handled, skipping: $current');
        return;
      }
      await prefs.setString('last_handled_deep_link', current);
      onFirstHandle();
    } catch (e) {
      onFirstHandle();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
