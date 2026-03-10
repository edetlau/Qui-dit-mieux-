enum ThemeType { force, reflexes, culture, chance }
enum ChallengeType { timer, chrono, hiddenInfo, none }

class Challenge {
  final String id;
  final ThemeType theme;
  final String statement;
  final ChallengeType type;
  final int? time;
  final String? needObject;
  final String? hiddenInfo;
  bool enabled;

  Challenge({
    required this.id,
    required this.theme,
    required this.statement,
    required this.type,
    this.time,
    this.hiddenInfo,
    this.needObject,
    this.enabled = true,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      theme: ThemeType.values.byName(json['theme']),
      statement: json['statement'],
      type: ChallengeType.values.byName(json['type']),
      time: json['time'],
      hiddenInfo: json['hiddenInfo'],
      needObject: json['needObject'],
      enabled: json['enabled'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'theme': theme.name,
    'statement': statement,
    'type': type.name,
    'time': time,
    'hiddenInfo': hiddenInfo,
    'needObject': needObject,
    'enabled': enabled,
  };
}