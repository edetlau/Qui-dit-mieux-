import 'package:flutter/material.dart';
import 'players_screen.dart';
import '../models/player.dart';
import '../theme/gradient_background.dart';
import '../utils/responsive.dart';
import 'game_screen.dart';

class EndGameScreen extends StatefulWidget {
  final List<Player> players;

  const EndGameScreen({
    super.key,
    required this.players,
  });

  @override
  State<EndGameScreen> createState() => _EndGameScreenState();
}

class _EndGameScreenState extends State<EndGameScreen>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> fadeAnimation;
  late Animation<double> slideAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    fadeAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    );

    slideAnimation = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
    );

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortedPlayers = [...widget.players]
      ..sort((a, b) => b.score.compareTo(a.score));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        child: FadeTransition(
          opacity: fadeAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: Colors.yellow.withValues(alpha: 0.15),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  AnimatedBuilder(
                    animation: slideAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, slideAnimation.value),
                        child: child,
                      );
                    },
                    child: const Text(
                      "🏆 Fin de la partie",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  _Podium(players: sortedPlayers),

                  const SizedBox(height: 30),

                  Expanded(
                    child: ListView.builder(
                      itemCount: sortedPlayers.length,
                      itemBuilder: (context, index) {
                        final p = sortedPlayers[index];

                        return TweenAnimationBuilder(
                          duration: Duration(milliseconds: 500 + (index * 100)),
                          tween: Tween<double>(begin: 30, end: 0),
                          builder: (context, double value, child) {
                            return Transform.translate(
                              offset: Offset(0, value),
                              child: Opacity(
                                opacity: 1 - (value / 30),
                                child: child,
                              ),
                            );
                          },
                          child: Card(
                            child: ListTile(
                              leading: Text(
                                "#${index + 1}",
                                style: const TextStyle(fontSize: 20),
                              ),
                              title: Text(
                                p.name,
                                style: const TextStyle(fontSize: 20),
                              ),
                              trailing: Text(
                                "${p.score} pts",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  FadeTransition(
                    opacity: fadeAnimation,
                    child: Column(
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/home',
                                  (_) => false,
                            );
                          },
                          child: const Text(
                            "Retour à l'accueil",
                            style: TextStyle(color: Colors.white60),
                          ),
                        ),

                        OutlinedButton(
                          onPressed: () {
                            for (var p in widget.players) {
                              p.score = 0;
                            }

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlayerScreen(initialPlayers: widget.players),
                              ),
                                  (_) => false,
                            );
                          },
                          child: const Text(
                            "Ajouter ou supprimer des joueurs",
                            style: TextStyle(color: Colors.white60),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Padding(
                          padding: R.padding(context, 0.05),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                for (var p in widget.players) {
                                  p.score = 0;
                                }

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        GameScreen(players: widget.players),
                                  ),
                                      (_) => false,
                                );
                              },
                              child: const Text("Relancer une partie"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          )
        ),
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  final List<Player> players;

  const _Podium({required this.players});

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) return const SizedBox();

    final first = players.isNotEmpty ? players[0] : null;
    final second = players.length > 1 ? players[1] : null;
    final third = players.length > 2 ? players[2] : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (third != null)
          _AnimatedPodiumTile(
            player: third,
            height: 80,
            color: Colors.brown,
            rank: "🥉",
            delay: 300,
          ),

        if (first != null)
          _AnimatedPodiumTile(
            player: first,
            height: 140,
            color: Colors.amber,
            rank: "🥇",
            delay: 0,
            isWinner: true,
          ),

        if (second != null)
          _AnimatedPodiumTile(
            player: second,
            height: 100,
            color: Colors.grey,
            rank: "🥈",
            delay: 150,
          ),
      ],
    );
  }
}

class _AnimatedPodiumTile extends StatelessWidget {
  final Player player;
  final double height;
  final Color color;
  final String rank;
  final int delay;
  final bool isWinner;

  const _AnimatedPodiumTile({
    required this.player,
    required this.height,
    required this.color,
    required this.rank,
    required this.delay,
    this.isWinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 1600 + delay),
      curve: Curves.easeOutBack,
      tween: Tween<double>(begin: 0, end: height),
      builder: (context, double value, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
            Text(rank, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            Text(
              player.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 80,
              height: value,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: (value > height * 0.6)
                  ? Text(
                    "${player.score}",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ) : null,
              ),
            ],
          ),
        );
      },
    );
  }
}