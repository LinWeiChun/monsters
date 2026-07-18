import 'package:flutter/material.dart';

enum AppWindowClass { mobile, tablet, desktop }

abstract final class AppBreakpoints {
  static const double tablet = 600;
  static const double desktop = 1200;

  static AppWindowClass windowClassFor(double width) {
    if (width >= desktop) {
      return AppWindowClass.desktop;
    }
    if (width >= tablet) {
      return AppWindowClass.tablet;
    }
    return AppWindowClass.mobile;
  }
}

typedef ResponsiveWidgetBuilder =
    Widget Function(BuildContext context, BoxConstraints constraints);

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.mobile,
    required this.tablet,
    required this.desktop,
    super.key,
  });

  final ResponsiveWidgetBuilder mobile;
  final ResponsiveWidgetBuilder tablet;
  final ResponsiveWidgetBuilder desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return switch (AppBreakpoints.windowClassFor(constraints.maxWidth)) {
          AppWindowClass.mobile => mobile(context, constraints),
          AppWindowClass.tablet => tablet(context, constraints),
          AppWindowClass.desktop => desktop(context, constraints),
        };
      },
    );
  }
}

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    required this.child,
    this.maxWidth = 1200,
    this.horizontalPadding = 32,
    this.alignment = Alignment.topCenter,
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final double horizontalPadding;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}

class ResponsiveFixedCanvas extends StatelessWidget {
  const ResponsiveFixedCanvas({
    required this.canvasWidth,
    required this.canvasHeight,
    required this.child,
    this.viewportKey,
    super.key,
  });

  final double canvasWidth;
  final double canvasHeight;
  final Widget child;
  final Key? viewportKey;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / canvasWidth;
        final scaledHeight = canvasHeight * scale;
        final contentHeight =
            scaledHeight < constraints.maxHeight
                ? constraints.maxHeight
                : scaledHeight;

        return SingleChildScrollView(
          child: SizedBox(
            key: viewportKey,
            width: constraints.maxWidth,
            height: contentHeight,
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: constraints.maxWidth,
                height: scaledHeight,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: SizedBox(
                    width: canvasWidth,
                    height: canvasHeight,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
