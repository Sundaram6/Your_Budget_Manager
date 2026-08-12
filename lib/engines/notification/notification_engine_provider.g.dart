// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_engine_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationEngine)
final notificationEngineProvider = NotificationEngineProvider._();

final class NotificationEngineProvider
    extends
        $FunctionalProvider<
          NotificationEngine,
          NotificationEngine,
          NotificationEngine
        >
    with $Provider<NotificationEngine> {
  NotificationEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationEngineHash();

  @$internal
  @override
  $ProviderElement<NotificationEngine> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationEngine create(Ref ref) {
    return notificationEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationEngine>(value),
    );
  }
}

String _$notificationEngineHash() =>
    r'd5cf47d45245b6b333628f4dfe2640ebeaebc84e';
