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

String _$analyticsEngineHash() => r'6c4cd86d75a9906058e781f3337d24a7df2c740a';
