import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qui_dit_mieux/theme/app_theme.dart';
import 'package:vibration/vibration.dart';

class TimerWidget extends StatefulWidget {
  final int seconds;
  final VoidCallback onStart;
  final VoidCallback onEnd;

  const TimerWidget({
    super.key,
    required this.seconds,
    required this.onStart,
    required this.onEnd,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late int remaining;
  Timer? timer;
  bool running = false;

  @override
  void initState() {
    super.initState();
    remaining = widget.seconds;
  }

  void start() {
    if (running) return;

    if (remaining == 0) remaining = widget.seconds;

    widget.onStart();
    running = true;

    timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted) {
        t.cancel();
        return;
      }

      if (remaining == 0) {
        t.cancel();
        running = false;
        widget.onEnd();

        if (await Vibration.hasVibrator()) {
          Vibration.vibrate(pattern: [0, 300, 200, 300]);
        }
      } else {
        setState(() => remaining--);
      }
    });
  }

  void stopAndNext() {
    timer?.cancel();
    timer = null;
    running = false;
    widget.onEnd();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("$remaining s", style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 20),
        ElevatedButton(
          style: TextButton.styleFrom(
            backgroundColor: !running ? AppColors.primary : Colors.yellow,
          ),
          onPressed: !running ? start : stopAndNext,
          child: Text(!running ? "Démarrer" : "Arrêter"),
        ),
      ],
    );
  }
}
