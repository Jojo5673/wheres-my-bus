import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:wheres_my_bus/pages/driver/driver_home.dart';
import 'package:wheres_my_bus/pages/landing_page.dart';
import 'package:wheres_my_bus/pages/login.dart';
import 'package:wheres_my_bus/pages/profile.dart';
import 'package:wheres_my_bus/pages/register.dart';
import 'package:wheres_my_bus/pages/passenger/live_map.dart';
import 'package:wheres_my_bus/pages/passenger/passenger_home.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => LandingPage()),
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => Login(),
      routes: [
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) {
            final arguments = state.uri.queryParameters;
            return ForgotPasswordScreen(email: arguments['email'], headerMaxExtent: 200);               
          },
        ),
      ],
    ),
    GoRoute(path: '/sign-up', builder: (context, state) => Register()),
    GoRoute(path: '/profile', builder: (context, state) => Profile()),
    GoRoute(path: '/passenger', builder: (context, state) => PassengerHome(), routes: [
      GoRoute(path: '/map', builder: (context, state) => LiveMap()),
    ]),
    GoRoute(path: '/driver', builder: (context, state) => DriverHome()),
  ],
);
