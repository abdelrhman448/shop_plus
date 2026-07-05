import 'package:flutter/widgets.dart';

enum DeviceType { mobile, tablet, desktop }

// Breakpoints + helpers so the UI behaves on web/desktop, not just phones.
abstract final class Breakpoints {
  const Breakpoints._();

  static const double tablet = 600;
  static const double desktop = 1024;

  // Don't let content stretch full-width on big screens.
  static const double maxContentWidth = 900;

  static DeviceType deviceTypeOf(double width) {
    if (width >= desktop) return DeviceType.desktop;
    if (width >= tablet) return DeviceType.tablet;
    return DeviceType.mobile;
  }
}

extension ResponsiveContext on BuildContext {
  DeviceType get deviceType =>
      Breakpoints.deviceTypeOf(MediaQuery.sizeOf(this).width);

  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop;
}

// Centers the child and caps its width. Keeps forms/lists readable on desktop.
class CenteredContent extends StatelessWidget {
  const CenteredContent({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContentWidth,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
