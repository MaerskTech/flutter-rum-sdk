import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rum_sdk/rum_flutter.dart';
import 'package:rum_sdk/src/models/payload.dart';
import 'package:rum_sdk/src/transport/rum_base_transport.dart';
import 'dart:io';

class OfflineTransport extends BaseTransport {
  bool isOnline = true;
  Duration? _maxCacheDuration;
  OfflineTransport({Duration? maxCacheDuration}) {
    _maxCacheDuration = maxCacheDuration;
    checkConnectivity();
    monitorConnectivity();
  }
  @override
  Future<void> send(Map<String,dynamic> data) async {
    Payload payload = Payload.fromJson(data);
    if (!isOnline) {
      if (isPayloadEmpty(payload)) {
        return;
      }
      await writeToFile(payload);
    }
  }

  Future<void> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.firstOrNull == ConnectivityResult.none) {
      isOnline = false;
    } else {
      isOnline = await _isConnectedToInternet();
      readFromFile();
    }
  }

  Future<void>? monitorConnectivity() {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) async {
      if (result.contains(ConnectivityResult.none)) {
        isOnline = false;
      } else {
        bool isConnected = await _isConnectedToInternet();
        if (isConnected) {
          isOnline = true;
          readFromFile();
        } else {
          isOnline = false;
        }
      }
    });
    return null;
  }

  Future<bool> _isConnectedToInternet() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  bool isPayloadEmpty(Payload payload) {
    return (payload.events.isEmpty &&
        payload.measurements.isEmpty &&
        payload.logs.isEmpty &&
        payload.exceptions.isEmpty);
  }

  Future<void> writeToFile(Payload payload) async {
    final file = await _getCacheFile();
    var logJson = {
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "payload": payload.toJson()
    };
    await file.writeAsString(jsonEncode(logJson) + '\n', mode: FileMode.append);
  }

  Future<void> readFromFile() async {
    final file = await _getCacheFile();
    if (!await file.exists()) {
      return;
    }
    if (await file.length() == 0) {
      return;
    }

    final Stream<String> lines = file
        .openRead()
        .transform(utf8.decoder) // Decode bytes to UTF-8.
        .transform(const LineSplitter()); // Convert stream to individual lines.

    final List<String> remainingLines = [];
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    await for (var line in lines) {
      if (line.trim().isEmpty) continue;

      int? timestamp;
      Payload? payload;
      try {
        final logJson = jsonDecode(line);
        timestamp = logJson["timestamp"];
        payload = Payload.fromJson(logJson["payload"]);
      } catch (error) {
        log('Failed to parse log: $line\nWith error: $error');
      }

      if (timestamp == null || payload == null) {
        continue;
      }

      if (_maxCacheDuration != null &&
          currentTime - timestamp > _maxCacheDuration!.inMilliseconds) {
        continue;
      } else {
        await sendCachedData(payload);
      }
    }

    if (remainingLines.isEmpty) {
      await file.writeAsString('');
    } else {
      await file.writeAsString(remainingLines.join('\n') + '\n');
    }
  }

  Future<File> _getCacheFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final filepath = '${directory.path}/rum_log.json';
    if (!await File(filepath).exists()) {
      return File(filepath).create(recursive: true);
    }
    return File(filepath);
  }

  bool cachedDataExists() {
    return false;
  }

  Future<void> sendCachedData(Payload payload) async {
    for (var transport in RumFlutter().transports) {
      if (this != transport) {
        transport.send(payload.toJson());
      }
    }
  }
}
