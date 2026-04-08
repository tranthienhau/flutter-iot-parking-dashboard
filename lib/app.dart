import 'package:flutter/material.dart';

import 'router.dart';

class ParkingApp extends StatelessWidget {
  const ParkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Smart Parking IoT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1220),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5A9EFF),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B1220),
          elevation: 0,
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
