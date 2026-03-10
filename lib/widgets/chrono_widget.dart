import 'dart:async';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ChronoWidget extends StatefulWidget {
  final VoidCallback onStart;
  final VoidCallback onEnd;
  const ChronoWidget({
    super.key,
    required this.onStart,
    required this.onEnd,
  });

  @override
  State<ChronoWidget> createState() => _ChronoWidgetState();
}

class _ChronoWidgetState extends State<ChronoWidget> {
  Duration duration = const Duration();
  Timer? timer;
  bool running = false;

  void start() {
    widget.onStart();
    running = true;
    if (timer != null) {
      addTimer();
    } else {
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if(running) {
          addTimer();
        }
      });
    }
  }

  void addTimer() {
    duration = Duration(seconds: 1 + duration.inSeconds);
    setState(() {});
  }

  void pause() {
    widget.onEnd();
    running = false;
    setState(() {});
  }

  void stop() {
    widget.onEnd();
    timer?.cancel();
    timer = null;
    running = false;
    duration = Duration.zero;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(duration.inSeconds.toString(), style: const TextStyle(fontSize: 40)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: TextButton.styleFrom(
                backgroundColor: !running ? AppColors.primary : Colors.yellow,
              ),
              onPressed: !running ? start : pause,
              child: Text(!running ? "Start" : "Stop"),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: stop,
              child: const Icon(Icons.replay),
            ),
          ],
        )
      ],
    );
  }
}
