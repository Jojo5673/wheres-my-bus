import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wheres_my_bus/app_state.dart';
import 'package:wheres_my_bus/widgets/auth_widgets.dart';
import 'package:go_router/go_router.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  Timer? _redirectTimer;
  bool _showContent = false;
  AppState? appState;

  @override
  void initState() {
    super.initState();
    // Small delay before showing any content
    Timer(Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _showContent = true;
        });
        _startRedirectTimer();
      }
    });
    appState = Provider.of<AppState>(context, listen: false);
  }

  void _startRedirectTimer() {
    _redirectTimer = Timer(Duration(seconds: 2), () {
      if (!mounted) return; // Safety check

      if (appState!.loggedIn) {
        if (appState!.userType == UserType.driver) {
          context.pushReplacement('/driver');
        } else if (appState!.userType == UserType.passenger) {
          context.pushReplacement('/passenger');
        }
      }
    });
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Center(
                child: Text(
                  "Where's My Bus?",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Arial',
                  ),
                ),
              ),
            ),
            // Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/logo.jpeg',
                height: 240,
                fit: BoxFit.contain,
              ),
            ),
            // Buttons - only show if not logged in
            Padding(
              padding: const EdgeInsets.only(
                bottom: 40.0,
                left: 20.0,
                right: 20.0,
              ),
              child:_showContent
                ? () {
                  if (appState!.loggedIn) {
                    return Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Welcome back!'),
                      ],
                    );
                  }
                  return Signin(setUser: appState!.setUserType);
                }()
                : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
