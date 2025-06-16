import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/updates/update.dart';
import 'package:tejory/updates/update_progress.dart';
import 'package:http/http.dart' as http;

class UpdateAssets extends Update {
  Isolate? _isolate;
  final _receivePort = ReceivePort();
  late SendPort _sendPort;

  @override
  String name() {
    return "Update assets";
  }

  @override
  Future<bool> required() async {
    var URL = Uri.parse(
      "https://raw.githubusercontent.com/integrityph/tejory-app/refs/heads/main/assets/coindata.json",
    );
    http.Response response;

    try {
      response = await http.head(URL).timeout(Duration(seconds: 2));
    } catch (e) {
      print("UpdateAssets: HEAD request error. ${e.toString()}");
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final etag = prefs.getString('coinddata.json-etag') ?? '';

    if (response.headers["etag"] != etag) {
      print("UpdateAssets: etag not matching");
      return true;
    }
    print("UpdateAssets: etag is matching");
    return false;
  }

  @override
  Future<void> start() async {
    status = UpdateStatus.working;
    // Listen for messages from the isolate
    _receivePort.listen((message) {
      print("UpdateAssets: message from isolate ${message}");
      if (message is UpdateProgress) {
        streamController.add(message);

        if (message.done) {
          stop();
          status =
              (message.ex == null)
                  ? UpdateStatus.successful
                  : UpdateStatus.error;
        }
      } else if (message is SendPort) {
        _sendPort = message;
        final RootIsolateToken? rootIsolateToken = RootIsolateToken.instance;
        Map<String, dynamic> msg = {
          "token": rootIsolateToken,
          "box": Singleton.getObjectBoxDB().getStore().reference,
        };
        _sendPort.send(msg);
      } else {
        print(
          "UpdateAssets: ERROR: unknown message type ${message.runtimeType}. ${message}",
        );
      }
    });

    // Spawn the new isolate
    _isolate = await Isolate.spawn(
      worker,
      _receivePort.sendPort,
      onError: _receivePort.sendPort,
      onExit: _receivePort.sendPort,
    );
  }

  static void worker(SendPort sendPort) {
    print("UpdateAssets: isolate stared");
    final _receivePort = ReceivePort();
    sendPort.send(_receivePort.sendPort);
    print("UpdateAssets: isolate port sent");

    _receivePort.listen((message) async {
      try {
        print("UpdateAssets: isolate received message ${message}");

        sendPort.send(
          UpdateProgress(
            0.05,
            done: false,
            message: "UpdateAssets: downloading assets file",
            ex: null,
          ),
        );

        var URL = Uri.parse(
          "https://raw.githubusercontent.com/integrityph/tejory-app/refs/heads/main/assets/coindata.json",
        );
        http.Response response;

        try {
          response = await http.get(URL).timeout(Duration(seconds: 5));
        } catch (e) {
          sendPort.send(
            UpdateProgress(
              0.05,
              done: true,
              message: "UpdateAssets: failed to download assets file",
              ex: e as Exception,
            ),
          );
          return;
        }

        sendPort.send(
          UpdateProgress(
            0.5,
            done: false,
            message: "UpdateAssets: download assets file completed",
            ex: null,
          ),
        );

        BackgroundIsolateBinaryMessenger.ensureInitialized(message["token"]);
        final dir = await getApplicationDocumentsDirectory();
        final localPath = '${dir.path}/assets/coindata.json';
        final file = File(localPath);
        await file.parent.create(recursive: true);
        await file.writeAsBytes(response.bodyBytes);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('coinddata.json-etag', response.headers["etag"]??'');

        sendPort.send(
          UpdateProgress(
            1.0,
            done: true,
            message: "UpdateAssets: asset file updated",
            ex: null,
          ),
        );
      } catch (e) {
        sendPort.send(
          UpdateProgress(
            1.0,
            done: true,
            message: "UpdateAssets: Error. ${e.toString()}",
            ex: Exception(e.toString()),
          ),
        );
      }
    });
  }

  void stop() {
    if (_isolate != null) {
      _isolate?.kill(priority: Isolate.immediate);
      _isolate = null;
      _receivePort.close();
      streamController.close(); // Close the stream controller
      doneCompleter.complete();
      print("UpdateAssets: Isolate stopped.");
    }
  }

  @override
  UpdateStatus getStatus() {
    return status;
  }
}