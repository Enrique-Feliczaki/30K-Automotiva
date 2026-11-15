import 'package:flutter/material.dart';

/// Keeps reading widths comfortable while letting scroll views fill the height.
class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    this.appBar,
    this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.maxWidth = 1100,
  });

  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final double maxWidth;

  Widget _constrain(Widget child) => Align(
    alignment: Alignment.topCenter,
    heightFactor: 1,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: SizedBox(width: double.infinity, child: child),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: appBar,
    backgroundColor: backgroundColor,
    body: body == null ? null : SafeArea(child: _constrain(body!)),
    bottomNavigationBar: bottomNavigationBar == null
        ? null
        : _constrain(bottomNavigationBar!),
    floatingActionButton: floatingActionButton,
  );
}

/// Stacks fields and actions when their usable width becomes too small.
/// Existing flex factors apply only to the horizontal arrangement.
class ResponsiveRow extends StatelessWidget {
  const ResponsiveRow({
    super.key,
    required this.children,
    this.breakpoint = 480,
    this.spacing = 10,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  });

  final List<Widget> children;
  final double breakpoint;
  final double spacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      if (constraints.maxWidth >= breakpoint * scale) {
        return Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: mainAxisSize,
          children: children,
        );
      }
      final stacked = <Widget>[];
      for (final child in children) {
        if (child is Spacer || child is SizedBox && child.child == null) {
          continue;
        }
        if (stacked.isNotEmpty) stacked.add(SizedBox(height: spacing));
        stacked.add(child is Flexible ? child.child : child);
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: stacked,
      );
    },
  );
}
