// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intelligence_engine_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(intelligenceEngine)
final intelligenceEngineProvider = IntelligenceEngineProvider._();

final class IntelligenceEngineProvider
    extends
        $FunctionalProvider<
          IntelligenceEngine,
          IntelligenceEngine,
          IntelligenceEngine
        >
    with $Provider<IntelligenceEngine> {
  IntelligenceEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'intelligenceEngineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$intelligenceEngineHash();

  @$internal
  @override
  $ProviderElement<IntelligenceEngine> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IntelligenceEngine create(Ref ref) {
    return intelligenceEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IntelligenceEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IntelligenceEngine>(value),
    );
  }
}

String _$intelligenceEngineHash() =>
    r'49eaadffbb4d3d6fa2cc5a8126573a3d87dd5875';
