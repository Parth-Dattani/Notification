import 'package:flutter/material.dart';

class MySecondScreen extends StatelessWidget {
  final String? payload;

  const MySecondScreen({Key? key, required this.payload}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Second Notification Demo"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 100),
                child: Image.asset(
                  "assets/Images/profile.jpg",
                ),
              ),
              Text(payload ?? ''),
              const Text('payload'),
            ],
          ),
        ),
      ),
    );
  }
}
