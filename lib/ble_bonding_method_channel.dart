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
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> bond(String address) {
    return methodChannel.invokeMethod<void>('bond', {'address': address});
  }

  @override
  Future<int?> getBondingState(String address) {
    return methodChannel.invokeMethod<int>('getBondingState', {'address': address});
  }
}
