import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricEncrypt {
  final AndroidOptions _aopt = AndroidOptions(encryptedSharedPreferences: true);
  final FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> supportBiometric() {
    return _auth.canCheckBiometrics;
  }

  Future<bool> isStored(String key) async {
    String? result = await _storage.read(key: key, aOptions: _aopt);
    try {
      return result!.isNotEmpty;
    } catch (e) {
      return Future<bool>.value(false);
    }
  }

  Future<String?> read(String key, String userMsg) async {
    bool didAuthenticate =
        await _auth.authenticate(localizedReason: userMsg, biometricOnly: true);
    if (didAuthenticate) {
      return _storage.read(key: key, aOptions: _aopt);
    } else {
      return null;
    }
  }

  Future<void> write(String key, String val, String userMsg) async {
    bool didAuthenticate =
        await _auth.authenticate(localizedReason: userMsg, biometricOnly: true);
    if (didAuthenticate) {
      return _storage.write(key: key, value: val, aOptions: _aopt);
    } else {
      // print("?");
      throw PlatformException(code: "No authenticate");
    }
  }

  Future<void> delete(String key) async {
    return _storage.delete(key: key);
  }
}
