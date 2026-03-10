import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/challenge.dart';
import '../theme/gradient_background.dart';
import '../utils/responsive.dart';

class ManageChallengesScreen extends StatefulWidget {
  const ManageChallengesScreen({super.key});

  @override
  State<ManageChallengesScreen> createState() => _ManageChallengesScreenState();
}

enum SortBy { theme, type, enabled }

class _ManageChallengesScreenState extends State<ManageChallengesScreen> {
  static const String enabledKey = "enabledChallenges";
  static const String customKey = "customChallenges";

  List<Challenge> challenges = [];
  SortBy? sortBy = SortBy.theme;
  Set<ThemeType> themeFilter = ThemeType.values.toSet();
  Set<ChallengeType> typeFilter = ChallengeType.values.toSet();
  bool showCustomOnly = false;
  bool showNeedObjectOnly = false;

  final ScrollController _scrollController = ScrollController();
  double _bottomGradientOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    load();

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      final fadeZone = R.h(context, 0.12);
      final remaining = (maxScroll - currentScroll).clamp(0.0, fadeZone);

      final newOpacity = (remaining / fadeZone).clamp(0.0, 1.0);

      if ((_bottomGradientOpacity - newOpacity).abs() > 0.01) {
        setState(() => _bottomGradientOpacity = newOpacity);
      }
    });
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final enabledIds = prefs.getStringList(enabledKey) ?? [];

    final data = await rootBundle.loadString('lib/data/challenges.json');
    final decoded = json.decode(data) as List;

    final jsonChallenges = decoded.map((e) {
      final c = Challenge.fromJson(e);
      c.enabled = enabledIds.isEmpty || enabledIds.contains(c.id);
      return c;
    }).toList();

    final customString = prefs.getString(customKey);
    List<Challenge> customChallenges = [];
    if (customString != null) {
      final decodedCustom = jsonDecode(customString) as List;
      customChallenges = decodedCustom.map((e) => Challenge.fromJson(e)).toList();
    }

    setState(() {
      challenges = [...jsonChallenges, ...customChallenges];
    });
  }

  Future<void> saveEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final enabledIds = challenges.where((c) => c.enabled).map((c) => c.id).toList();
    await prefs.setStringList(enabledKey, enabledIds);
  }

  Future<void> saveCustomChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final custom = challenges
        .where((c) => c.id.startsWith("custom_"))
        .map((c) => c.toJson())
        .toList();
    await prefs.setString(customKey, jsonEncode(custom));
  }

  List<Challenge> get filteredChallenges {
    var list = challenges.where((c) {
      if (!themeFilter.contains(c.theme)) return false;
      if (!typeFilter.contains(c.type)) return false;
      if (showCustomOnly && !c.id.startsWith("custom_")) return false;
      if (showNeedObjectOnly && c.needObject == null) return false;
      return true;
    }).toList();

    if (sortBy != null) {
      switch (sortBy!) {
        case SortBy.theme:
          list.sort((a, b) => a.theme.index.compareTo(b.theme.index));
          break;
        case SortBy.type:
          list.sort((a, b) => a.type.index.compareTo(b.type.index));
          break;
        case SortBy.enabled:
          list.sort((a, b) => (b.enabled ? 1 : 0).compareTo(a.enabled ? 1 : 0));
          break;
      }
    }
    return list;
  }

  Map<String, List<Challenge>> get groupedChallenges {
    final Map<String, List<Challenge>> map = {};
    for (var c in filteredChallenges) {
      String key;
      switch (sortBy) {
        case SortBy.theme:
          key = c.theme.name.toUpperCase();
          break;
        case SortBy.type:
          key = c.type.name.toUpperCase();
          break;
        case SortBy.enabled:
          key = c.enabled ? "ACTIVÉS" : "DÉSACTIVÉS";
          break;
        default:
          key = "TOUS";
      }
      map.putIfAbsent(key, () => []).add(c);
    }
    return map;
  }

  void showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocalState) {
          return Padding(
            padding: R.padding(context, 0.04),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Thèmes", style: TextStyle(fontSize: R.sp(context, 0.045))),
                  Wrap(
                    spacing: R.w(context, 0.02),
                    children: ThemeType.values.map((t) {
                      return FilterChip(
                        label: Text(t.name),
                        selected: themeFilter.contains(t),
                        onSelected: (v) => setLocalState(() {
                          if (v) {
                            themeFilter.add(t);
                          } else {
                            themeFilter.remove(t);
                          }
                        }),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: R.h(context, 0.02)),

                  Text("Types", style: TextStyle(fontSize: R.sp(context, 0.045))),
                  Wrap(
                    spacing: R.w(context, 0.02),
                    children: ChallengeType.values.map((t) {
                      return FilterChip(
                        label: Text(t.name),
                        selected: typeFilter.contains(t),
                        onSelected: (v) => setLocalState(() {
                          if (v) {
                            typeFilter.add(t);
                          } else {
                            typeFilter.remove(t);
                          }
                        }),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: R.h(context, 0.02)),

                  SwitchListTile(
                    title: Text("Défis personnalisés", style: TextStyle(fontSize: R.sp(context, 0.04))),
                    value: showCustomOnly,
                    onChanged: (v) => setLocalState(() => showCustomOnly = v),
                  ),
                  SwitchListTile(
                    title: Text("Besoin d'objet", style: TextStyle(fontSize: R.sp(context, 0.04))),
                    value: showNeedObjectOnly,
                    onChanged: (v) => setLocalState(() => showNeedObjectOnly = v),
                  ),

                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: const Text("Appliquer"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = groupedChallenges;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Gérer les défis", style: TextStyle(fontSize: R.sp(context, 0.045))),
        actions: [
          IconButton(
            icon: Icon(Icons.sort, size: R.sp(context, 0.06)),
            onPressed: () {
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(100, 80, 0, 0),
                items: [
                  PopupMenuItem(
                    value: SortBy.theme,
                    child: Text("Trier par thème"),
                  ),
                  PopupMenuItem(
                    value: SortBy.type,
                    child: Text("Trier par type"),
                  ),
                  PopupMenuItem(
                    value: SortBy.enabled,
                    child: Text("Trier par activé"),
                  ),
                ],
              ).then((v) {
                if (v != null) setState(() => sortBy = v);
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_alt, size: R.sp(context, 0.06)),
            onPressed: showFilterSheet,
          ),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: R.h(context, 0.10)),
                child: ListView(
                  controller: _scrollController,
                  padding: R.paddingV(context, 0.02),
                  children: groups.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (sortBy != null)
                          Padding(
                            padding: R.padding(context, 0.02),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Builder(
                                  builder: (_) {
                                    final groupChallenges = entry.value;
                                    final enabledCount =
                                        groupChallenges.where((c) => c.enabled).length;

                                    final allEnabled = enabledCount == groupChallenges.length;
                                    final noneEnabled = enabledCount == 0;

                                    return Checkbox(
                                      activeColor: Colors.lightBlue,
                                      value: allEnabled
                                          ? true
                                          : noneEnabled
                                          ? false
                                          : null,
                                      tristate: true,
                                      onChanged: (value) async {
                                        final newValue = value ?? false;

                                        setState(() {
                                          for (var c in groupChallenges) {
                                            c.enabled = newValue;
                                          }
                                        });

                                        await saveEnabled();
                                      },
                                    );
                                  },
                                ),
                                SizedBox(width: R.w(context, 0.02)),
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: R.sp(context, 0.055),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ...entry.value.map((c) {
                          final isCustom = c.id.startsWith("custom_");
                          return CheckboxListTile(
                            title: Text(
                              c.statement,
                              style: TextStyle(
                                  fontSize: R.sp(context, 0.04),
                                  color: c.enabled ? Colors.white : Colors.white38
                              ),
                            ),
                            subtitle: isCustom
                                ? Text(
                              "Défi personnalisé",
                              style: TextStyle(fontSize: R.sp(context, 0.035)),
                            )
                                : null,
                            activeColor: Colors.lightBlue,
                            value: c.enabled,
                            onChanged: (value) async {
                              setState(() => c.enabled = value!);
                              await saveEnabled();
                            },
                            secondary: isCustom
                                ? IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: R.sp(context, 0.06),
                              ),
                              onPressed: () => confirmDeleteChallenge(c),
                            )
                                : null,
                          );
                        }),
                        SizedBox(height: R.h(context, 0.02)),
                      ],
                    );
                  }).toList(),
                ),
              ),

              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: R.h(context, 0.02),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: R.h(context, 0.10),
                child: Container(
                  height: R.h(context, 0.02),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.5 * _bottomGradientOpacity),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),


              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: R.h(context, 0.02)),
                  child: ElevatedButton.icon(
                    onPressed: showAddChallengeDialog,
                    icon: Icon(Icons.add, size: R.sp(context, 0.05)),
                    label: Text(
                      "Ajouter un défi personnalisé",
                      style: TextStyle(fontSize: R.sp(context, 0.045)),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: R.h(context, 0.02),
                        horizontal: R.w(context, 0.05),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(R.w(context, 0.03)),
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

  void confirmDeleteChallenge(Challenge challenge) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Supprimer le défi", style: TextStyle(fontSize: R.sp(context, 0.045))),
        content: Text("Es-tu sûr de vouloir supprimer ce défi personnalisé ?", style: TextStyle(fontSize: R.sp(context, 0.04))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler", style: TextStyle(fontSize: R.sp(context, 0.04))),
          ),
          TextButton(
            onPressed: () async {
              setState(() => challenges.removeWhere((c) => c.id == challenge.id));
              await saveCustomChallenges();
              await saveEnabled();
              Navigator.pop(context);
            },
            child: Text("Supprimer", style: TextStyle(color: Colors.red, fontSize: R.sp(context, 0.04))),
          ),
        ],
      ),
    );
  }

  void showAddChallengeDialog() {
    final statementController = TextEditingController();
    final timeController = TextEditingController();
    final hiddenInfoController = TextEditingController();
    final objectController = TextEditingController();

    ThemeType selectedTheme = ThemeType.force;
    ChallengeType selectedType = ChallengeType.none;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setLocalState) => AlertDialog(
          title: Text(
            "Ajouter un défi",
            style: TextStyle(fontSize: R.sp(context, 0.045)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: statementController,
                  style: TextStyle(fontSize: R.sp(context, 0.04)),
                  decoration: InputDecoration(
                    labelText: "Énoncé",
                    labelStyle: TextStyle(fontSize: R.sp(context, 0.04)),
                  ),
                ),

                SizedBox(height: R.h(context, 0.02)),

                Text("THÈME DE DÉFI"),
                DropdownButton<ThemeType>(
                  value: selectedTheme,
                  isExpanded: true,
                  style: TextStyle(
                    fontSize: R.sp(context, 0.04),
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  items: ThemeType.values.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(t.name[0].toUpperCase() + t.name.substring(1)),
                    );
                  }).toList(),
                  onChanged: (v) => setLocalState(() => selectedTheme = v!),
                ),

                SizedBox(height: R.h(context, 0.02)),

                Text("TYPE DE DÉFI"),
                DropdownButton<ChallengeType>(
                  value: selectedType,
                  isExpanded: true,
                  style: TextStyle(
                    fontSize: R.sp(context, 0.04),
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  items: ChallengeType.values.map((t) {
                    String displayText;
                    switch (t) {
                      case ChallengeType.timer:
                        displayText = "Timer";
                        break;
                      case ChallengeType.chrono:
                        displayText = "Chrono";
                        break;
                      case ChallengeType.hiddenInfo:
                        displayText = "Information cachée";
                        break;
                      case ChallengeType.none:
                        displayText = "Aucun";
                        break;
                    }
                    return DropdownMenuItem(
                      value: t,
                      child: Text(displayText),
                    );
                  }).toList(),
                  onChanged: (v) => setLocalState(() => selectedType = v!),
                ),

                SizedBox(height: R.h(context, 0.02)),

                if (selectedType == ChallengeType.timer)
                  TextField(
                    controller: timeController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: R.sp(context, 0.04)),
                    decoration: InputDecoration(
                      labelText: "Durée du timer (secondes)",
                      labelStyle: TextStyle(fontSize: R.sp(context, 0.04)),
                    ),
                  ),

                if (selectedType == ChallengeType.hiddenInfo)
                  TextField(
                    controller: hiddenInfoController,
                    style: TextStyle(fontSize: R.sp(context, 0.04)),
                    decoration: InputDecoration(
                      labelText: "Information masquée",
                      labelStyle: TextStyle(fontSize: R.sp(context, 0.035)),
                    ),
                  ),
                if (selectedType == ChallengeType.hiddenInfo)
                  Row(
                    children: [
                      SizedBox(height: R.h(context, 0.08)),
                      Icon(Icons.info_outline),
                      SizedBox(width: R.w(context, 0.02)),
                      Expanded(
                        child: Text(
                          "Tapez RANDOM_LETTER ou RANDOM_NUMBER pour générer une lettre ou un nombre aléatoire (de 1 à 20).",
                        ),
                      ),                    ],
                  ),

                SizedBox(height: R.h(context, 0.02)),

                TextField(
                  controller: objectController,
                  style: TextStyle(fontSize: R.sp(context, 0.04)),
                  decoration: InputDecoration(
                    labelText: "Objet nécessaire (optionnel)",
                    labelStyle: TextStyle(fontSize: R.sp(context, 0.04)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "Annuler",
                style: TextStyle(fontSize: R.sp(context, 0.04)),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (statementController.text.trim().isEmpty) return;

                final newChallenge = Challenge(
                  id: "custom_${DateTime.now().millisecondsSinceEpoch}",
                  theme: selectedTheme,
                  statement: statementController.text,
                  type: selectedType,
                  time: selectedType == ChallengeType.timer
                      ? int.tryParse(timeController.text)
                      : null,
                  hiddenInfo: selectedType == ChallengeType.hiddenInfo
                      ? hiddenInfoController.text
                      : null,
                  needObject: objectController.text.trim().isEmpty ? null : objectController.text.trim(),
                  enabled: true,
                );

                setState(() {
                  challenges.add(newChallenge);
                });

                await saveCustomChallenges();
                await saveEnabled();

                Navigator.pop(dialogContext);
              },
              child: Text(
                "Ajouter",
                style: TextStyle(fontSize: R.sp(context, 0.04)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
