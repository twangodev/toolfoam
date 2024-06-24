import 'package:flutter/material.dart';

import '../widgets/breadcrumb.dart';

class ToolEditorPage extends StatefulWidget {

  final List<BreadcrumbItem> breadcrumbItems;

  const ToolEditorPage({super.key, required this.breadcrumbItems});

  @override
  State<ToolEditorPage> createState() => _ToolEditorPageState();

}

class _ToolEditorPageState extends State<ToolEditorPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tool Editor'),
      ),
      body: const Center(
        child: Text('Tool Editor Page'),
      ),
    );
  }

}
