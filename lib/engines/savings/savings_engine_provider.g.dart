// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_engine_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$savingsEngineHash() => r'759486b2a7f8bc3f90ec88bb06718d63d2b4bf91';

/// See also [savingsEngine].
@ProviderFor(savingsEngine)
final savingsEngineProvider = AutoDisposeProvider<SavingsEngine>.internal(
  savingsEngine,
  name: r'savingsEngineProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$savingsEngineHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SavingsEngineRef = AutoDisposeProviderRef<SavingsEngine>;
String _$savingsGoalsStreamHash() =>
    r'698ee98a1decfe866913c1e8b12efd0ba65c9171';

/// See also [savingsGoalsStream].
@ProviderFor(savingsGoalsStream)
final savingsGoalsStreamProvider =
    AutoDisposeStreamProvider<List<SavingsGoalModel>>.internal(
      savingsGoalsStream,
      name: r'savingsGoalsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$savingsGoalsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SavingsGoalsStreamRef =
    AutoDisposeStreamProviderRef<List<SavingsGoalModel>>;
String _$savingsGoalStreamHash() => r'826e739af2776cebcb5cf15b2554e35d04ec1f64';

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

/// See also [savingsGoalStream].
@ProviderFor(savingsGoalStream)
const savingsGoalStreamProvider = SavingsGoalStreamFamily();

/// See also [savingsGoalStream].
class SavingsGoalStreamFamily extends Family<AsyncValue<SavingsGoalModel?>> {
  /// See also [savingsGoalStream].
  const SavingsGoalStreamFamily();

  /// See also [savingsGoalStream].
  SavingsGoalStreamProvider call(String id) {
    return SavingsGoalStreamProvider(id);
  }

  @override
  SavingsGoalStreamProvider getProviderOverride(
    covariant SavingsGoalStreamProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'savingsGoalStreamProvider';
}

/// See also [savingsGoalStream].
class SavingsGoalStreamProvider
    extends AutoDisposeStreamProvider<SavingsGoalModel?> {
  /// See also [savingsGoalStream].
  SavingsGoalStreamProvider(String id)
    : this._internal(
        (ref) => savingsGoalStream(ref as SavingsGoalStreamRef, id),
        from: savingsGoalStreamProvider,
        name: r'savingsGoalStreamProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$savingsGoalStreamHash,
        dependencies: SavingsGoalStreamFamily._dependencies,
        allTransitiveDependencies:
            SavingsGoalStreamFamily._allTransitiveDependencies,
        id: id,
      );

  SavingsGoalStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    Stream<SavingsGoalModel?> Function(SavingsGoalStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SavingsGoalStreamProvider._internal(
        (ref) => create(ref as SavingsGoalStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<SavingsGoalModel?> createElement() {
    return _SavingsGoalStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SavingsGoalStreamProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SavingsGoalStreamRef on AutoDisposeStreamProviderRef<SavingsGoalModel?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _SavingsGoalStreamProviderElement
    extends AutoDisposeStreamProviderElement<SavingsGoalModel?>
    with SavingsGoalStreamRef {
  _SavingsGoalStreamProviderElement(super.provider);

  @override
  String get id => (origin as SavingsGoalStreamProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
