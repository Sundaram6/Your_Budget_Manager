// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encryption_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(encryptionService)
final encryptionServiceProvider = EncryptionServiceFamily._();

final class EncryptionServiceProvider
    extends
        $FunctionalProvider<
          EncryptionService,
          EncryptionService,
          EncryptionService
        >
    with $Provider<EncryptionService> {
  EncryptionServiceProvider._({
    required EncryptionServiceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'encryptionServiceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$encryptionServiceHash();

  @override
  String toString() {
    return r'encryptionServiceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<EncryptionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EncryptionService create(Ref ref) {
    final argument = this.argument as String;
    return encryptionService(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EncryptionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EncryptionService>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EncryptionServiceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$encryptionServiceHash() => r'a3088e31eb8fb5141c69659f02a3ebf2915a67a1';

final class EncryptionServiceFamily extends $Family
    with $FunctionalFamilyOverride<EncryptionService, String> {
  EncryptionServiceFamily._()
    : super(
        retry: null,
        name: r'encryptionServiceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EncryptionServiceProvider call(String base64Key) =>
      EncryptionServiceProvider._(argument: base64Key, from: this);

  @override
  String toString() => r'encryptionServiceProvider';
}
