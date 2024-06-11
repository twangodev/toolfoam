import 'package:flutter/material.dart';

class LayoutsPage extends StatefulWidget {
  const LayoutsPage({super.key});

  @override
  State<LayoutsPage> createState() => _LayoutsPageState();
}

class _LayoutsPageState extends State<LayoutsPage> {

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Layouts',
        style: TextStyle(fontSize: 24),
      ),
    );
  }

}