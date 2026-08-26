import 'package:flutter/material.dart';

class AppSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double s = 12.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const Widget heightXXS = SizedBox(height: xxs);
  static const Widget heightXS = SizedBox(height: xs);
  static const Widget heightS = SizedBox(height: s);
  static const Widget heightM = SizedBox(height: m);
  static const Widget heightL = SizedBox(height: l);
  static const Widget heightXL = SizedBox(height: xl);

  static const Widget widthXXS = SizedBox(width: xxs);
  static const Widget widthXS = SizedBox(width: xs);
  static const Widget widthS = SizedBox(width: s);
  static const Widget widthM = SizedBox(width: m);
  static const Widget widthL = SizedBox(width: l);
  static const Widget widthXL = SizedBox(width: xl);
}

class AppRadius {
  static const double s = 6.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 24.0;
  static const double circular = 999.0;

  static BorderRadius radiusS = BorderRadius.circular(s);
  static BorderRadius radiusM = BorderRadius.circular(m);
  static BorderRadius radiusL = BorderRadius.circular(l);
  static BorderRadius radiusXL = BorderRadius.circular(xl);
  static BorderRadius radiusCircular = BorderRadius.circular(circular);
}

class AppShadows {
  static List<BoxShadow> light = [
    const BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.04),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
    const BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.01),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static List<BoxShadow> dark = [
    const BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.3),
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];
}
