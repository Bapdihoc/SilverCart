import 'package:go_router/go_router.dart';
import 'package:silvercart/page/home.dart';
import 'package:silvercart/page/auth/role_selection_page.dart';
import 'package:silvercart/page/auth/login_page.dart';
import 'package:silvercart/page/auth/elderly_login_page.dart';
import 'package:silvercart/page/auth/register_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/role-selection',
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
    ],
  );
}
