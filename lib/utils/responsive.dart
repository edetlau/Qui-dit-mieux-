import 'package:flutter/material.dart';

class R {
  static Size _size(BuildContext context) => MediaQuery.of(context).size;

  static double w(BuildContext context, double percent) {
    return _size(context).width * percent;
  }

  static double h(BuildContext context, double percent) {
    return _size(context).height * percent;
  }

  static double sp(BuildContext context, double percent) {
    return _size(context).width * percent;
  }

  static EdgeInsets padding(BuildContext context, double percent) {
    return EdgeInsets.all(_size(context).width * percent);
  }

  static EdgeInsets paddingH(BuildContext context, double percent) {
    return EdgeInsets.symmetric(horizontal: _size(context).width * percent);
  }

  static EdgeInsets paddingV(BuildContext context, double percent) {
    return EdgeInsets.symmetric(vertical: _size(context).height * percent);
  }

  static bool isSmallScreen(BuildContext context) {
    return _size(context).width < 600;
  }

  static bool isMediumScreen(BuildContext context) {
    final width = _size(context).width;
    return width >= 600 && width < 1200;
  }

  static bool isLargeScreen(BuildContext context) {
    return _size(context).width >= 1200;
  }

  static double adaptiveText(BuildContext context, {
    double small = 14,
    double medium = 16,
    double large = 18,
  }) {
    if (isSmallScreen(context)) return small;
    if (isMediumScreen(context)) return medium;
    return large;
  }
}