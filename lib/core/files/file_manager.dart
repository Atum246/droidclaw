import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

/// 📁 File Manager — Upload, download, share, manage files
class FileManager extends ChangeNotifier {
  static final FileManager I = FileManager._();
  FileManager._();

  final List<ManagedFile> _files = [];
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> init() async {
    // Load saved files from disk if needed
  }

  List<ManagedFile> get files => _files;
  List<ManagedFile> get downloads => _files.where((f) => f.type == FileType.download).toList();
  List<ManagedFile> get uploads => _files.where((f) => f.type == FileType.upload).toList();
  List<ManagedFile> get images => _files.where((f) => f.mimeType.startsWith('image/')).toList();
  List<ManagedFile> get videos => _files.where((f) => f.mimeType.startsWith('video/')).toList();

  /// Pick file from device
  Future<ManagedFile?> pickFile({List<String>? allowedExtensions}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final managed = ManagedFile(
          id: 'file_${DateTime.now().millisecondsSinceEpoch}',
          name: file.name,
          path: file.path ?? '',
          size: file.size,
          mimeType: _getMimeType(file.name),
          type: FileType.upload,
          createdAt: DateTime.now(),
        );
        _files.add(managed);
        notifyListeners();
        return managed;
      }
    } catch (e) {
      debugPrint('File pick error: $e');
    }
    return null;
  }

  /// Pick image from gallery or camera
  Future<ManagedFile?> pickImage({bool fromCamera = false}) async {
    try {
      final XFile? image = fromCamera
          ? await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 85)
          : await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (image != null) {
        final managed = ManagedFile(
          id: 'img_${DateTime.now().millisecondsSinceEpoch}',
          name: image.name,
          path: image.path,
          size: await File(image.path).length(),
          mimeType: 'image/jpeg',
          type: FileType.upload,
          createdAt: DateTime.now(),
        );
        _files.add(managed);
        notifyListeners();
        return managed;
      }
    } catch (e) {
      debugPrint('Image pick error: $e');
    }
    return null;
  }

  /// Pick video
  Future<ManagedFile?> pickVideo({bool fromCamera = false}) async {
    try {
      final XFile? video = fromCamera
          ? await _imagePicker.pickVideo(source: ImageSource.camera)
          : await _imagePicker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        final managed = ManagedFile(
          id: 'vid_${DateTime.now().millisecondsSinceEpoch}',
          name: video.name,
          path: video.path,
          size: await File(video.path).length(),
          mimeType: 'video/mp4',
          type: FileType.upload,
          createdAt: DateTime.now(),
        );
        _files.add(managed);
        notifyListeners();
        return managed;
      }
    } catch (e) {
      debugPrint('Video pick error: $e');
    }
    return null;
  }

  /// Save text content as file and offer download/share
  Future<ManagedFile> saveAndShare({
    required String content,
    required String fileName,
    String mimeType = 'text/plain',
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content);

    final managed = ManagedFile(
      id: 'dl_${DateTime.now().millisecondsSinceEpoch}',
      name: fileName,
      path: file.path,
      size: await file.length(),
      mimeType: mimeType,
      type: FileType.download,
      createdAt: DateTime.now(),
    );
    _files.add(managed);
    notifyListeners();

    // Offer to share
    await Share.shareXFiles([XFile(file.path)], subject: fileName);
    return managed;
  }

  /// Save bytes as file
  Future<ManagedFile> saveBytes({
    required List<int> bytes,
    required String fileName,
    String mimeType = 'application/octet-stream',
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    final managed = ManagedFile(
      id: 'dl_${DateTime.now().millisecondsSinceEpoch}',
      name: fileName,
      path: file.path,
      size: bytes.length,
      mimeType: mimeType,
      type: FileType.download,
      createdAt: DateTime.now(),
    );
    _files.add(managed);
    notifyListeners();
    return managed;
  }

  /// Download from URL
  Future<ManagedFile?> downloadFromUrl(String url, {String? fileName}) async {
    try {
      final name = fileName ?? url.split('/').last.split('?').first;
      final request = await HttpClient().getUrl(Uri.parse(url));
      final response = await request.close();
      final bytes = <int>[];
      await for (var chunk in response) {
        bytes.addAll(chunk);
      }
      return await saveBytes(bytes: bytes, fileName: name, mimeType: _getMimeType(name));
    } catch (e) {
      debugPrint('Download error: $e');
      return null;
    }
  }

  /// Share a file
  Future<void> shareFile(ManagedFile file) async {
    await Share.shareXFiles([XFile(file.path)], subject: file.name);
  }

  /// Delete a file
  Future<void> deleteFile(String id) async {
    final file = _files.firstWhere((f) => f.id == id);
    final ioFile = File(file.path);
    if (await ioFile.exists()) await ioFile.delete();
    _files.removeWhere((f) => f.id == id);
    notifyListeners();
  }

  /// Get file as base64 (for sending to AI)
  Future<String> fileToBase64(String path) async {
    final bytes = await File(path).readAsBytes();
    return base64Encode(bytes);
  }

  String _getMimeType(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg': case 'jpeg': return 'image/jpeg';
      case 'png': return 'image/png';
      case 'gif': return 'image/gif';
      case 'webp': return 'image/webp';
      case 'svg': return 'image/svg+xml';
      case 'mp4': return 'video/mp4';
      case 'mov': return 'video/quicktime';
      case 'avi': return 'video/x-msvideo';
      case 'mp3': return 'audio/mpeg';
      case 'wav': return 'audio/wav';
      case 'ogg': return 'audio/ogg';
      case 'pdf': return 'application/pdf';
      case 'doc': case 'docx': return 'application/msword';
      case 'xls': case 'xlsx': return 'application/vnd.ms-excel';
      case 'ppt': case 'pptx': return 'application/vnd.ms-powerpoint';
      case 'zip': return 'application/zip';
      case 'json': return 'application/json';
      case 'xml': return 'application/xml';
      case 'html': return 'text/html';
      case 'css': return 'text/css';
      case 'js': return 'text/javascript';
      case 'py': return 'text/x-python';
      case 'dart': return 'text/x-dart';
      case 'md': return 'text/markdown';
      case 'txt': return 'text/plain';
      case 'csv': return 'text/csv';
      default: return 'application/octet-stream';
    }
  }
}

