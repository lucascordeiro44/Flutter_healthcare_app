import 'package:flutter/material.dart';

import 'base_container.dart';

//salvador de vidas de usar expanded em uma coluna que precisa de scroll.
class AppLayoutBuilder extends StatelessWidget {
  final EdgeInsets padding;
  final bool needSingleChildScrollView;
  final Widget child;
  final Alignment alignment;

  const AppLayoutBuilder(
      {Key key,
      this.padding,
      this.needSingleChildScrollView = false,
      this.child,
      this.alignment})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return BaseContainer(
          padding: padding,
          needSingleChildScrollView: needSingleChildScrollView,
          alignment: alignment,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraint.maxHeight,
              minWidth: constraint.maxWidth,
            ),
            child: IntrinsicHeight(
              child: child,
            ),
          ),
        );
      },
    );
  }
}
