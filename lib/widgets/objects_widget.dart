import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../utils/responsive.dart';

class ObjectsWidget extends StatefulWidget {
  final List<Challenge> challenges;

  const ObjectsWidget({super.key, required this.challenges});

  @override
  State<ObjectsWidget> createState() => _ObjectsWidgetState();
}

class _ObjectsWidgetState extends State<ObjectsWidget> {
  late Map<String, bool> objectsMap;

  @override
  void initState() {
    super.initState();
    final allObjects = widget.challenges
        .where((c) => c.needObject != null)
        .map((c) => c.needObject!)
        .toSet()
        .toList();
    objectsMap = {for (var obj in allObjects) obj: true};
  }

  @override
  Widget build(BuildContext context) {
    final objects = objectsMap.keys.toList();
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: R.padding(context, 0.04),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Objets nécessaires",
                style: theme.textTheme.titleLarge!.copyWith(
                  color: Colors.white,
                  fontSize: R.sp(context, 0.05),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: R.h(context, 0.015)),
              Text(
                "Vous pourriez avoir besoin de certains objets pour les défis. "
                    "Décochez ceux que vous n'avez pas pour éviter ces défis.",
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: Colors.white70,
                  fontSize: R.sp(context, 0.04),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: R.h(context, 0.02)),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: objects.length,
                  separatorBuilder: (_, _) => Divider(color: Colors.white12),
                  itemBuilder: (context, index) {
                    final obj = objects[index];
                    return CheckboxListTile(
                      value: objectsMap[obj],
                      activeColor: Colors.lightBlueAccent,
                      checkColor: Colors.black,
                      title: Text(
                        obj[0].toUpperCase() + obj.substring(1),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: R.sp(context, 0.045),
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      onChanged: (v) => setState(() => objectsMap[obj] = v!),
                    );
                  },
                ),
              ),
              SizedBox(height: R.h(context, 0.02)),
              ElevatedButton(
                onPressed: () {
                  final selectedObjects = objectsMap.entries
                      .where((e) => e.value)
                      .map((e) => e.key)
                      .toList();
                  Navigator.pop(context, selectedObjects);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  padding: EdgeInsets.symmetric(
                    horizontal: R.w(context, 0.06),
                    vertical: R.h(context, 0.015),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  "Valider",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: R.sp(context, 0.042),
                    fontWeight: FontWeight.bold,
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