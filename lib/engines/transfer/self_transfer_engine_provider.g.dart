// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'self_transfer_engine_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(selfTransferEngine)
final selfTransferEngineProvider = SelfTransferEngineProvider._();

final class SelfTransferEngineProvider
    extends
        $FunctionalProvider<
          SelfTransferEngine,
          SelfTransferEngine,
          SelfTransferEngine
        >
    with $Provider<SelfTransferEngine> {
  SelfTransferEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selfTransferEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selfTransferEngineHash();

  @$internal
  @override
  $ProviderElement<SelfTransferEngine> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SelfTransferEngine create(Ref ref) {
    return selfTransferEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SelfTransferEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SelfTransferEngine>(value),
    );
  }
}

String _$selfTransferEngineHash() =>
    r'b94d58ee529c6734899a636757f40dcc6f1f8fb0';

@ProviderFor(TransferSuggestionsNotifier)
final transferSuggestionsProvider = TransferSuggestionsNotifierProvider._();

final class TransferSuggestionsNotifierProvider
    extends
        $NotifierProvider<
          TransferSuggestionsNotifier,
          List<TransferSuggestion>
        > {
  TransferSuggestionsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transferSuggestionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transferSuggestionsNotifierHash();

  @$internal
  @override
  TransferSuggestionsNotifier create() => TransferSuggestionsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TransferSuggestion> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TransferSuggestion>>(value),
    );
  }
}

String _$transferSuggestionsNotifierHash() =>
    r'1493ce276757480e830c688d6f9187cbae3b03cc';

abstract class _$TransferSuggestionsNotifier
    extends $Notifier<List<TransferSuggestion>> {
  List<TransferSuggestion> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<List<TransferSuggestion>, List<TransferSuggestion>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<TransferSuggestion>, List<TransferSuggestion>>,
              List<TransferSuggestion>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
