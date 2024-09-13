import 'dart:async';
import 'package:rum_sdk/rum_sdk.dart';
import 'package:rum_sdk/src/configurations/batch_config.dart';
import 'package:rum_sdk/src/models/models.dart';
import 'package:rum_sdk/src/transport/rum_base_transport.dart';

class BatchTransport {
  int items = 0;
  Payload payload;
  BatchConfig batchConfig;
  List<BaseTransport> transports;
  Timer? flushTimer;
  BatchTransport(
      {required this.payload,
      required this.batchConfig,
      required this.transports}) {
    if (batchConfig.enabled) {
      Timer.periodic(batchConfig.sendTimeout, (Timer t) {
        flushTimer = t;
        flush();
      });
    } else {
      batchConfig.payloadItemLimit = 1;
    }
  }

  Future<void> addEvent(Event event) async {
    payload.events.add(event);
    items++;
    checkPayloadItemLimit();
  }

  Future<void> addMeasurement(Measurement measurement) async {
    payload.measurements.add(measurement);
    items++;
    checkPayloadItemLimit();
  }

  Future<void> addLog(RumLog rumLog) async {
    payload.logs.add(rumLog);
    items++;
    checkPayloadItemLimit();
  }

  Future<void> addExceptions(RumException exception) async {
    payload.exceptions.add(exception);
    items++;
    checkPayloadItemLimit();
  }

  void updatePayloadMeta(Meta meta) {
    flush();
    payload.meta = meta;
  }

  Future<void> flush() async {
    if (isPayloadEmpty()) {
      return;
    }
    if (transports.isNotEmpty) {
      final currentTransports = transports;
      for (var transport in currentTransports) {
        await transport.send(payload);
      }
    }
    resetPayload();
  }

  void checkPayloadItemLimit() {
    if (items >= batchConfig.payloadItemLimit) {
      items = 0;
      flush();
    }
  }

  void dispose() {
    flushTimer?.cancel();
  }

  bool isPayloadEmpty() {
    return (payload.events.isEmpty &&
        payload.measurements.isEmpty &&
        payload.logs.isEmpty &&
        payload.exceptions.isEmpty);
  }

  void resetPayload() {
    payload.events = [];
    payload.measurements = [];
    payload.logs = [];
    payload.exceptions = [];
  }
}
