import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final int _maxSizeInBytes = 30 * 1024 * 1024;

  Future<String> uploadReceipt(XFile file, String userId) async {
    try {
      final fileSize = await file.length();
      if (fileSize > _maxSizeInBytes) {
        throw Exception('Arquivo muito grande. Limite: 30 MB');
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('receipts/$userId/$fileName');
      final bytes = await file.readAsBytes();

      final uploadTask = await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erro ao fazer upload');
    }
  }

  Future<void> deleteReceipt(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Erro ao deletar arquivo');
    }
  }
}
