import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:relative_time/relative_time.dart';
import 'package:toolfoam/pages/home_page.dart';

void main() async {
  runApp(const Toolfoam());
}

class Toolfoam extends StatelessWidget {
  final visualizeLayout = false;

  const Toolfoam({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (visualizeLayout) {
      debugPaintSizeEnabled = true;
    }

    return MaterialApp(
      title: 'Toolfoam',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        RelativeTimeLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
