import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/challenge.dart';
import '../models/player.dart';
import '../theme/gradient_background.dart';
import '../utils/responsive.dart';
import '../widgets/objects_widget.dart';
import 'challenge_result_screen.dart';
import '../widgets/rules_dialog.dart';
import '../widgets/timer_widget.dart';
import '../widgets/hidden_info_widget.dart';
import '../widgets/chrono_widget.dart';
import 'end_game_screen.dart';

class GameScreen extends StatefulWidget {
  final List<Player>? players;

  const GameScreen({
    super.key,
    this.players,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  static const String enabledKey = "enabledChallenges";
  static const String customKey = "customChallenges";

  List<Challenge> gameChallenges = [];
  bool isLoading = true;
  bool interactionLocked = false;
  int index = 0;
  late final bool withScores;
  List<Player>? players;
  Player? currentPlayer;

  bool timerFinished = false;
  bool chronoStarted = false;
  bool hiddenInfoRevealed = false;

  late AnimationController _clickController;
  late Animation<double> _clickAnimation;

  int? doublePointsIndex;
  bool doublePointsEnabled = false;

  late AnimationController shakeController;
  late Animation<double> shakeAnimation;

  @override
  void initState() {
    super.initState();
    players = widget.players;
    withScores = players != null && players!.isNotEmpty;
    loadChallenges();

    _clickController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _clickAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _clickController, curve: Curves.easeInOut),
    );

    _clickController.repeat(reverse: true);

    shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    shakeAnimation = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(
        parent: shakeController,
        curve: Curves.elasticIn,
      ),
    );

