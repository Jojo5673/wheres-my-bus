import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wheres_my_bus/app_state.dart';

class Register extends StatelessWidget {
  const Register({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RegisterScreen(
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
            if (appState.userType == UserType.driver) {
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
              ButtonSegment(value: UserType.passenger, label: Text('Passenger')),
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
      ),
    );
  }
}
