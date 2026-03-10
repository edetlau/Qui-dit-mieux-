class Player {
  final String id;
  final String name;
  int score;

  Player({
    required this.id,
    required this.name,
    this.score = 0,
  });
}
