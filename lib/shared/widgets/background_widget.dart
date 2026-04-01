import 'package:flutter/material.dart';
import '';


class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/img/full_bg.png'), // <-- your asset path
          fit: BoxFit.cover,
        ),
      ),
      alignment: AlignmentDirectional.center,
      child: child,
    );
  }
}