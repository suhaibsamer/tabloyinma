import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/book.dart';

class LibraryService {
  static final LibraryService _instance = LibraryService._internal();
  factory LibraryService() => _instance;
  LibraryService._internal();

  final Dio _dio = Dio();

  Future<Directory> _getLibraryDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final libraryDir = Directory(p.join(docs.path, 'library'));
    if (!await libraryDir.exists()) {
      await libraryDir.create(recursive: true);
    }
    return libraryDir;
  }

  Future<String> getBookPath(String bookId) async {
    final libraryDir = await _getLibraryDir();
    return p.join(libraryDir.path, '$bookId.pdf');
  }

  Future<bool> isBookDownloaded(String bookId) async {
    final path = await getBookPath(bookId);
    return File(path).existsSync();
  }

  Future<void> downloadBook(Book book, ProgressCallback onProgress) async {
    final savePath = await getBookPath(book.id);
    await _dio.download(
      book.downloadUrl,
      savePath,
      onReceiveProgress: onProgress,
    );
  }

  Future<void> deleteBook(String bookId) async {
    final path = await getBookPath(bookId);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

