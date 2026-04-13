import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quran_verse.dart';
import 'quran_service.dart';

class QuranAudioService extends BaseAudioHandler with QueueHandler, SeekHandler, ChangeNotifier {
  static const String _reciterKey = 'quran_audio_reciter_id';
  static const String _downloadedOnlyKey = 'quran_audio_downloaded_only';
  static const String _lastKhatmIndexKey = 'quran_audio_last_khatm_index';

  static final QuranAudioService _instance = QuranAudioService._internal();
  factory QuranAudioService() => _instance;
  
  static QuranAudioService? _handler;
  static QuranAudioService get handler {
    if (_handler == null) {
      throw Exception("QuranAudioService not initialized. Call init() first.");
    }
    return _handler!;
  }

  static Future<void> init() async {
    if (_handler != null) return;
    _handler = await AudioService.init(
      builder: () => QuranAudioService._internal(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.tabloy.iman.quran_audio',
        androidNotificationChannelName: 'Quran Audio Playback',
        androidNotificationOngoing: true,
      ),
    );
    await _handler!._loadSettings();
  }

  QuranAudioService._internal() {
    playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      processingState: AudioProcessingState.idle,
      playing: false,
    ));

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _handleVerseCompletion();
      }
      
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (_player.playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _currentIndex,
      ));
      
      notifyListeners();
    });
  }

  final AudioPlayer _player = AudioPlayer();
  final Dio _dio = Dio();
  
  bool _downloadedOnly = false;
  String _reciterId = "Alafasy_128kbps";
  
  List<QuranVerse> _playlist = [];
  int _currentIndex = -1;
  QuranVerse? _currentVerse;

  // Hifz Features
  int _repeatCount = 1; // 1 means play once
  int _currentRepeat = 0;
  Duration _gapDuration = Duration.zero;
  bool _isSmartGap = false;
  double _playbackSpeed = 1.0;
  int _rangeStartIdx = -1;
  int _rangeEndIdx = -1;
  bool _isHifzMode = false;

  AudioPlayer get player => _player;
  bool get downloadedOnly => _downloadedOnly;
  QuranVerse? get currentVerse => _currentVerse;
  int get currentIndex => _currentIndex;
  String get reciterId => _reciterId;
  
  int get repeatCount => _repeatCount;
  int get currentRepeat => _currentRepeat;
  Duration get gapDuration => _gapDuration;
  bool get isSmartGap => _isSmartGap;
  double get playbackSpeed => _playbackSpeed;
  bool get isHifzMode => _isHifzMode;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _reciterId = prefs.getString(_reciterKey) ?? "Alafasy_128kbps";
    _downloadedOnly = prefs.getBool(_downloadedOnlyKey) ?? false;
    _playbackSpeed = prefs.getDouble('quran_audio_speed') ?? 1.0;
    _player.setSpeed(_playbackSpeed);
    notifyListeners();
  }

  Future<void> setDownloadedOnly(bool value) async {
    _downloadedOnly = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_downloadedOnlyKey, value);
    notifyListeners();
  }

  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed;
    await _player.setSpeed(speed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('quran_audio_speed', speed);
    notifyListeners();
  }

  Future<void> setReciter(String reciterId) async {
    _reciterId = reciterId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reciterKey, reciterId);
    notifyListeners();
    if (_player.playing && _currentVerse != null) {
      await _playCurrent();
    }
  }

  // Hifz Setters
  void setHifzMode(bool enabled) {
    _isHifzMode = enabled;
    notifyListeners();
  }

  void setRepeatCount(int count) {
    _repeatCount = count;
    _currentRepeat = 0;
    notifyListeners();
  }

  void setGapDuration(Duration duration) {
    _gapDuration = duration;
    _isSmartGap = false;
    notifyListeners();
  }

  void setSmartGap(bool enabled) {
    _isSmartGap = enabled;
    notifyListeners();
  }

  void setRange(int start, int end) {
    _rangeStartIdx = start;
    _rangeEndIdx = end;
    notifyListeners();
  }

  Future<void> playHifzRange(List<QuranVerse> verses, int start, int end) async {
    _isHifzMode = true;
    _playlist = verses;
    _rangeStartIdx = start;
    _rangeEndIdx = end;
    _currentIndex = start;
    _currentRepeat = 0;
    await _playCurrent();
  }

  String _formatUrl(int chapter, int verse) {
    final chapterStr = chapter.toString().padLeft(3, '0');
    final verseStr = verse.toString().padLeft(3, '0');
    return "https://www.everyayah.com/data/$_reciterId/$chapterStr$verseStr.mp3";
  }

  Future<String> _getLocalPath(int chapter, int verse) async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/quran_audio/$_reciterId/${chapter.toString().padLeft(3, '0')}/${verse.toString().padLeft(3, '0')}.mp3";
  }

  Future<bool> isDownloaded(int chapter, int verse) async {
    final path = await _getLocalPath(chapter, verse);
    return File(path).exists();
  }

  Future<void> playPlaylist(List<QuranVerse> verses, int startIndex) async {
    _playlist = verses;
    _currentIndex = startIndex;
    _currentRepeat = 0;
    await _playCurrent();
  }

  Future<void> resumeKhatm() async {
    final prefs = await SharedPreferences.getInstance();
    int lastIndex = prefs.getInt(_lastKhatmIndexKey) ?? 0;
    
    final quranService = QuranService();
    await quranService.loadQuranData();
    _playlist = quranService.flattenedVerses;
    _currentIndex = lastIndex;
    _isHifzMode = false;
    _currentRepeat = 0;
    await _playCurrent();
  }

  Future<void> _playCurrent() async {
    if (_currentIndex < 0 || _currentIndex >= _playlist.length) {
      _currentVerse = null;
      notifyListeners();
      return;
    }

    _currentVerse = _playlist[_currentIndex];
    notifyListeners();
    
    // Save Khatm progress if not in Hifz mode
    if (!_isHifzMode) {
      final prefs = await SharedPreferences.getInstance();
      // We need global index. If _playlist is the full Quran, _currentIndex is global index.
      // If not, we might need a better way to find the global index.
      // Assuming for Khatm we always use full Quran playlist.
      if (_playlist.length > 6000) {
        await prefs.setInt(_lastKhatmIndexKey, _currentIndex);
      }
    }

    final verse = _currentVerse!;
    mediaItem.add(MediaItem(
      id: '${verse.chapter}_${verse.verse}',
      album: 'القرآن الكريم',
      title: 'ئایەتی ${verse.verse}',
      artist: _reciterId,
    ));

    final localPath = await _getLocalPath(verse.chapter, verse.verse);
    final file = File(localPath);

    try {
      if (await file.exists()) {
        await _player.setFilePath(localPath);
      } else {
        if (_downloadedOnly) {
          await stop();
          throw Exception("Verse not downloaded and 'Downloaded Only' mode is active.");
        }

        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          await stop();
          throw Exception("No internet connection and verse is not downloaded.");
        }

        final url = _formatUrl(verse.chapter, verse.verse);
        await _player.setUrl(url);
      }
      await _player.play();
    } catch (e) {
      _currentVerse = null;
      notifyListeners();
      rethrow;
    }
  }

  void _handleVerseCompletion() async {
    if (_isHifzMode) {
      final currentAyahDuration = _player.duration ?? Duration.zero;
      final actualGap = _isSmartGap ? currentAyahDuration : _gapDuration;

      _currentRepeat++;
      if (_repeatCount == -1 || _currentRepeat < _repeatCount) {
        // Repeat the same verse
        if (actualGap > Duration.zero) {
          await Future.delayed(actualGap);
        }
        if (_player.processingState != ProcessingState.idle && _currentVerse != null) {
          await _playCurrent();
        }
      } else {
        // Move to next verse in range
        _currentRepeat = 0;
        if (_currentIndex < _rangeEndIdx && _currentIndex + 1 < _playlist.length) {
          _currentIndex++;
          if (actualGap > Duration.zero) {
            await Future.delayed(actualGap);
          }
          if (_player.processingState != ProcessingState.idle && _currentVerse != null) {
            await _playCurrent();
          }
        } else if (_currentIndex == _rangeEndIdx) {
          // Range finished, loop the entire range
          _currentIndex = _rangeStartIdx;
          if (actualGap > Duration.zero) {
            await Future.delayed(actualGap);
          }
          if (_player.processingState != ProcessingState.idle && _currentVerse != null) {
            await _playCurrent();
          }
        } else {
          stop();
        }
      }
    } else {
      _playNext();
    }
  }

  void _playNext() {
    if (_currentIndex + 1 < _playlist.length) {
      _currentIndex++;
      _playCurrent().catchError((e) {
        stop();
      });
    } else {
      stop();
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    _currentVerse = null;
    mediaItem.add(null);
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
    notifyListeners();
  }

  @override
  Future<void> skipToNext() async {
    if (_isHifzMode) {
      if (_currentIndex < _rangeEndIdx && _currentIndex + 1 < _playlist.length) {
        _currentIndex++;
        _currentRepeat = 0;
        await _playCurrent();
      }
    } else {
      _playNext();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_isHifzMode) {
      if (_currentIndex > _rangeStartIdx) {
        _currentIndex--;
        _currentRepeat = 0;
        await _playCurrent();
      }
    } else {
      if (_currentIndex > 0) {
        _currentIndex--;
        await _playCurrent();
      }
    }
  }

  Future<void> downloadVerse(int chapter, int verse, {Function(double)? onProgress}) async {
    final localPath = await _getLocalPath(chapter, verse);
    final file = File(localPath);
    if (await file.exists()) return;
    await file.parent.create(recursive: true);
    final url = _formatUrl(chapter, verse);
    await _dio.download(
      url,
      localPath,
      onReceiveProgress: (received, total) {
        if (total != -1 && onProgress != null) {
          onProgress(received / total);
        }
      },
    );
    notifyListeners();
  }

  Future<void> downloadChapter(int chapter, List<QuranVerse> verses, {Function(int, int)? onProgress}) async {
    int downloadedCount = 0;
    for (var verse in verses) {
      await downloadVerse(chapter, verse.verse);
      downloadedCount++;
      if (onProgress != null) {
        onProgress(downloadedCount, verses.length);
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

