import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ble_bonding/ble_bonding.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _bleBondingPlugin = BleBonding();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _bleBondingPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });

    var address = '';
    var done = false;

    Future.microtask(() async {
      final bondingFuture = _bleBondingPlugin.bond(address);

      Future.microtask(() async {
        await for (final state in _bleBondingPlugin.bondingStateStream) {
          debugPrint('State is $state, from stream.');
          if (state == BleBondingState.bonded) break;
        }
        debugPrint('BONDED, in stream.');
      });

      await bondingFuture;
      debugPrint('BONDED, after await.');
    });


    while (!done) {
      final state = await _bleBondingPlugin.getBondingState(address);
      debugPrint('State is $state, in loop.');

      if (state == BleBondingState.bonded) {
        debugPrint('BONDED, in loop.');
        break;
      }

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
