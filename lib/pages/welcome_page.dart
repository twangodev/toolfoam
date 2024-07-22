import 'package:flutter/cupertino.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Welcome to Toolfoam!',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
