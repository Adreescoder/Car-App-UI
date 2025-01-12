import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic.dart';

class Home_ScreenPage extends StatelessWidget {
  Home_ScreenPage({Key? key}) : super(key: key);

  final Home_ScreenLogic logic = Get.put(Home_ScreenLogic());

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.indigo,
      child: Text("Telegram mini app"),
    );
  }
}
