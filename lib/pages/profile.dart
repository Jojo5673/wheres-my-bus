import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wheres_my_bus/app_state.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(
      providers: const [],
      actions: [
        SignedOutAction((context) {
          context.pushReplacement('/');
        }),
        AccountDeletedAction((context, user) {
          final appState = Provider.of<AppState>(context, listen: false);
          try {
            appState.removeUser(user);
          } on Exception catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
          }
        }),
      ],
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
    );
  }
}
