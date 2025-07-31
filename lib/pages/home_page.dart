import 'package:flutter/material.dart';
import 'package:flutter_drift_crud/widgets/add_task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: addTaskButton(),
      body: SafeArea(child: Column(children: [Text('data')])),
    );
  }
}
