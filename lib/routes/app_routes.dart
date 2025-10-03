import 'package:go_router/go_router.dart';
import 'package:silvercart/page/home.dart';
import 'package:silvercart/page/auth/role_selection_page.dart';
import 'package:silvercart/page/auth/login_page.dart';
import 'package:silvercart/page/auth/elderly_login_page.dart';
import 'package:silvercart/page/auth/register_page.dart';
import 'package:silvercart/page/settings/user_profile_page.dart';
import 'package:silvercart/page/payment/payment_callback_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/role-selection',
    redirect: (context, state) {
      final uri = state.uri;
      // Normalize external deeplinks like silvercart://payment/callback?status=...
      if (uri.scheme == 'silvercart') {
        final combinedPath = '/${uri.host}${uri.path}';
        if (combinedPath == '/payment/callback') {
          final status = uri.queryParameters['status'] ?? 'success';
          return '/payment/callback?status=$status';
        }
        // Unknown deep link → fallback home
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'];
          return HomePage(role: role);
        },
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionPage(),
      ),
      GoRoute(
        path: '/login/family',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/login/elderly',
        builder: (context, state) => const ElderlyLoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/user-profile',
        builder: (context, state) => const UserProfilePage(),
      ),
      GoRoute(
        path: '/payment/callback',
        builder: (context, state) {
          final status = state.uri.queryParameters['status'] ?? 'success';
          return PaymentCallbackPage(status: status);
        },
      ),
    
    ],
  );
}
 
