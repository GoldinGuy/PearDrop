import 'package:flutter/foundation.dart' show required, kDebugMode;
import 'package:peardrop/src/utilities/version_const.dart';
import 'package:sentry/sentry.dart';

final SentryClient _sentry = SentryClient(
    dsn:
        'https://b31defa9fb8d46ae9f8c966578f4053f@o421971.ingest.sentry.io/5342559');

Future<SentryResponse> reportBlocException({
  @required dynamic exception,
  @required dynamic stackTrace,
  Map<String, String> tags,
}) {
  return reportException(
    exception: exception,
    stackTrace: stackTrace,
  );
}

Future<SentryResponse> reportException({
  @required dynamic exception,
  @required dynamic stackTrace,
  Map<String, String> tags,
}) {
  if (!kDebugMode) {
    print(exception);
    if (stackTrace != null) {
      print(stackTrace);
    }

    try {
      final event = Event(
        exception: exception,
        stackTrace: stackTrace,
        release: VERSION_STRING,
        tags: tags,
      );
      return _sentry.capture(event: event);
    } catch (e) {
      print('Sending report to sentry.io failed: $e');
    }
  } else {
    print('Error not reported to sentry (debug mode)');
    print(exception);
    if (stackTrace != null) {
      print(stackTrace);
    }
  }

  return null;
}
