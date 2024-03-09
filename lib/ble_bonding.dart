
import 'ble_bonding_platform_interface.dart';

enum BleBondingState {
  none(10),
  bonding(11),
  bonded(12);

  const BleBondingState(this.value);
  final int value;
}

class BleBonding {
  Stream<BleBondingState> getBondingStateStream(String address) async* {
    await for (final bondingState
        in BleBondingPlatform.instance.getBondingStateStream(address)) {
      yield BleBondingState.values
          .firstWhere((element) => element.value == bondingState);
    }
  }

  Future<BleBondingState> getBondingState(String address) async {
    final maybeBondingState =
        await BleBondingPlatform.instance.getBondingState(address);
    return BleBondingState.values
        .firstWhere((element) => element.value == maybeBondingState);
  }

  Future<void> bond(String address) {
    return BleBondingPlatform.instance.bond(address);
  }

  Future<void> unbound(String address) {
    return BleBondingPlatform.instance.unbound(address);
  }

  Future<bool> isPaired(String address) {
    return BleBondingPlatform.instance.isPaired(address);
  }
}
