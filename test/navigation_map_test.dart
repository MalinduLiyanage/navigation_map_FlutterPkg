import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_map/navigation_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class BaseWidget extends StatelessWidget {
  const BaseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigationMapState> navMapKey = GlobalKey();

    return SafeArea(
      child: Scaffold(
        body: NavigationMap(
          key: navMapKey,
        ),
      ),
    );
  }
}
