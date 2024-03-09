import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ble_bonding_platform_interface.dart';

/// An implementation of [BleBondingPlatform] that uses method channels.
class MethodChannelBleBonding extends BleBondingPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ble_bonding');
  @visibleForTesting
  final stateEventChannel = const EventChannel('ble_bonding_state_stream');

  @override
  Future<void> bond(String address) {
    return methodChannel.invokeMethod<void>('bond', {'address': address});
  }

  @override
  Future<void> unbound(String address) {
    return methodChannel.invokeMethod<void>('unbound', {'address': address});
  }

  @override
  Future<int?> getBondingState(String address) {
    return methodChannel.invokeMethod<int>('getBondingState', {'address': address});
  }

  @override
  Stream<int> getBondingStateStream(String address) {
    return stateEventChannel.receiveBroadcastStream({'address': address}).cast<int>();
  }

  @override
  Future<bool> isPaired(String address) async {
    try {
      var pairedDevices = await methodChannel.invokeMethod('getPairedDevices');
      print("pairedDevices: $pairedDevices");
      for (String pairedDevice in pairedDevices) {
        if (pairedDevice == address) {
          return true;
        }
      }
    } on PlatformException catch (e) {
      print('PlatformException: ${e.code} ${e.message}');
    }
    return false;
  }

}
