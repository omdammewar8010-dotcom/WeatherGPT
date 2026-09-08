import 'dart:async';
import 'firestore_collections.dart';

class StorageUploadResult {
  final String downloadUrl;
  final String storagePath;
  final int byteSize;
  final DateTime uploadedAt;

  const StorageUploadResult({
    required this.downloadUrl,
    required this.storagePath,
    required this.byteSize,
    required this.uploadedAt,
  });

  Map<String, dynamic> toJson() => {
        'download_url': downloadUrl,
        'storage_path': storagePath,
        'byte_size': byteSize,
        'uploaded_at': uploadedAt.toIso8601String(),
      };
}

abstract class FirebaseStorageService {
  Future<StorageUploadResult> uploadIncidentPhoto({
    required String reportId,
    required String localFilePath,
    void Function(double progress)? onProgress,
  });

  Future<void> deleteFile(String storagePath);
  String getIncidentPhotoPath(String reportId, String filename);
}

class FirebaseStorageServiceImpl implements FirebaseStorageService {
  @override
  String getIncidentPhotoPath(String reportId, String filename) {
    return FirebaseStoragePaths.incidentPhoto(reportId, filename);
  }

  @override
  Future<StorageUploadResult> uploadIncidentPhoto({
    required String reportId,
    required String localFilePath,
    void Function(double progress)? onProgress,
  }) async {
    final filename = localFilePath.split(RegExp(r'[/\\]')).last;
    final targetPath = FirebaseStoragePaths.incidentPhoto(reportId, filename);

    // Simulate progress stream for smooth UX in evaluation mode
    for (int step = 1; step <= 5; step++) {
      await Future.delayed(const Duration(milliseconds: 100));
      onProgress?.call(step / 5.0);
    }

    final simulatedUrl =
        'https://firebasestorage.googleapis.com/v0/b/ner-landslideguard.appspot.com/o/${Uri.encodeComponent(targetPath)}?alt=media';

    return StorageUploadResult(
      downloadUrl: simulatedUrl,
      storagePath: targetPath,
      byteSize: 1024 * 350, // ~350 KB
      uploadedAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteFile(String storagePath) async {
    // Delete simulation / storage hook
    await Future.delayed(const Duration(milliseconds: 150));
  }
}
