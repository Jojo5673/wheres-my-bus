import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Where's My Bus? "),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Where's My Bus?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                "This app was developed by Joseph and Demaria, two University students excited to make a difference. \n\n\n"
                "Where's My Bus? helps passengers track live buses across Jamaica and in the future, the whole world.\n\n"
                "We hope to create a future where public transportation is a hassle of the past, and that efficient, reliable information on transport systems is the new norm.\n\n"
                "In Where's My Bus? we have numerous features. \n\n"
                "Features:\n"
                "• Live bus tracking\n"
                "• Favourite routes\n"
                "• Real time driver updates\n"
                "• User-friendly design.\n\n\n\n"

                "version 1.0, developed in August 2025",

                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
