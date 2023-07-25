import 'package:ble_bonding/ble_bonding.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ble_bonding_method_channel.dart';

abstract class BleBondingPlatform extends PlatformInterface {
  /// Constructs a BleBondingPlatform.
  BleBondingPlatform() : super(token: _token);

  static final Object _token = Object();

  static BleBondingPlatform _instance = MethodChannelBleBonding();

  /// The default instance of [BleBondingPlatform] to use.
  ///
  /// Defaults to [MethodChannelBleBonding].
  static BleBondingPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BleBondingPlatform] when
  /// they register themselves.
  static set instance(BleBondingPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> bond(String address) async {
    throw UnimplementedError('bond() has not been implemented.');
  }

  Future<void> unbound(String address) async {
    throw UnimplementedError('unbound() has not been implemented.');
  }

  Future<int?> getBondingState(String address) async {
    throw UnimplementedError('getBondingState() has not been implemented.');
  }

  Stream<int> getBondingStateStream(String address) {
    throw UnimplementedError('getBondingStateStream() has not been implemented.');
  }
}
