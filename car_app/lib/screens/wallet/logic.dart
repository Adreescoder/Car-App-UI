import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletLogic extends GetxController {
  var coins = 0.obs;

  WalletLogic() {
    loadCoins();
  }

  Future<void> loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    coins.value = prefs.getInt('coins') ?? 0;
  }

  Future<void> saveCoins() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', coins.value);
  }

  void incrementCoins() {
    coins.value++;
  }
}
