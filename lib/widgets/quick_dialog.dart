import 'package:flutter/material.dart';

void showQuickDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Défi Rapide"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "ICI TOUT VA VITE !\n\n"
                "👉 10 défis : on ne compte pas les points, on n'inscrit pas le nom des joueurs et pas besoin de valider chaque défi\n\n"
                "✅ Seul objectif : S'AMUSER !!\n",
            style: TextStyle(fontSize: 16),
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
