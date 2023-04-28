
import 'ble_bonding_platform_interface.dart';

enum BleBondingState {
  none,
  bonding,
  bonded,
}

class BleBonding {
  Future<String?> getPlatformVersion() {
    return BleBondingPlatform.instance.getPlatformVersion();
  }

  Stream<BleBondingState> get bondingStateStream async* {

  }

  Future<BleBondingState> getBondingState(String address) async {

  }

  Future<void> bond(String address) async {
    
  }
}
