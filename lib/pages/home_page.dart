import 'package:flutter/material.dart';
import 'package:flutter_drift_crud/widgets/add_task.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: addTaskButton(),
      body: SafeArea(child: Column(children: [Text('test2')])),
    );
  }
}
