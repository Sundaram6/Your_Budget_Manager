// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_engine_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(analyticsEngine)
final analyticsEngineProvider = AnalyticsEngineProvider._();

final class AnalyticsEngineProvider
    extends
        $FunctionalProvider<AnalyticsEngine, AnalyticsEngine, AnalyticsEngine>
    with $Provider<AnalyticsEngine> {
  AnalyticsEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsEngineHash();

  @$internal
  @override
  $ProviderElement<AnalyticsEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnalyticsEngine create(Ref ref) {
    return analyticsEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalyticsEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalyticsEngine>(value),
    );
  }
}

String _$analyticsEngineHash() => r'25bf5612d4be3ebd0c47b4a8ce83f31f2c5062f1';
