import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'logic.dart';

class GameScreen extends StatefulWidget {
  GameScreen({super.key});
  final GameScreenLogic logic = Get.put(GameScreenLogic());

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int coins = 0;
  int battery = 1000; // Start battery at 1000
  final int maxBattery = 1000;
  bool isBatteryRecharging = false;
  Timer? batteryTimer;
  Timer? batteryAnimationTimer;
  late AnimationController _bounceController;
  late AnimationController _batteryFillController;
  double batteryFillPercentage = 1.0;

  @override
  void initState() {
    super.initState();
    loadGameState();
    setupAnimations();
  }

  void setupAnimations() {
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _batteryFillController = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 1),
    );
  }

  Future<void> loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      coins = prefs.getInt('coins') ?? 0;
      battery =
          prefs.getInt('battery') ?? 1000; // Ensure the battery starts at 1000
    });
  }

  Future<void> saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', coins);
    await prefs.setInt('battery', battery);
  }

  void onTap() {
    if (battery > 0 && !isBatteryRecharging) {
      setState(() {
        coins++;
        battery--;
      });
      saveGameState();
    }
    // Start recharge when battery reaches 0
    if (battery <= 0 && !isBatteryRecharging) {
      startBatteryRecharge();
    }
  }

  void startBatteryRecharge() {
    isBatteryRecharging = true;
    batteryFillPercentage = 0.0;
    _batteryFillController.reset();
    _batteryFillController.forward();

    const totalRechargeTime = Duration(minutes: 1);
    const updateInterval = Duration(milliseconds: 50);
    final totalSteps =
        totalRechargeTime.inMilliseconds ~/ updateInterval.inMilliseconds;
    final incrementPerStep = maxBattery / totalSteps;
    batteryAnimationTimer?.cancel();
    batteryAnimationTimer = Timer.periodic(updateInterval, (timer) {
      if (!isBatteryRecharging) {
        timer.cancel();
        return;
      }

      setState(() {
        battery = (battery + incrementPerStep).clamp(0, maxBattery).toInt();
        batteryFillPercentage = battery / maxBattery;
      });

      if (battery >= maxBattery) {
        timer.cancel();
        setState(() {
          isBatteryRecharging = false;
        });
      }
    });

    batteryTimer = Timer(const Duration(minutes: 1), () {
      setState(() {
        battery = maxBattery;
        isBatteryRecharging = false;
      });
      saveGameState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage("assets/1122.jpg"),
          fit: BoxFit.cover,
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue[900]!, Colors.black],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/coin.png",
                          width: 50,
                          height: 50,
                        ),
                        Text(
                          '$coins',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .scale(delay: 300.ms),
                      ],
                    ),
                    const Text(
                      'COINS',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 200,
                      child: LinearProgressIndicator(
                        value: battery / maxBattery,
                        backgroundColor: Colors.grey[800],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isBatteryRecharging ? Colors.orange : Colors.yellow,
                        ),
                      ),
                    ),
                    Text(
                      'Battery: $battery/$maxBattery',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                Positioned(
                  right: 10,
                  child: Image.asset(
                    "assets/11.gif",
                    width: 60,
                    height: 60,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTapDown: (_) {
                  _bounceController.forward(from: 0.0);
                  onTap();
                },
                child: AnimatedBuilder(
                  animation: _bounceController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 - (_bounceController.value * 0.1),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.blue[900],
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: Center(child: Image.asset("assets/hamster.png")),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    batteryTimer?.cancel();
    batteryAnimationTimer?.cancel();
    _bounceController.dispose();
    _batteryFillController.dispose();
    super.dispose();
  }
}

//// very nice
