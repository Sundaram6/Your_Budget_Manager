// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encryption_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$encryptionServiceHash() => r'b4fee1b14c9fad6d6a017f5051b200b5e954f93a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [encryptionService].
@ProviderFor(encryptionService)
const encryptionServiceProvider = EncryptionServiceFamily();

/// See also [encryptionService].
class EncryptionServiceFamily extends Family<EncryptionService> {
  /// See also [encryptionService].
  const EncryptionServiceFamily();

  /// See also [encryptionService].
  EncryptionServiceProvider call(String base64Key) {
    return EncryptionServiceProvider(base64Key);
  }

  @override
  EncryptionServiceProvider getProviderOverride(
    covariant EncryptionServiceProvider provider,
  ) {
    return call(provider.base64Key);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'encryptionServiceProvider';
}

/// See also [encryptionService].
class EncryptionServiceProvider extends AutoDisposeProvider<EncryptionService> {
  /// See also [encryptionService].
  EncryptionServiceProvider(String base64Key)
    : this._internal(
        (ref) => encryptionService(ref as EncryptionServiceRef, base64Key),
        from: encryptionServiceProvider,
        name: r'encryptionServiceProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$encryptionServiceHash,
        dependencies: EncryptionServiceFamily._dependencies,
        allTransitiveDependencies:
            EncryptionServiceFamily._allTransitiveDependencies,
        base64Key: base64Key,
      );

  EncryptionServiceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.base64Key,
  }) : super.internal();

  final String base64Key;

  @override
  Override overrideWith(
    EncryptionService Function(EncryptionServiceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EncryptionServiceProvider._internal(
        (ref) => create(ref as EncryptionServiceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        base64Key: base64Key,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<EncryptionService> createElement() {
    return _EncryptionServiceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EncryptionServiceProvider && other.base64Key == base64Key;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, base64Key.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EncryptionServiceRef on AutoDisposeProviderRef<EncryptionService> {
  /// The parameter `base64Key` of this provider.
  String get base64Key;
}

class _EncryptionServiceProviderElement
    extends AutoDisposeProviderElement<EncryptionService>
    with EncryptionServiceRef {
  _EncryptionServiceProviderElement(super.provider);

  @override
  String get base64Key => (origin as EncryptionServiceProvider).base64Key;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
