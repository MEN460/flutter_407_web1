import 'package:flutter/material.dart';

/// Represents different screen size categories for responsive design
enum ScreenType {
  mobile,
  tablet,
  desktop,

  /// Optional extra large desktop screens
  ultrawide,
}

/// Configuration class for responsive breakpoints
class ResponsiveBreakpoints {
  final double mobile;
  final double tablet;
  final double desktop;
  final double ultrawide;

  const ResponsiveBreakpoints({
    this.mobile = 0,
    this.tablet = 600,
    this.desktop = 1200,
    this.ultrawide = 1920,
  }) : assert(
         mobile <= tablet && tablet <= desktop && desktop <= ultrawide,
         'Breakpoints must be in ascending order',
       );

  /// Material Design breakpoints (default)
  static const material = ResponsiveBreakpoints();

  /// Bootstrap-inspired breakpoints
  static const bootstrap = ResponsiveBreakpoints(
    mobile: 0,
    tablet: 768,
    desktop: 992,
    ultrawide: 1400,
  );

  /// Tailwind CSS inspired breakpoints
  static const tailwind = ResponsiveBreakpoints(
    mobile: 0,
    tablet: 640,
    desktop: 1024,
    ultrawide: 1536,
  );
}

/// Extension to easily get screen type from BuildContext
extension ResponsiveContext on BuildContext {
  /// Gets the current screen type based on available width
  ScreenType get screenType => getScreenType(this);

  /// Gets the current breakpoints configuration
  ResponsiveBreakpoints get breakpoints =>
      ResponsiveConfig.of(this)?.breakpoints ?? ResponsiveBreakpoints.material;

  /// Checks if current screen is mobile
  bool get isMobile => screenType == ScreenType.mobile;

  /// Checks if current screen is tablet or larger
  bool get isTabletOrLarger => screenType != ScreenType.mobile;

  /// Checks if current screen is desktop or larger
  bool get isDesktopOrLarger =>
      screenType == ScreenType.desktop || screenType == ScreenType.ultrawide;
}

/// Configuration provider for responsive layouts
class ResponsiveConfig extends InheritedWidget {
  final ResponsiveBreakpoints breakpoints;
  final bool considerOrientation;

  const ResponsiveConfig({
    super.key,
    required super.child,
    this.breakpoints = ResponsiveBreakpoints.material,
    this.considerOrientation = true,
  });

  static ResponsiveConfig? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ResponsiveConfig>();
  }

  @override
  bool updateShouldNotify(ResponsiveConfig oldWidget) {
    return breakpoints != oldWidget.breakpoints ||
        considerOrientation != oldWidget.considerOrientation;
  }
}

/// Determines screen type based on available width and configuration
ScreenType getScreenType(BuildContext context, [double? width]) {
  final config = ResponsiveConfig.of(context);
  final breakpoints = config?.breakpoints ?? ResponsiveBreakpoints.material;

  // Use provided width or get from LayoutBuilder context if available
  final screenWidth = width ?? _getAvailableWidth(context);

  // Consider orientation if enabled
  if (config?.considerOrientation == true) {
    final orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.portrait &&
        screenWidth < breakpoints.tablet * 1.2) {
      // Bias towards mobile in portrait mode
      if (screenWidth >= breakpoints.tablet) {
        return ScreenType.mobile;
      }
    }
  }

  if (screenWidth >= breakpoints.ultrawide) return ScreenType.ultrawide;
  if (screenWidth >= breakpoints.desktop) return ScreenType.desktop;
  if (screenWidth >= breakpoints.tablet) return ScreenType.tablet;
  return ScreenType.mobile;
}

/// Helper to get available width, preferring LayoutBuilder context
double _getAvailableWidth(BuildContext context) {
  // Try to get width from LayoutBuilder if available
  try {
    return context.findAncestorWidgetOfExactType<LayoutBuilder>() != null
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.width;
  } catch (e) {
    // Fallback to MediaQuery
    return MediaQuery.of(context).size.width;
  }
}

/// A flexible responsive layout widget that adapts to different screen sizes
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? ultrawide;

  /// Custom builder function that receives screen type and constraints
  final Widget Function(
    BuildContext context,
    ScreenType screenType,
    BoxConstraints constraints,
  )?
  builder;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.ultrawide,
  }) : builder = null;

  /// Constructor for custom builder pattern
  const ResponsiveLayout.builder({super.key, required this.builder})
    : mobile = const SizedBox.shrink(),
      tablet = null,
      desktop = null,
      ultrawide = null;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = getScreenType(context, constraints.maxWidth);

        // Use custom builder if provided
        if (builder != null) {
          return builder!(context, screenType, constraints);
        }

        // Use widget-based approach with smart fallbacks
        return _buildForScreenType(screenType);
      },
    );
  }

  Widget _buildForScreenType(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.ultrawide:
        return ultrawide ?? desktop ?? tablet ?? mobile;
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.mobile:
        return mobile;
    }
  }
}

/// Utility widget for responsive values
class ResponsiveValue<T> extends StatelessWidget {
  final T mobile;
  final T? tablet;
  final T? desktop;
  final T? ultrawide;
  final Widget Function(T value) builder;

  const ResponsiveValue({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.ultrawide,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = getScreenType(context, constraints.maxWidth);
        final value = _getValueForScreenType(screenType);
        return builder(value);
      },
    );
  }

  T _getValueForScreenType(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.ultrawide:
        return ultrawide ?? desktop ?? tablet ?? mobile;
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.mobile:
        return mobile;
    }
  }
}

/// Example usage demonstrating the responsive system
class ResponsiveExample extends StatelessWidget {
  const ResponsiveExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveConfig(
      breakpoints: ResponsiveBreakpoints.material,
      considerOrientation: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Responsive Layout (${context.screenType.name})'),
        ),
        body: Column(
          children: [
            // Example 1: Widget-based responsive layout
            Expanded(
              child: ResponsiveLayout(
                mobile: _buildMobileLayout(),
                tablet: _buildTabletLayout(),
                desktop: _buildDesktopLayout(),
              ),
            ),

            // Example 2: Builder-based responsive layout
            ResponsiveLayout.builder(
              builder: (context, screenType, constraints) {
                return Container(
                  height: 100,
                  color: _getColorForScreenType(screenType),
                  child: Center(
                    child: Text(
                      '${screenType.name.toUpperCase()}\n${constraints.maxWidth.toInt()}px wide',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Example 3: Responsive values
            ResponsiveValue<int>(
              mobile: 1,
              tablet: 2,
              desktop: 3,
              ultrawide: 4,
              builder: (columns) => GridView.count(
                shrinkWrap: true,
                crossAxisCount: columns,
                children: List.generate(
                  columns * 2,
                  (index) =>
                      Card(child: Center(child: Text('Item ${index + 1}'))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.phone_android, size: 64),
          SizedBox(height: 16),
          Text('Mobile Layout', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return const Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.tablet, size: 64),
          Text('Tablet Layout', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        children: const [
          Card(child: Icon(Icons.desktop_windows, size: 32)),
          Card(child: Center(child: Text('Desktop'))),
          Card(child: Center(child: Text('Layout'))),
        ],
      ),
    );
  }

  Color _getColorForScreenType(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return Colors.green;
      case ScreenType.tablet:
        return Colors.blue;
      case ScreenType.desktop:
        return Colors.purple;
      case ScreenType.ultrawide:
        return Colors.orange;
    }
  }
}
