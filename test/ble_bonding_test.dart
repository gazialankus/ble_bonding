import 'package:flutter_test/flutter_test.dart';
import 'package:ble_bonding/ble_bonding.dart';
import 'package:ble_bonding/ble_bonding_platform_interface.dart';
import 'package:ble_bonding/ble_bonding_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBleBondingPlatform
    with MockPlatformInterfaceMixin
    implements BleBondingPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BleBondingPlatform initialPlatform = BleBondingPlatform.instance;

  test('$MethodChannelBleBonding is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBleBonding>());
  });

  test('getPlatformVersion', () async {
    BleBonding bleBondingPlugin = BleBonding();
    MockBleBondingPlatform fakePlatform = MockBleBondingPlatform();
    BleBondingPlatform.instance = fakePlatform;

    expect(await bleBondingPlugin.getPlatformVersion(), '42');
  });
}
