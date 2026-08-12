// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_engine_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(categoryEngine)
final categoryEngineProvider = CategoryEngineProvider._();

final class CategoryEngineProvider
    extends $FunctionalProvider<CategoryEngine, CategoryEngine, CategoryEngine>
    with $Provider<CategoryEngine> {
  CategoryEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryEngineHash();

  @$internal
  @override
  $ProviderElement<CategoryEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CategoryEngine create(Ref ref) {
    return categoryEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryEngine>(value),
    );
  }
}

String _$categoryEngineHash() => r'763c866b9a0f4360f99bb64164ecac6896251ce3';
