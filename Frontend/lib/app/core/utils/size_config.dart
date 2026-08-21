import 'package:flutter/material.dart';

class SizeConfig {
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;

  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  static double? _textMultiplier;
  static double? _heightMultiplier;
  static double? _widthMultiplier;

  static const double baseWidth = 375;
  static const double baseHeight = 812;

  void init(BoxConstraints constraints, Orientation orientation) {
    if (orientation == Orientation.portrait) {
      screenWidth = constraints.maxWidth;
      screenHeight = constraints.maxHeight;
    } else {
      screenWidth = constraints.maxHeight;
      screenHeight = constraints.maxWidth;
    }

    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _textMultiplier = blockSizeVertical;
    _heightMultiplier = blockSizeVertical;
    _widthMultiplier = blockSizeHorizontal;

    _heightMultiplier = screenHeight / baseHeight;
    _widthMultiplier = screenWidth / baseWidth;
    
    _textMultiplier = (screenWidth / baseWidth);
  }

  static double get h => _heightMultiplier ?? 1.0;
  static double get w => _widthMultiplier ?? 1.0;
  static double get sp => _textMultiplier ?? 1.0;
}

extension SizeExtension on num {
  double get h => this * SizeConfig.h;
  double get w => this * SizeConfig.w;
  double get sp => this * SizeConfig.sp;
}
