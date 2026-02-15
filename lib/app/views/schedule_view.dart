import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScheduleView extends StatelessWidget {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    final level = Get.parameters['level'];

    return Scaffold(
      appBar: AppBar(title: Text('Level $level Schedule')),
      body: Center(
        child: Text(
          'Schedule Placeholder for Level $level',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
