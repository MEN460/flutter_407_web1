  import 'package:flutter/material.dart';

enum ScreenType { mobile, tablet, desktop }

ScreenType getScreenType(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width > 1200) return ScreenType.desktop;
  if (width > 600) return ScreenType.tablet;
  return ScreenType.mobile;
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return desktop;
        } else if (constraints.maxWidth > 600) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

extension ResponsiveExtensions on BuildContext {
  bool get isMobile => getScreenType(this) == ScreenType.mobile;
  bool get isTablet => getScreenType(this) == ScreenType.tablet;
  bool get isDesktop => getScreenType(this) == ScreenType.desktop;
}
