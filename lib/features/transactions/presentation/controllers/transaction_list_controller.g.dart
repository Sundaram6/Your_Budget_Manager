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
    r'73014716a6deb747152f5b6afda37e5833193171';

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
