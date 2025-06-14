import 'package:flutter/material.dart';

class ThirdScreen extends StatelessWidget {
  const ThirdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Third Screen')
        ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigator.pop(context);
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
          child: const Text('Go to Home screen'),
        ),
      ),
    );
  }
}