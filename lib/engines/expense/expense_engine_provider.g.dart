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

String _$expenseEngineHash() => r'900cf6a7aa11027b7776edfdd62977535a502480';
