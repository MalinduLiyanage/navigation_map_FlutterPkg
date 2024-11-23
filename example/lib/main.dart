import 'package:flutter/material.dart';
import 'package:navigation_map/navigation_map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      home: const home,
    );
  }
}

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  final GlobalKey<NavigationMapState> navMapKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: NavigationMap(
        key: navMapKey,
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        
      }),
    ));
  }
}
