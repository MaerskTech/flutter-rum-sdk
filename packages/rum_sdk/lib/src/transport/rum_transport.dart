import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:rum_sdk/src/transport/rum_base_transport.dart';
import 'package:rum_sdk/src/transport/task_buffer.dart';
import 'package:rum_sdk/src/models/payload.dart';


class RUMTransport extends BaseTransport {
  final String collectorUrl;
  final String apiKey;
  TaskBuffer<dynamic>? _taskBuffer;
  RUMTransport({required this.collectorUrl, required this.apiKey, maxBufferLimit = 30 }) {
    _taskBuffer = TaskBuffer(maxBufferLimit);
  }

  @override
  Future<void> send(Payload payload) async {
    final headers = {'Content-Type': 'application/json', 'x-api-key': apiKey};
    final response = await _taskBuffer?.add((){
       return http.post(
         Uri.parse(collectorUrl),
         headers: headers,
         body: jsonEncode(payload.toJson()),
       );
    });
    if (response!= null && response?.statusCode ~/ 100 != 2) {
          log("Error sending payload: ${response?.statusCode}");
    }
  }

}
