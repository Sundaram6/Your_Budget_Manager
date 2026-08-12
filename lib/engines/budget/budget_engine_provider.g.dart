// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_engine_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(budgetEngine)
final budgetEngineProvider = BudgetEngineProvider._();

final class BudgetEngineProvider
    extends $FunctionalProvider<BudgetEngine, BudgetEngine, BudgetEngine>
    with $Provider<BudgetEngine> {
  BudgetEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetEngineHash();

  @$internal
  @override
  $ProviderElement<BudgetEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BudgetEngine create(Ref ref) {
    return budgetEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetEngine>(value),
    );
  }
}

String _$budgetEngineHash() => r'1afc0d37b8155c68a5de6437b4d3dfd68f8d5cfd';

@ProviderFor(dailyAllowance)
final dailyAllowanceProvider = DailyAllowanceProvider._();

final class DailyAllowanceProvider
    extends
        $FunctionalProvider<
          AsyncValue<DailyAllowance?>,
          DailyAllowance?,
          FutureOr<DailyAllowance?>
        >
    with $FutureModifier<DailyAllowance?>, $FutureProvider<DailyAllowance?> {
  DailyAllowanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailyAllowanceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailyAllowanceHash();

  @$internal
  @override
  $FutureProviderElement<DailyAllowance?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DailyAllowance?> create(Ref ref) {
    return dailyAllowance(ref);
  }
}

String _$dailyAllowanceHash() => r'f804388e2799db05393d6a7cba683ca8ee101869';
