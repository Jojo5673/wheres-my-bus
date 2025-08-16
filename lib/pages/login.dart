import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wheres_my_bus/app_state.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
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
        AuthStateChangeAction<SignedIn>((context, state) async {
          final appState = Provider.of<AppState>(context, listen: false);
          await appState.refreshUserType();
          //print("Going to ${appState.userType}");
          if (context.mounted) {
            //print("Going to ${appState.userType}");
            if (appState.userType == UserType.driver) {
              context.go('/driver');
            } else {
              context.go('/passenger');
            }
          }
        }),
      ],
    );
  }
}
