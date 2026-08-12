// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_engine_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(savingsEngine)
final savingsEngineProvider = SavingsEngineProvider._();

final class SavingsEngineProvider
    extends $FunctionalProvider<SavingsEngine, SavingsEngine, SavingsEngine>
    with $Provider<SavingsEngine> {
  SavingsEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savingsEngineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savingsEngineHash();

  @$internal
  @override
  $ProviderElement<SavingsEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SavingsEngine create(Ref ref) {
    return savingsEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavingsEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavingsEngine>(value),
    );
  }
}

String _$savingsEngineHash() => r'f0e2622ccabb49ffd91702bae5d82b59b51bcabc';

@ProviderFor(savingsGoalsEngine)
final savingsGoalsEngineProvider = SavingsGoalsEngineProvider._();

final class SavingsGoalsEngineProvider
    extends $FunctionalProvider<SavingsEngine, SavingsEngine, SavingsEngine>
    with $Provider<SavingsEngine> {
  SavingsGoalsEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savingsGoalsEngineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savingsGoalsEngineHash();

  @$internal
  @override
  $ProviderElement<SavingsEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SavingsEngine create(Ref ref) {
    return savingsGoalsEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavingsEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavingsEngine>(value),
    );
  }
}

String _$savingsGoalsEngineHash() =>
    r'435e380ea61716ee22ee8ec5fb82b3a3392165bc';
