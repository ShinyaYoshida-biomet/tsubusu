import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const CustomText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  CustomText.title(
    this.text, {
    super.key,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = TextStyle(
          color: color,
          fontSize: fontSize ?? 20,
          fontWeight: fontWeight ?? FontWeight.bold,
        );

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}