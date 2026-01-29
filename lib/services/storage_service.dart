import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final int _maxSizeInBytes = 30 * 1024 * 1024; // 30 MB

  Future<String> uploadReceipt(File file, String userId) async {
    try {
      // Verificar tamanho do arquivo
      final fileSize = await file.length();
      if (fileSize > _maxSizeInBytes) {
        throw Exception('Arquivo muito grande. Limite: 30 MB');
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('receipts/$userId/$fileName');
      
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Erro ao fazer upload: ${e.toString()}');
    }
  }

  Future<void> deleteReceipt(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Erro ao deletar arquivo: ${e.toString()}');
    }
  }
}
