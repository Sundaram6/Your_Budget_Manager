// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merchant_engine_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(merchantEngine)
final merchantEngineProvider = MerchantEngineProvider._();

final class MerchantEngineProvider
    extends $FunctionalProvider<MerchantEngine, MerchantEngine, MerchantEngine>
    with $Provider<MerchantEngine> {
  MerchantEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'merchantEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$merchantEngineHash();

  @$internal
  @override
  $ProviderElement<MerchantEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MerchantEngine create(Ref ref) {
    return merchantEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MerchantEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MerchantEngine>(value),
    );
  }
}

String _$merchantEngineHash() => r'2f799ebcef6d3f5a26d7db96fffd63dd3e264691';