enum FileType { download, upload, generated }

class ManagedFile {
  final String id;
  final String name;
  final String path;
  final int size;
  final String mimeType;
  final FileType type;
  final DateTime createdAt;

  ManagedFile({
    required this.id, required this.name, required this.path,
    required this.size, required this.mimeType, required this.type,
    required this.createdAt,
  });

  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get icon {
    if (mimeType.startsWith('image/')) return '🖼️';
    if (mimeType.startsWith('video/')) return '🎥';
    if (mimeType.startsWith('audio/')) return '🎵';
    if (mimeType.contains('pdf')) return '📄';
    if (mimeType.contains('word') || mimeType.contains('document')) return '📝';
    if (mimeType.contains('sheet') || mimeType.contains('excel')) return '📊';
    if (mimeType.contains('presentation') || mimeType.contains('powerpoint')) return '📽️';
    if (mimeType.contains('zip') || mimeType.contains('archive')) return '📦';
    if (mimeType.contains('json') || mimeType.contains('xml')) return '📋';
    if (mimeType.contains('html') || mimeType.contains('css') || mimeType.contains('javascript')) return '🌐';
    return '📁';
  }

  bool get isImage => mimeType.startsWith('image/');
  bool get isVideo => mimeType.startsWith('video/');
  bool get isAudio => mimeType.startsWith('audio/');
  bool get isDocument => mimeType.contains('pdf') || mimeType.contains('word') || mimeType.contains('sheet');
}
