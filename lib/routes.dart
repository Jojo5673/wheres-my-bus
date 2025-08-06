import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wheres_my_bus/driver/driver_home.dart';
import 'package:wheres_my_bus/pages/landing_page.dart';
import 'package:wheres_my_bus/pages/login.dart';
import 'package:wheres_my_bus/pages/profile.dart';
import 'package:wheres_my_bus/pages/sign_up.dart';
import 'package:wheres_my_bus/passenger/passenger_home.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => LandingPage()),
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => Login(context, state),
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
    GoRoute(
      path: '/sign-up',
      builder:
          (context, state) =>
              Scaffold(body: SignUp(context, state)), //makes keyboard not cover text fields
    ),
    GoRoute(path: '/profile', builder: (context, state) => Profile(context, state)),
    GoRoute(path: '/passenger', builder: (context, state) => PassengerHome()),
    GoRoute(path: '/driver', builder: (context, state) => DriverHome()),
  ],
);
