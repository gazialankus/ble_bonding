
import 'ble_bonding_platform_interface.dart';

class BleBonding {
  Future<String?> getPlatformVersion() {
    return BleBondingPlatform.instance.getPlatformVersion();
  }
}
