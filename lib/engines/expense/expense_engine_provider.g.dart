// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_engine_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(expenseEngine)
final expenseEngineProvider = ExpenseEngineProvider._();

final class ExpenseEngineProvider
    extends $FunctionalProvider<ExpenseEngine, ExpenseEngine, ExpenseEngine>
    with $Provider<ExpenseEngine> {
  ExpenseEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseEngineHash();

  @$internal
  @override
  $ProviderElement<ExpenseEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExpenseEngine create(Ref ref) {
    return expenseEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExpenseEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExpenseEngine>(value),
    );
  }
}

String _$expenseEngineHash() => r'77054e1bf3a85e747ae15f2a0fc0cd55d14b9458';
