import 'package:flutter/material.dart';
import 'widgets.dart';

class AboutMedium extends StatelessWidget {
  const AboutMedium({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 600,
          child: AboutWidget(),
        ),
      ),
    );
  }
}
