import 'dart:convert';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const _keyStorageKey = 'bytebank_enc_key';
  static const _ivStorageKey = 'bytebank_enc_iv';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  enc.Encrypter? _encrypter;
  enc.IV? _iv;

  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  Future<void> initialize() async {
    String? keyBase64 = await _secureStorage.read(key: _keyStorageKey);
    String? ivBase64 = await _secureStorage.read(key: _ivStorageKey);

    if (keyBase64 == null || ivBase64 == null) {
      final key = enc.Key.fromSecureRandom(32);
      final iv = enc.IV.fromSecureRandom(16);
      keyBase64 = base64.encode(key.bytes);
      ivBase64 = base64.encode(iv.bytes);
      await _secureStorage.write(key: _keyStorageKey, value: keyBase64);
      await _secureStorage.write(key: _ivStorageKey, value: ivBase64);
    }

    final key = enc.Key(base64.decode(keyBase64));
    _iv = enc.IV(base64.decode(ivBase64));
    _encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
  }

  String encrypt(String plainText) {
    if (_encrypter == null || _iv == null) return plainText;
    try {
      return _encrypter!.encrypt(plainText, iv: _iv!).base64;
    } catch (_) {
      return plainText;
    }
  }

  String decrypt(String encryptedText) {
    if (_encrypter == null || _iv == null) return encryptedText;
    try {
      return _encrypter!.decrypt64(encryptedText, iv: _iv!);
    } catch (_) {
      return encryptedText;
    }
  }

  Future<void> writeSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: encrypt(value));
  }

  Future<String?> readSecure(String key) async {
    final value = await _secureStorage.read(key: key);
    if (value == null) return null;
    return decrypt(value);
  }

  Future<void> deleteSecure(String key) async {
    await _secureStorage.delete(key: key);
  }
}
