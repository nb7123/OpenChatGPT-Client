
import 'package:flutter/material.dart';

import '../../widgets/app_bar.dart';
import 'widgets.dart';

class MainCompat extends StatefulWidget {
  const MainCompat({super.key});

  @override
  State<StatefulWidget> createState() => _MainCompatState();
}

class _MainCompatState extends State<MainCompat> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AxionAppBar(),
      body: HomeContentWidget()
    );
  }
}