    shakeController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _clickController.stop();
    _clickController.dispose();
    shakeController.dispose();
    super.dispose();
  }

  Future<void> loadChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final enabledIds = prefs.getStringList(enabledKey) ?? [];

    final data = await rootBundle.loadString('lib/data/challenges.json');
    final List decoded = json.decode(data);

    final jsonChallenges = decoded.map((e) {
      final c = Challenge.fromJson(e);
      c.enabled = enabledIds.isEmpty || enabledIds.contains(c.id);
      return c;
    }).toList();

    final customString = prefs.getString(customKey);
    List<Challenge> customChallenges = [];

    if (customString != null) {
      final decodedCustom = jsonDecode(customString) as List;
      customChallenges =
          decodedCustom.map((e) => Challenge.fromJson(e)).toList();
    }

    final allChallenges = [
      ...jsonChallenges,
      ...customChallenges,
    ].where((c) => c.enabled).toList();

    // --- Pop-up objets ---
    if (withScores) {
      if (players != null) {
        final selectedObjects = await showDialog<List<String>>(
          context: context,
          barrierDismissible: false,
          builder: (_) => ObjectsWidget(challenges: allChallenges),
        );

        final filteredChallenges = selectedObjects != null
            ? allChallenges
            .where((c) =>
        c.needObject == null || selectedObjects.contains(c.needObject))
            .toList()
            : allChallenges;

        filteredChallenges.shuffle();

        setState(() {
          gameChallenges = filteredChallenges.take(10).toList();
          isLoading = false;
        });
        if (gameChallenges.length >= 5) {
          final random = Random();

          // 50% de chance d’avoir un défi x2
          doublePointsEnabled = random.nextBool();

          if (doublePointsEnabled) {
            final lastFiveStart = gameChallenges.length - 5;
            doublePointsIndex =
                lastFiveStart + random.nextInt(5); // un des 5 derniers
          }
        }
      }
    } else {
      allChallenges.shuffle();

      setState(() {
        gameChallenges = allChallenges.take(10).toList();
        isLoading = false;
      });
    }




  }

  void nextChallenge({bool skipResult = false}) {
    final isLastChallenge = index >= gameChallenges.length - 1;
    final isDoublePoints = doublePointsEnabled && index == doublePointsIndex;

    if (withScores) {
      if (!skipResult) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Dialog(
            insetPadding: R.padding(context, 0.04),
            backgroundColor: Colors.transparent,
            child: ChallengeResultScreen(
              players: players!,
              player: currentPlayer!,
              isDoublePoints: isDoublePoints,
              onNext: () {
                if (!isLastChallenge) {
                  setState(() {
                    timerFinished = false;
                    chronoStarted = false;
                    hiddenInfoRevealed = false;
                    index++;
                    currentPlayer = null;
                  });
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EndGameScreen(players: players!),
                    ),
                  );
                }
              },
            ),
          ),
        );
        return;
      }

      if (!isLastChallenge) {
        setState(() {
          index++;
          currentPlayer = null;
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EndGameScreen(players: players!),
          ),
        );
      }

      return;
    } else {
      if (!isLastChallenge) {
        timerFinished = false;
        chronoStarted = false;
        hiddenInfoRevealed = false;
        interactionLocked = false;

        setState(() => index++);
      } else {
        Navigator.pop(context);
      }
    }
  }



  void showLockInfo() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "L'écran est temporairement désactivé pour éviter les clics accidentels.\n"
              "Arrête le timer ou le chrono pour continuer.",
          style: TextStyle(fontSize: R.sp(context, 0.04)),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: R.padding(context, 0.04),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (gameChallenges.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            "Aucun défi disponible",
            style: TextStyle(fontSize: R.sp(context, 0.05)),
          ),
        ),
      );
    }

    final challenge = gameChallenges[index];
    final isDoublePoints = doublePointsEnabled && index == doublePointsIndex;

    bool canClick = false;

    if (!withScores) {
      if (!interactionLocked) {
        switch (challenge.type) {
          case ChallengeType.none:
            canClick = true;
            break;
          case ChallengeType.timer:
            canClick = timerFinished;
            break;
          case ChallengeType.chrono:
            canClick = chronoStarted;
            break;
          case ChallengeType.hiddenInfo:
            canClick = hiddenInfoRevealed;
            break;
        }
      }
    } else if (currentPlayer != null) {
      if (!interactionLocked) {
        switch (challenge.type) {
          case ChallengeType.none:
            canClick = true;
            break;
          case ChallengeType.timer:
            canClick = timerFinished;
            break;
          case ChallengeType.chrono:
            canClick = chronoStarted;
            break;
          case ChallengeType.hiddenInfo:
            canClick = hiddenInfoRevealed;
            break;
        }
      }
    }

    final progress = (index + 1) / gameChallenges.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          TextButton(
            child: Text("Voir les règles"),
            onPressed: () => showRulesDialog(context),
          ),
        ],
      ),
      body: GradientBackground(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: isDoublePoints ? Colors.yellow.withValues(alpha: 0.55) : null,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (interactionLocked) {
                showLockInfo();
              } else {
                if (withScores && currentPlayer == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Sélectionne un joueur avant de continuer ou passe ce défi.",
                        style: TextStyle(fontSize: R.sp(context, 0.04)),
                      ),
                    ),
                  );
                  return;
                }
                nextChallenge();
              }
            },
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: R.w(context, 0.04),
                      vertical: R.h(context, 0.015),
                    ),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: R.h(context, 0.008),
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: R.padding(context, 0.03),
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() => interactionLocked = false);
                          nextChallenge(skipResult: true);
                        },
                        icon: Icon(Icons.skip_next, size: R.sp(context, 0.05)),
                        label: Text(
                          "Passer ce défi",
                          style: TextStyle(fontSize: R.sp(context, 0.04)),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red.withValues(alpha: 0.2),
                          foregroundColor: Colors.redAccent,
                          padding: EdgeInsets.symmetric(
                            horizontal: R.w(context, 0.03),
                            vertical: R.h(context, 0.008),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(R.w(context, 0.03)),
                          ),
                        ),
                      ),
                    ),
                  ),
  
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Padding(
                                padding: R.padding(context, 0.05),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  transitionBuilder: (child, animation) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1, -1),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: FadeTransition(opacity: animation, child: child),
                                    );
                                  },
                                  child: Column(
                                    key: ValueKey(challenge.id),
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isDoublePoints)
                                        Padding(
                                          padding: EdgeInsets.only(bottom: R.h(context, 0.02)),
                                          child: AnimatedBuilder(
                                            animation: shakeController,
                                            builder: (context, child) {
                                              return Transform.translate(
                                                offset: Offset(shakeAnimation.value, 0),
                                                child: child,
                                              );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: R.w(context, 0.04),
                                                vertical: R.h(context, 0.01),
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.amber,
                                                borderRadius: BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.amber.withValues(alpha: 0.6),
                                                    blurRadius: 12,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                "🔥 POINTS x2 🔥",
                                                style: TextStyle(
                                                  fontSize: R.sp(context, 0.045),
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      Image.asset(
                                        switch (challenge.theme) {
                                          ThemeType.force => "assets/icons/force.png",
                                          ThemeType.reflexes => "assets/icons/reflexes.png",
                                          ThemeType.culture => "assets/icons/culture.png",
                                          ThemeType.chance => "assets/icons/chance.png",
                                        },
                                        height: R.sp(context, 0.2),
                                        fit: BoxFit.contain,
                                      ),
                                      SizedBox(height: R.h(context, 0.02)),
                                      Padding(
                                        padding: R.paddingH(context, 0.03),
                                        child: Text(
                                          challenge.statement,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: R.sp(context, 0.065),
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: R.h(context, 0.04)),
  
                                      if (challenge.type == ChallengeType.timer)
                                        TimerWidget(
                                          key: ValueKey(challenge.id),
                                          seconds: challenge.time!,
                                          onStart: () => setState(() => interactionLocked = true),
                                          onEnd: () => setState(() {
                                            interactionLocked = false;
                                            timerFinished = true;
                                          }),
                                        )
                                      else if (challenge.type == ChallengeType.hiddenInfo)
                                        HiddenInfoWidget(
                                          key: ValueKey(challenge.id),
                                          info: challenge.hiddenInfo ?? "",
                                          onReveal: () => setState(() => hiddenInfoRevealed = true),
                                        )
                                      else if (challenge.type == ChallengeType.chrono)
                                          ChronoWidget(
                                            key: ValueKey(challenge.id),
                                            onStart: () => setState(() {
                                              interactionLocked = true;
                                              chronoStarted = true;
                                            }),
                                            onEnd: () => setState(() => interactionLocked = false),
                                          ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: R.w(context, 0.05),
                        bottom: R.h(context, 0.02),
                      ),
                      child: SizedBox(
                        height: R.sp(context, 0.12),
                        width: R.sp(context, 0.12),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: canClick ? 1 : 0,
                          child: FadeTransition(
                            opacity: _clickAnimation,
                            child: Image.asset(
                              "assets/icons/click.png",
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (withScores)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: R.padding(context, 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Qui va réaliser ce défi ?",
                              style: TextStyle(
                                fontSize: R.sp(context, 0.045),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: R.h(context, 0.02)),
                            Wrap(
                              spacing: R.w(context, 0.03),
                              runSpacing: R.h(context, 0.015),
                              children: players!.map((player) {
                                final selected = player == currentPlayer;
                                return ChoiceChip(
                                  label: Text(
                                    player.name,
                                    style: TextStyle(fontSize: R.sp(context, 0.04)),
                                  ),
                                  selected: selected,
                                  onSelected: (_) {
                                    setState(() => currentPlayer = player);
                                  },
                                );
                              }).toList(),
                            ),
                            SizedBox(height: R.h(context, 0.04)),
                          ],
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