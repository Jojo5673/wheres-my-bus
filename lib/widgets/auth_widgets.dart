import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wheres_my_bus/app_state.dart';

class Signin extends StatelessWidget {
  const Signin({
    super.key,
    required this.setUser,
  });

  final Function(UserType) setUser;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          height: 60, // half of the screen
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () {
              setUser(UserType.passenger);
              context.push('/sign-in');
            },
            child: Text(
              "Sign in as a Passenger",
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
        ),
        SizedBox(height: 20),
        SizedBox(
          height: 60,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow[700],
            ),
            onPressed: () {
              setUser(UserType.driver);
              context.push('/sign-in');
            },
            child: Text(
              "Sign in as a Bus Driver",
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}