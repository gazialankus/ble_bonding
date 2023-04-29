
import 'ble_bonding_platform_interface.dart';

enum BleBondingState {
  none(10),
  bonding(11),
  bonded(12);

  const BleBondingState(this.value);
  final int value;
}

class BleBonding {
  Future<String?> getPlatformVersion() {
    return BleBondingPlatform.instance.getPlatformVersion();
  }

  Stream<BleBondingState> getBondingStateStream(String address) async* {
    // TODO implement
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
    final maybeBondingState =
        await BleBondingPlatform.instance.getBondingState(address);
    return BleBondingState.values
        .firstWhere((element) => element.value == maybeBondingState);
  }

  var tmpState = BleBondingState.none;

  Future<void> bond(String address) {
    return BleBondingPlatform.instance.bond(address);
  }
}
