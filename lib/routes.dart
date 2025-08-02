import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wheres_my_bus/app_state.dart';
import 'package:wheres_my_bus/driver/driver_home.dart';
import 'package:wheres_my_bus/pages/landing_page.dart';
import 'package:wheres_my_bus/passenger/passenger_home.dart';


final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => LandingPage(),
      routes: [
        GoRoute(
          path: 'sign-in',
          builder: (context, state) {
            return SignInScreen(
              actions: [
                ForgotPasswordAction(((context, email) {
                  final uri = Uri(
                    path: '/sign-in/forgot-password',
                    queryParameters: <String, String?>{'email': email},
                  );
                  context.push(uri.toString());
                })),
                AuthStateChangeAction(((context, state) {
                  final user = switch (state) {
                    SignedIn state => state.user,
                    UserCreated state => state.credential.user,
                    _ => null,
                  };
                  if (user == null) {
                    return;
                  }
                  if (state is UserCreated) {
                    user.updateDisplayName(user.email!.split('@')[0]);
                  }
                  if (!user.emailVerified) {
                    user.sendEmailVerification();
                    const snackBar = SnackBar(
                      content: Text(
                        'Please check your email to verify your email address',
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                  final userType =
                      Provider.of<AppState>(context, listen: false).userType;
                  if (userType == UserType.driver) {
                    context.pushReplacement('/driver');
                  } else {
                    context.pushReplacement('/passenger');
                  }
                })),
              ],
            );
          },
          routes: [
            GoRoute(
              path: 'forgot-password',
              builder: (context, state) {
                final arguments = state.uri.queryParameters;
                return ForgotPasswordScreen(
                  email: arguments['email'],
                  headerMaxExtent: 200,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) {
            return ProfileScreen(
              providers: const [],
              actions: [
                SignedOutAction((context) {
                  context.pushReplacement('/');
                }),
              ],
              appBar: AppBar(
                title: const Text("Profile"),
                backgroundColor: Theme.of(context).colorScheme.primary,
                centerTitle: true,
              ),
            );
          },
        ),
      ],
    ),
    GoRoute(path: '/passenger', builder: (context, state) => PassengerHome()),
    GoRoute(path: '/driver', builder: (context, state) => DriverHome()),
  ],
);
