import 'package:flutter/material.dart';

class ResponsiveValues {
  final double screenWidth;
  final bool isSmallScreen;
  final double iconSize;
  final double iconInnerSize;
  final double titleFontSize;
  final double countFontSize;
  final double detailFontSize;
  final double horizontalPadding;
  final double verticalPadding;

  const ResponsiveValues._({
    required this.screenWidth,
    required this.isSmallScreen,
    required this.iconSize,
    required this.iconInnerSize,
    required this.titleFontSize,
    required this.countFontSize,
    required this.detailFontSize,
    required this.horizontalPadding,
    required this.verticalPadding,
  });

  factory ResponsiveValues.fromContext(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isSmall = w < 375;
    return ResponsiveValues._(
      screenWidth: w,
      isSmallScreen: isSmall,
      iconSize: isSmall ? 50.0 : 64.0,
      iconInnerSize: isSmall ? 24.0 : 32.0,
      titleFontSize: isSmall ? 14.0 : 16.0,
      countFontSize: isSmall ? 24.0 : 32.0,
      detailFontSize: isSmall ? 11.0 : 12.0,
      horizontalPadding: w * 0.04,
      verticalPadding: isSmall ? 16.0 : 24.0,
    );
  }
}

extension ResponsiveExt on BuildContext {
  ResponsiveValues get rv => ResponsiveValues.fromContext(this);
}