import 'package:flutter/material.dart';
import '../models/player.dart';
import '../theme/gradient_background.dart';
import '../utils/responsive.dart';
import 'game_screen.dart';

class PlayerScreen extends StatefulWidget {
  final List<Player>? initialPlayers;

  const PlayerScreen({super.key, this.initialPlayers});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final TextEditingController controller = TextEditingController();
  late List<Player> players;

  @override
  void initState() {
    super.initState();
    players = widget.initialPlayers != null
        ? List.from(widget.initialPlayers!)
        : [];
  }

  void addPlayer() {
    final name = controller.text.trim();
    if (name.isEmpty) return;

    setState(() {
      players.add(
        Player(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
        ),
      );
      controller.clear();
    });
  }

  void removePlayer(Player player) {
    setState(() {
      players.remove(player);
    });
  }

  void startGame() {
    if (players.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Ajoute au moins 2 joueurs pour lancer une partie.",
            style: TextStyle(fontSize: R.sp(context, 0.04)),
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(players: players),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
                  (_) => false,
            );
          },
        ),
        title: Text(
          "Participants",
          style: TextStyle(fontSize: R.sp(context, 0.05)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: R.padding(context, 0.04),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: TextStyle(fontSize: R.sp(context, 0.04)),
                        decoration: InputDecoration(
                          hintText: "Nom du joueur",
                          hintStyle: TextStyle(fontSize: R.sp(context, 0.04)),
                        ),
                        onSubmitted: (_) => addPlayer(),
                      ),
                    ),
                    SizedBox(width: R.w(context, 0.03)),
                    ElevatedButton(
                      onPressed: addPlayer,
                      child: Padding(
                        padding: R.paddingV(context, 0.01),
                        child: Text(
                          "Ajouter",
                          style: TextStyle(fontSize: R.sp(context, 0.04)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: R.h(context, 0.01)),

              Expanded(
                child: players.isEmpty
                    ? Center(
                  child: Padding(
                    padding: R.paddingH(context, 0.05),
                    child: Text(
                      "Ajoute les participants pour commencer",
                      style: TextStyle(fontSize: R.sp(context, 0.045)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                    : ListView.builder(
                  padding: R.paddingH(context, 0.04),
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    return Card(
                      margin: EdgeInsets.symmetric(
                        vertical: R.h(context, 0.01),
                      ),
                      child: ListTile(
                        contentPadding: R.padding(context, 0.04),
                        title: Text(
                          player.name,
                          style: TextStyle(fontSize: R.sp(context, 0.045)),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            size: R.sp(context, 0.06),
                          ),
                          onPressed: () => removePlayer(player),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: R.padding(context, 0.05),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: startGame,
                    child: Padding(
                      padding: R.paddingV(context, 0.015),
                      child: Text(
                        "LANCER LA PARTIE",
                        style: TextStyle(fontSize: R.sp(context, 0.045)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}