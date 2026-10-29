import 'package:flutter/widgets.dart';

class ResponsiveExpanded extends StatelessWidget {
  final Widget child;
  final bool isExpanded;

  const ResponsiveExpanded({
    super.key,
    required this.child,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    // If true, returns Expanded, otherwise returns the raw child
    return isExpanded ? Expanded(child: child) : child;
  }
}
