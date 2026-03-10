import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/random_widget.dart';

class HiddenInfoWidget extends StatefulWidget {
  final String info;
  final VoidCallback? onReveal;
  const HiddenInfoWidget({super.key, required this.info, this.onReveal});

  @override
  State<HiddenInfoWidget> createState() => _HiddenInfoWidgetState();
}

class _HiddenInfoWidgetState extends State<HiddenInfoWidget> {
  bool revealed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          style: TextButton.styleFrom(
            backgroundColor: !revealed ? AppColors.primary : Colors.grey.withValues(alpha: 0.4),
            foregroundColor: !revealed ? Colors.black : Colors.black.withValues(alpha: 0.6)
          ),
          onPressed: revealed
              ? null
              : () {
            setState(() => revealed = true);
            widget.onReveal?.call();
          },
          child: Text(revealed ? "Information révélée" : "Révéler l'information"),
        ),
        if (revealed)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: buildHiddenContent(),
          )
      ],
    );
  }

  Widget buildHiddenContent() {
    switch (widget.info) {
      case "RANDOM_LETTER":
        return RandomLetterWidget();
      case "RANDOM_NUMBER":
        return RandomNumberWidget(max: 20);
      default:
        return Text(
          widget.info,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        );
    }
  }

}
