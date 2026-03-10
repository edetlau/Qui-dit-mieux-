  import 'package:flutter/material.dart';
  import '../models/player.dart';
  import '../theme/gradient_background.dart';
  import '../utils/responsive.dart';

  class ChallengeResultScreen extends StatefulWidget {
    final List<Player> players;
    final VoidCallback onNext;
    final Player player;
    final bool isDoublePoints;

    const ChallengeResultScreen({
      super.key,
      required this.players,
      required this.player,
      required this.onNext,
      required this.isDoublePoints,
    });

    @override
    State<ChallengeResultScreen> createState() => _ChallengeResultScreenState();
  }

  class _ChallengeResultScreenState extends State<ChallengeResultScreen>
      with SingleTickerProviderStateMixin {
    bool? success;
    late AnimationController controller;
    late Animation<double> scaleAnimation;

    final List<String> successMessages = [
      "Impressionnant ! 🔥",
      "Incroyable performance ! 💪",
      "On applaudit ! 👏",
      "Maîtrise totale 😎",
      "Quel talent ! ✨",
      "C’était propre ça ! 🎯",
    ];

    final List<String> failMessages = [
      "La prochaine sera la bonne 😉",
      "Ouch… ça pique 😅",
      "Pas loin ! 💥",
      "Ça arrive aux meilleurs 😌",
      "On y a cru pourtant ! 😏",
      "Revanche au prochain défi 🔄",
    ];

    String? randomMessage;

    @override
    void initState() {
      super.initState();
      controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );

      scaleAnimation =
          CurvedAnimation(parent: controller, curve: Curves.easeOutBack);
    }

    @override
    void dispose() {
      controller.dispose();
      super.dispose();
    }

    void validate() {
      if (success == null) return;

      if (success!) {
        widget.player.score += widget.isDoublePoints ? 6 : 3;
      } else {
        for (final p in widget.players) {
          if (p != widget.player) {
            p.score += widget.isDoublePoints ? 2 : 1;
          }
        }
      }

      Navigator.pop(context);
      widget.onNext();
    }

  void selectResult(bool value) {
    final messages = value ? successMessages : failMessages;
    messages.shuffle();

    setState(() {
      success = value;
      randomMessage = messages.first;
    });

    controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final Color? overlayColor = success == null
        ? null
        : success!
        ? Colors.green.withValues(alpha: 0.15)
        : Colors.red.withValues(alpha: 0.15);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Résultat du défi",
          style: TextStyle(fontSize: R.sp(context, 0.045)),
        ),
      ),
      body: GradientBackground(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: overlayColor,
          child: SafeArea(
            child: Padding(
              padding: R.padding(context, 0.06),
              child: Column(
                children: [

                  CircleAvatar(
                    radius: R.w(context, 0.12),
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    child: Text(
                      widget.player.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: R.sp(context, 0.08),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: R.h(context, 0.02)),

                  Text(
                    widget.player.name,
                    style: TextStyle(
                      fontSize: R.sp(context, 0.07),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: R.h(context, 0.01)),

                  Text(
                    "a relevé le défi ?",
                    style: TextStyle(
                      fontSize: R.sp(context, 0.045),
                      color: Colors.white70,
                    ),
                  ),

                  SizedBox(height: R.h(context, 0.05)),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => selectResult(true),
                          icon: Icon(Icons.check,
                              size: R.sp(context, 0.05)),
                          label: Text(
                            "Réussi",
                            style:
                            TextStyle(fontSize: R.sp(context, 0.045)),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: success == true
                                ? Colors.greenAccent
                                : Colors.green,
                            padding: R.paddingV(context, 0.025),
                          ),
                        ),
                      ),
                      SizedBox(width: R.w(context, 0.04)),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => selectResult(false),
                          icon: Icon(Icons.close,
                              size: R.sp(context, 0.05)),
                          label: Text(
                            "Échoué",
                            style:
                            TextStyle(fontSize: R.sp(context, 0.045)),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: success == false
                                ? Colors.redAccent
                                : Colors.red,
                            padding: R.paddingV(context, 0.025),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: R.h(context, 0.05)),

                  if (success != null)
                    ScaleTransition(
                      scale: scaleAnimation,
                      child: Column(
                        children: [
                          Text(
                            success!
                                ? "🎉 +3 POINTS"
                                : "😈 +1 point aux autres",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: R.sp(context, 0.07),
                              fontWeight: FontWeight.bold,
                              color: success!
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                            ),
                          ),
                          SizedBox(height: R.h(context, 0.015)),
                          Text(
                            randomMessage ?? "",
                            style: TextStyle(
                              fontSize: R.sp(context, 0.045),
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: success != null ? validate : null,
                      style: ElevatedButton.styleFrom(
                        padding: R.paddingV(context, 0.025),
                      ),
                      child: Text(
                        success == null
                            ? "Choisir un résultat"
                            : "Continuer la partie",
                        style: TextStyle(
                          fontSize: R.sp(context, 0.05),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}