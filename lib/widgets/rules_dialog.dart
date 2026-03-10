import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showRulesDialog(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final skipIntro = prefs.getBool("skipRulesIntro") ?? false;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Règles du jeu"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Les joueurs enchérissent sur le défi.\n\n"
                "👉 Celui qui fait la plus grosse enchère doit réaliser le défi.\n\n"
                "✅ S’il réussit : il gagne 3 points.\n"
                "❌ S’il échoue : tous les autres joueurs gagnent 1 point.",
            style: TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 16),

          if (skipIntro)
            TextButton(
              onPressed: () async {
                await prefs.setBool("skipRulesIntro", false);

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Les règles s'afficheront de nouveau au début des parties.",
                      textAlign: TextAlign.center,
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text("Réactiver l'affichage du tutoriel au démarrage"),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Compris",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],
    ),
  );
}
