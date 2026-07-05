import 'package:flutter/widgets.dart';

/// Screen size buckets used to adapt the UI for web/desktop, tablet and mobile.
enum DeviceType { mobile, tablet, desktop }

/// Breakpoints and helpers for building a responsive, web-friendly UI.
///
/// The wallet feature must run well on Flutter Web, so layouts read the current
/// [DeviceType] to decide column counts, content max-width, etc.
abstract final class Breakpoints {
  const Breakpoints._();

  static const double tablet = 600;
  static const double desktop = 1024;

  /// Max content width so the UI does not stretch edge-to-edge on wide screens.
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

/// Constrains its [child] to a comfortable reading width and centers it.
///
/// Used to keep forms and lists readable on large web/desktop windows.
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
