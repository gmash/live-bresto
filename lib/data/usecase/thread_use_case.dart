// ignore_for_file: prefer-match-file-name

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_bresto/data/definitions/app_mode.dart';
import 'package:live_bresto/data/service/database_service.dart';

final currentThreadProvider = StreamProvider((ref) {
  return ref.watch(threadProvider(AppMode.threadIdForDebug).stream);
});