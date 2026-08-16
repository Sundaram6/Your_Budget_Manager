// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_transactions_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PendingTransactionsController)
final pendingTransactionsControllerProvider =
    PendingTransactionsControllerProvider._();

final class PendingTransactionsControllerProvider
    extends
        $NotifierProvider<
          PendingTransactionsController,
          PendingTransactionsState
        > {
  PendingTransactionsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingTransactionsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingTransactionsControllerHash();

  @$internal
  @override
  PendingTransactionsController create() => PendingTransactionsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PendingTransactionsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PendingTransactionsState>(value),
    );
  }
}

String _$pendingTransactionsControllerHash() =>
    r'e920eac197fe3c1244871359ae9b7ea351a7da9d';

abstract class _$PendingTransactionsController
    extends $Notifier<PendingTransactionsState> {
  PendingTransactionsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<PendingTransactionsState, PendingTransactionsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PendingTransactionsState, PendingTransactionsState>,
              PendingTransactionsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
