// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_engine_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recurringEngine)
final recurringEngineProvider = RecurringEngineProvider._();

final class RecurringEngineProvider
    extends
        $FunctionalProvider<RecurringEngine, RecurringEngine, RecurringEngine>
    with $Provider<RecurringEngine> {
  RecurringEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringEngineHash();

  @$internal
  @override
  $ProviderElement<RecurringEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RecurringEngine create(Ref ref) {
    return recurringEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecurringEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecurringEngine>(value),
    );
  }
}

String _$recurringEngineHash() => r'2c517b7c66d60c0c5b2042d37795fdde25fec962';
