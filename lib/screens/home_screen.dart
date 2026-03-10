import 'package:flutter/material.dart';
import 'package:qui_dit_mieux/screens/players_screen.dart';
import '../theme/gradient_background.dart';
import '../utils/responsive.dart';
import '../widgets/quick_dialog.dart';
import 'game_screen.dart';
import 'manage_challenges_screen.dart';
import '../widgets/rules_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rules_intro_dialog.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: R.paddingH(context, 0.05),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: R.h(context, 0.05)),

                          Flexible(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: R.h(context, 0.35),
                                maxWidth: R.w(context, 0.8),
                              ),
                              child: Image.asset(
                                "assets/logo-removebg.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          SizedBox(height: R.h(context, 0.03)),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                final prefs = await SharedPreferences.getInstance();
                                final skipIntro = prefs.getBool("skipRulesIntro") ?? false;

                                if (!skipIntro) {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RulesIntroDialog(),
                                    ),
                                  );
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PlayerScreen(),
                                  ),
                                );
                              },

                              child: Padding(
                                padding: R.paddingV(context, 0.015),
                                child: Text(
                                  "LANCER UNE PARTIE",
                                  style: TextStyle(
                                    fontSize: R.sp(context, 0.045),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: R.h(context, 0.02)),

                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton(
                                  onPressed: () async {
                                    final prefs = await SharedPreferences.getInstance();
                                    final skip = prefs.getBool("skipRulesIntro") ?? false;

                                    if (skip) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const GameScreen()),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const RulesIntroDialog()),
                                      );
                                    }
                                  },
                                  child: Padding(
                                    padding: R.paddingV(context, 0.015),
                                    child: Text(
                                          "DEFI RAPIDE",
                                          style: TextStyle(
                                            fontSize: R.sp(context, 0.04),
                                          ),
                                        ),
                                    )
                                  ),
                                  IconButton(onPressed: () => showQuickDialog(context), icon: Icon(Icons.help_outline))
                                ],
                            ),
                          ),

                          SizedBox(height: R.h(context, 0.02)),

                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: R.w(context, 0.03),
                            runSpacing: R.h(context, 0.015),
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ManageChallengesScreen(),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: R.paddingV(context, 0.01),
                                  child: Text(
                                    "Gérer les défis",
                                    style: TextStyle(
                                      fontSize: R.sp(context, 0.035),
                                    ),
                                  ),
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () => showRulesDialog(context),
                                child: Padding(
                                  padding: R.paddingV(context, 0.01),
                                  child: Text(
                                    "Voir les règles",
                                    style: TextStyle(
                                      fontSize: R.sp(context, 0.035),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: R.h(context, 0.05)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}