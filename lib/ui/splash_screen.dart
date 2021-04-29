import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:grp_eight_recorder/utils/size_config.dart';
import 'index.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  static const String id = 'splash_screen_page';

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    navigate();
  }

  void navigate() {
    Timer(
      Duration(seconds: 7),
      () {
        Navigator.of(context).pushReplacementNamed(Index.id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.indigoAccent,
      body: Center(
        child: TextLiquidFill(
            text: 'Group 8\nRecorder',
            waveColor: Colors.white,
            boxBackgroundColor: Colors.indigoAccent,
            textStyle: TextStyle(
                fontSize: 60.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lora')),
      ),
    );
  }
}
