// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TransactionListController)
final transactionListControllerProvider = TransactionListControllerProvider._();

final class TransactionListControllerProvider
    extends
        $AsyncNotifierProvider<
          TransactionListController,
          TransactionListState
        > {
  TransactionListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionListControllerHash();

  @$internal
  @override
  TransactionListController create() => TransactionListController();
}

String _$transactionListControllerHash() =>
    r'6038e8503f209935938e5f4f1a009965e1a5cf3b';

abstract class _$TransactionListController
    extends $AsyncNotifier<TransactionListState> {
  FutureOr<TransactionListState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<TransactionListState>, TransactionListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<TransactionListState>,
                TransactionListState
              >,
              AsyncValue<TransactionListState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
