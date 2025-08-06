import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wheres_my_bus/app_state.dart';

ProfileScreen Profile(BuildContext context, GoRouterState state) {
  return ProfileScreen(
    providers: const [],
    actions: [
      SignedOutAction((context) {
        context.pushReplacement('/');
      }),
      AccountDeletedAction((context, user) {
        final appState = Provider.of<AppState>(context, listen: false);
        appState.removeUser(user);
      }),
    ],
    appBar: AppBar(
      title: const Text("Profile"),
      backgroundColor: Theme.of(context).colorScheme.primary,
      centerTitle: true,
    ),
  );
}
