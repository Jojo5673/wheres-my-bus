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
    GoRoute(path: '/', builder: (context, state) => LandingPage()),
    GoRoute(
      path: '/sign-in',
      builder: (context, state) {
        return SignInScreen(
          showAuthActionSwitch: false,
          footerBuilder: (context, _) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don’t have an account?"),
                  TextButton(
                    onPressed: () {
                      context.go('/sign-up');
                    },
                    child: const Text("Sign up"),
                  ),
                ],
              ),
            );
          },
          actions: [
            ForgotPasswordAction(((context, email) {
              final uri = Uri(
                path: '/sign-in/forgot-password',
                queryParameters: <String, String?>{'email': email},
              );
              context.push(uri.toString());
            })),
            AuthStateChangeAction<SignedIn>((context, state) async{
              final appState = Provider.of<AppState>(context, listen: false);
              await appState.refreshUserType();
              print("Going to ${appState.userType}");
              if (appState.userType == UserType.driver) {
                context.go('/driver');
              } else {
                context.go('/passenger');
              }
            }),
          ],
        );
      },
      routes: [
        GoRoute(
          path: '/forgot-password',
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
      path: '/profile',
      builder: (context, state) {
        return ProfileScreen(
          providers: const [],
          actions: [
            SignedOutAction((context) {
              context.pushReplacement('/');
            }),
            AccountDeletedAction((context, user){
              final appState = Provider.of<AppState>(context, listen: false);
              appState.removeUser(user);
            })
          ],
          appBar: AppBar(
            title: const Text("Profile"),
            backgroundColor: Theme.of(context).colorScheme.primary,
            centerTitle: true,
          ),
        );
      },
    ),
    GoRoute(
      path: '/sign-up',
      builder: (context, state) {
        return RegisterScreen(
          showAuthActionSwitch: false,
          actions: [
            AuthStateChangeAction(((context, state) {
              final appState = Provider.of<AppState>(context, listen: false);
              final user = switch (state) {
                SignedIn state => state.user,
                UserCreated state => state.credential.user,
                _ => null,
              };
              if (user == null) {
                return;
              }
              if (state is UserCreated) {
                print("Check user email isnt null in routes: ${user.email}");
                user.updateDisplayName(user.email!.split('@')[0]);
                appState.addUser(user, appState.userType);
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
              print("Going to ${appState.userType}");
              if ( appState.userType == UserType.driver) {
                context.go('/driver');
              } else {
                context.go('/passenger');
              }
            })),
          ],
          subtitleBuilder: (context, action) {
            final appState = Provider.of<AppState>(context, listen: true);
            final userType = appState.userType;
            return SegmentedButton<UserType>(
              segments: const [
                ButtonSegment(
                  value: UserType.passenger,
                  label: Text('Passenger'),
                ),
                ButtonSegment(value: UserType.driver, label: Text('Driver')),
              ],
              selected: {userType},
              onSelectionChanged: (newSelection) {
                appState.setUserType(newSelection.first);
              },
            );
          },
          footerBuilder: (context, _) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      context.go('/sign-in');
                    },
                    child: const Text("Sign in"),
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
    GoRoute(path: '/passenger', builder: (context, state) => PassengerHome()),
    GoRoute(path: '/driver', builder: (context, state) => DriverHome()),
  ],
);
