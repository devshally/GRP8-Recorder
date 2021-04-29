import 'package:flutter/material.dart';
import 'package:grp_eight_recorder/ui/index.dart';
import 'package:grp_eight_recorder/ui/splash_screen.dart';

void main() {
  runApp(
    MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: Splash.id,
        routes: {
          Splash.id: (context) => Splash(),
          Index.id: (context) => Index(),
        }),
  );
}
