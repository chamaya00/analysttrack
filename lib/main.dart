import 'package:flutter/material.dart';
import 'screens/nfl_week_events_screen.dart';

void main() {
  runApp(const AnalystTrackApp());
}

class AnalystTrackApp extends StatelessWidget {
  const AnalystTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnalystTrack - NFL Events',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const NFLWeekEventsScreen(),
    );
  }
}
