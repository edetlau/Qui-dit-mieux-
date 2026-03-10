import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/responsive.dart';
import 'game_screen.dart';

class RulesIntroDialog extends StatefulWidget {
  const RulesIntroDialog({super.key});

  @override
  State<RulesIntroDialog> createState() => _RulesIntroDialogState();
}

class _RulesIntroDialogState extends State<RulesIntroDialog> {
  final PageController controller = PageController();
  int index = 0;

  final List<String> images = [
    "assets/rules/rule1.png",
    "assets/rules/rule2.png",
    "assets/rules/rule3.png",
    "assets/rules/rule4.png",
    "assets/rules/rule5.png",
  ];

  Future<void> disableForever() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("skipRulesIntro", true);
    goToGame();
  }

  void goToGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  void nextStep() {
    if (index < images.length - 1) {
      controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      goToGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: R.h(context, 0.02)),

            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: images.length,
                onPageChanged: (i) => setState(() => index = i),
                itemBuilder: (_, i) {
                  return Padding(
                    padding: R.paddingH(context, 0.05),
                    child: Image.asset(
                      images[i],
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: index == i ? 14 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index == i ? Colors.white : Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),

            SizedBox(height: R.h(context, 0.02)),

            Padding(
              padding: R.paddingH(context, 0.06),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: nextStep,
                      child: Text(
                        index == images.length - 1 ? "Commencer" : "Continuer",
                      ),
                    ),
                  ),

                  SizedBox(height: R.h(context, 0.015)),

                  OutlinedButton(
                    onPressed: goToGame,
                    child: Text(
                      "Passer le tutoriel",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: R.sp(context, 0.04),
                      ),
                    ),
                  ),

                  SizedBox(height: R.h(context, 0.01)),

                  TextButton(
                    onPressed: disableForever,
                    child: Text(
                      "Ne plus me le montrer",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: R.sp(context, 0.038),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: R.h(context, 0.02)),
          ],
        ),
      ),
    );
  }
}
