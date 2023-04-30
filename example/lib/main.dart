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
  final _bleBondingPlugin = BleBonding();

  @override
  void initState() {
    super.initState();
  }

  Future<void> bond() async {
    var address = 'E2:92:8E:ED:7C:7E';
    var done = false;

    Future.microtask(() async {
      final bondingFuture = _bleBondingPlugin.bond(address);

      Future.microtask(() async {
        await for (final state
            in _bleBondingPlugin.getBondingStateStream(address)) {
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

      if (state == BleBondingState.none) {
        debugPrint('NONE, in loop.');
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
          child: ElevatedButton(
            onPressed: bond,
            child: const Text('Bond'),
          ),
        ),
      ),
    );
  }
}
