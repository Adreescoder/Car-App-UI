import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/task.dart';
import 'logic.dart';

class GiftscreenPage extends StatefulWidget {
  GiftscreenPage({super.key});
  final GifScreenLogic logic = Get.put(GifScreenLogic());

  @override
  State<GiftscreenPage> createState() => _GiftscreenState();
}

class _GiftscreenState extends State<GiftscreenPage> {
  int coins = 0;

  // 9 tasks with different links and reward values
  final List<Task> tasks = [
    Task(
      title: 'Click To Complete Task 1',
      description: 'Watch ads in 30 seconds',
      reward: 100,
      url: 'https://poawooptugroo.com/4/8740522',
      icon: Icons.star,
    ),
    Task(
      title: 'Click To Complete Task 2',
      description: 'Watch ads in 30 seconds',
      reward: 100,
      url: 'https://poawooptugroo.com/4/8416420',
      icon: Icons.star,
    ),
    Task(
      title: 'Click To Complete Task 3',
      description: 'Watch ads in 30 seconds',
      reward: 100,
      url: 'https://poawooptugroo.com/4/8416428',
      icon: Icons.star,
    ),
    Task(
      title: 'Click To Complete Task 4',
      description: 'Watch ads in 30 seconds',
      reward: 100,
      url: 'https://poawooptugroo.com/4/8416420',
      icon: Icons.star,
    ),
    Task(
      title: 'Click To Complete Task 5',
      description: 'Watch ads in 30 seconds',
      reward: 100,
      url: 'https://poawooptugroo.com/4/8416426',
      icon: Icons.star,
    ),
    Task(
      title: 'Click To Complete Task 6',
      description: 'Watch ads in 30 seconds',
      reward: 100,
      url: 'https://poawooptugroo.com/4/8416429',
      icon: Icons.star,
    ),
    Task(
      title: 'Click To Complete Task 7',
      description: 'Watch ads in 30 seconds',
      reward: 100,
      url: 'https://poawooptugroo.com/4/8416429',
      icon: Icons.star,
    ),
    Task(
      title: 'Click To Complete Task 8',
      description: 'Watch ads in 30 seconds',
      reward: 450,
      url: 'https://poawooptugroo.com/4/8416430',
      icon: Icons.star,
    ),
    Task(
      title: 'Click To Complete Task 9',
      description: 'Watch ads in 30 seconds',
      reward: 500,
      url: 'https://poawooptugroo.com/4/8416425',
      icon: Icons.star,
    ),
  ];

  @override
  void initState() {
    super.initState();
    loadGameState();
  }

  Future<void> loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      coins = prefs.getInt('coins') ?? 0;
      for (int i = 0; i < tasks.length; i++) {
        tasks[i].isCompleted = prefs.getBool('task_$i') ?? false;
        tasks[i].lastOpened = prefs.getInt('task_${i}_timestamp') ?? 0;
      }
    });
  }

  Future<void> saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', coins);

    for (int i = 0; i < tasks.length; i++) {
      await prefs.setBool('task_$i', tasks[i].isCompleted);
      await prefs.setInt('task_${i}_timestamp', tasks[i].lastOpened);
    }
  }

  Future<void> completeTask(int index) async {
    final task = tasks[index];
    int currentTime = DateTime.now().millisecondsSinceEpoch;

    // If task was completed within the last 24 hours, prevent re-opening
    if (task.isCompleted) {
      int timeElapsed = currentTime - task.lastOpened;
      if (timeElapsed < 86400000) {
        // 24 hours in milliseconds
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You can open this task after 24 hours!')),
        );
        return;
      }
    }

    final url = Uri.parse(task.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
      setState(() {
        task.isCompleted = true;
        task.lastOpened = currentTime;
        coins += task.reward;
      });
      saveGameState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gift Screen'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/12.jpg'), // Your image path
            fit: BoxFit.cover, // Ensures the image covers the whole screen
          ),
          // You can add the gradient on top of the image if you want
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7)
            ], // Gradients with transparency for better visibility of content
          ),
        ),
        child: ListView.builder(
          itemCount: tasks.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Card(
              color: Colors.blue[900]!.withOpacity(0.3),
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Icon(task.icon, color: Colors.white),
                title: Text(
                  task.title,
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: task.isCompleted
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : Text(
                        '+${task.reward}',
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                onTap: () => completeTask(index),
              ),
            )
                .animate()
                .fadeIn(delay: (index * 100).ms)
                .slideX(delay: (index * 100).ms);
          },
        ),
      ),
    );
  }
}
