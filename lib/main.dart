import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qui_dit_mieux/screens/game_screen.dart';
import 'package:qui_dit_mieux/screens/home_screen.dart';
import 'package:qui_dit_mieux/screens/players_screen.dart';
import 'package:qui_dit_mieux/screens/splash_screen.dart';
import 'package:qui_dit_mieux/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const QuiDitMieuxApp());
}

class QuiDitMieuxApp extends StatelessWidget {
  const QuiDitMieuxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qui dit mieux ?',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/game': (context) => const GameScreen(),
        '/players' : (context) => const PlayerScreen()
      },
    );
  }
}
