import 'package:flutter/material.dart';
import 'package:nearomart/app/core/values/colors.dart';
import 'package:nearomart/app/core/utils/size_config.dart';

enum TextType { header, title, body, caption, error, button }

class CommonText extends StatelessWidget {
  final String text;
  final TextType type;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? fontSize;
  final double? letterSpacing;

  const CommonText(
    this.text, {
    super.key,
    this.type = TextType.body,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontSize,
    this.letterSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: _getStyle(),
    );
  }

  TextStyle _getStyle() {
    switch (type) {
      case TextType.header:
        return TextStyle(
          fontSize: fontSize ?? 24.sp,
          fontWeight: fontWeight ?? FontWeight.bold,
          color: color ?? AppColors.textPrimary,
          letterSpacing: letterSpacing,
        );
      case TextType.title:
        return TextStyle(
          fontSize: fontSize ?? 18.sp,
          fontWeight: fontWeight ?? FontWeight.w600,
          color: color ?? AppColors.textPrimary,
          letterSpacing: letterSpacing,
        );
      case TextType.body:
        return TextStyle(
          fontSize: fontSize ?? 14.sp,
          fontWeight: fontWeight ?? FontWeight.normal,
          color: color ?? AppColors.textPrimary,
          letterSpacing: letterSpacing,
        );
      case TextType.caption:
        return TextStyle(
          fontSize: fontSize ?? 12.sp,
          fontWeight: fontWeight ?? FontWeight.normal,
          color: color ?? AppColors.textSecondary,
          letterSpacing: letterSpacing,
        );
      case TextType.error:
        return TextStyle(
          fontSize: fontSize ?? 12.sp,
          fontWeight: fontWeight ?? FontWeight.normal,
          color: color ?? AppColors.error,
          letterSpacing: letterSpacing,
        );
      case TextType.button:
        return TextStyle(
          fontSize: fontSize ?? 16.sp,
          fontWeight: fontWeight ?? FontWeight.w600,
          color: color ?? Colors.white,
          letterSpacing: letterSpacing,
        );
    }
  }
}
