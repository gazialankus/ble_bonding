
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

  Stream<BleBondingState> getBondingStateStream(String address) async* {
    var localState = tmpState;
    yield localState;
    while (localState != BleBondingState.bonded) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (localState != tmpState) {
        localState = tmpState;
        yield localState;
      }
    }
  }

  Future<BleBondingState> getBondingState(String address) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return tmpState;
  }

  var tmpState = BleBondingState.none;

  Future<void> bond(String address) async {
    await Future.delayed(const Duration(seconds: 4));
    tmpState = BleBondingState.bonding;
    await Future.delayed(const Duration(seconds: 4));
    tmpState = BleBondingState.bonded;
  }
}
