import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/task.dart';
import 'logic.dart';

class TasksScreen extends StatefulWidget {
  TasksScreen({super.key});
  final TaskScreenLogic logic = Get.put(TaskScreenLogic());

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int coins = 0;
  final List<Task> tasks = [
    Task(
      title: 'Join Youtube Channel',
      description: 'Join our Youtube channel',
      reward: 1000,
      url: 'https://www.youtube.com/channel/UCv4GSeaHpUA7OTuBoGTGGRQ',
      icon: Icons.youtube_searched_for,
    ),
    Task(
      title: 'Join Whatsapp Group',
      description: 'Join our Whatsapp group',
      reward: 1000,
      url: 'https://whatsapp.com/channel/0029Vb2oQAX0VycAnfZGno00',
      icon: Icons.group,
    ),
    Task(
      title: 'Join Telegram',
      description: 'Join us on Telegram',
      reward: 3000,
      url: 'https://t.me/ra0745',
      icon: Icons.telegram,
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
      }
    });
  }

  Future<void> saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', coins);

    for (int i = 0; i < tasks.length; i++) {
      await prefs.setBool('task_$i', tasks[i].isCompleted);
    }
  }

  Future<void> completeTask(int index) async {
    if (!tasks[index].isCompleted) {
      final url = Uri.parse(tasks[index].url);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
        setState(() {
          tasks[index].isCompleted = true;
          coins += tasks[index].reward;
        });
        saveGameState();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.asset(
            "assets/img_1.png",
            fit: BoxFit.cover,
          ),
        ),
        // ListView of tasks
        Scaffold(
          backgroundColor: Colors.transparent,
          body: ListView.builder(
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
      ],
    );
  }
}
