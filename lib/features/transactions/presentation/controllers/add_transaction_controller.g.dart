// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_transaction_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddTransactionController)
final addTransactionControllerProvider = AddTransactionControllerProvider._();

final class AddTransactionControllerProvider
    extends $NotifierProvider<AddTransactionController, AddTransactionState> {
  AddTransactionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addTransactionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addTransactionControllerHash();

  @$internal
  @override
  AddTransactionController create() => AddTransactionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddTransactionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddTransactionState>(value),
    );
  }
}

String _$addTransactionControllerHash() =>
    r'659ab0a0e0cba1ec9a2efec880821aaa276c475c';

abstract class _$AddTransactionController
    extends $Notifier<AddTransactionState> {
  AddTransactionState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AddTransactionState, AddTransactionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AddTransactionState, AddTransactionState>,
              AddTransactionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
