import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;

  double widthPct(double percent) => width * percent;
  double heightPct(double percent) => height * percent;

  double scaledSp(double size) => MediaQuery.textScalerOf(this).scale(size);
}
