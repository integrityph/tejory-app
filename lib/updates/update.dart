import 'dart:async';

import 'package:tejory/updates/update_progress.dart';

enum UpdateStatus { pending, working, successful, error }

abstract class Update {
  final streamController = StreamController<UpdateProgress>.broadcast();
  UpdateStatus status = UpdateStatus.pending;
  Completer doneCompleter = Completer();
  
  String name();
  Stream<UpdateProgress> getProgressStream() {
    return streamController.stream;
  }
  Future<bool> required();
  Future<void> start();
  UpdateStatus getStatus();

  Future<void> done() {
    return doneCompleter.future;
  }
}