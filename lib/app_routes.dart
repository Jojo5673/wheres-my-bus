import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:wheres_my_bus/models/route.dart';
import 'package:wheres_my_bus/pages/driver/driver_home.dart';
import 'package:wheres_my_bus/pages/driver/live_route.dart';
import 'package:wheres_my_bus/pages/landing_page.dart';
import 'package:wheres_my_bus/pages/login.dart';
import 'package:wheres_my_bus/pages/profile.dart';
import 'package:wheres_my_bus/pages/register.dart';
import 'package:wheres_my_bus/pages/info.dart';
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
    GoRoute(path: '/info', builder: (context, state) => InfoPage()),
    GoRoute(
      path: '/passenger',
      builder: (context, state) => PassengerHome(),
      routes: [
        GoRoute(
          path: '/map',
          builder: (context, state) {
            final favourite_routes = state.extra as List<BusRoute>;
            return LiveMap(favourite_routes: favourite_routes);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/driver',
      builder: (context, state) => DriverHome(),
      routes: [
        GoRoute(
          path: '/live',
          builder: (context, state) {
            // Access the extra data
            final route = state.extra as BusRoute;
            return LiveRoute(route: route);
          },
        ),
      ],
    ),

  ],
);
