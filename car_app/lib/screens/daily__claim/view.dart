import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'logic.dart';

class DailyRewardScreen extends StatefulWidget {
  DailyRewardScreen({super.key});

  final Daily_ClaimLogic logic = Get.put(Daily_ClaimLogic());

  @override
  State<DailyRewardScreen> createState() => _DailyRewardScreenState();
}

class _DailyRewardScreenState extends State<DailyRewardScreen> {
  int coins = 0;
  int lastDailyRewardDay = 0;
  int dailyRewardCycle = 0;
  final List<int> dailyRewards = [50, 100, 200, 300, 4000, 500, 600, 700];

  @override
  void initState() {
    super.initState();
    loadGameState();
  }

  Future<void> loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      coins = prefs.getInt('coins') ?? 0;
      lastDailyRewardDay = prefs.getInt('lastDailyRewardDay') ?? 0;
      dailyRewardCycle = prefs.getInt('dailyRewardCycle') ?? 0;
    });
  }

  Future<void> saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', coins);
    await prefs.setInt('lastDailyRewardDay', lastDailyRewardDay);
    await prefs.setInt('dailyRewardCycle', dailyRewardCycle);
  }

  Future<void> claimDailyReward() async {
    final today = DateTime.now().day;
    if (today != lastDailyRewardDay) {
      setState(() {
        coins += dailyRewards[dailyRewardCycle];
        lastDailyRewardDay = today;
        dailyRewardCycle = (dailyRewardCycle + 1) % dailyRewards.length;
      });
      saveGameState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fullscreen background image
        Positioned.fill(
          child: Image.asset(
            "assets/img_2.png",
            fit: BoxFit.cover,
          ),
        ),
        // Content of the DailyRewardScreen
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Daily Rewards'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: dailyRewards.length,
                  itemBuilder: (context, index) {
                    final bool isToday = index == dailyRewardCycle;
                    final bool isPast = index < dailyRewardCycle;

                    return Card(
                      color: isToday
                          ? Colors.green
                          : (isPast ? Colors.grey[800] : Colors.blue[900]),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Day ${index + 1}',
                            style: TextStyle(
                              color: isToday ? Colors.white : Colors.grey[400],
                            ),
                          ),
                          Text(
                            '${dailyRewards[index]}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isToday ? Colors.white : Colors.grey[400],
                            ),
                          ),
                          if (isPast)
                            const Icon(Icons.check_circle, color: Colors.green),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: (index * 100).ms)
                        .scale(delay: (index * 100).ms);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: claimDailyReward,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                  ),
                  child: const Text(
                    'CLAIM',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
