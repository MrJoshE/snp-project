import 'package:flutter/material.dart';

class AppBlockingLoadingView extends StatelessWidget {
  final bool isBlocking;
  final Widget child;
  const AppBlockingLoadingView({
    required this.isBlocking,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      child,
      if (isBlocking) ...[
        ModalBarrier(
          color: Colors.white.withOpacity(0.8),
          dismissible: false,
        ),
        const SafeArea(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ]
    ]);
  }
}
