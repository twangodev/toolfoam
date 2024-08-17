import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';
import 'package:relative_time/relative_time.dart';
import 'package:toolfoam/pages/home_page.dart';

void main() async {
  Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
  Logger.root.onRecord.listen((record) {
    log('[${record.level.name}] ${record.message}',
        level: record.level.value,
        name: record.loggerName,
        time: record.time,
        sequenceNumber: record.sequenceNumber,
        zone: record.zone,
        error: record.error,
        stackTrace: record.stackTrace);
  });

  Logger('toolfoam.main').info('Starting Toolfoam');

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
