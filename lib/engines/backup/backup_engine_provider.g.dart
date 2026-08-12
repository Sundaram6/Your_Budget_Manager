// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_engine_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(backupEngine)
final backupEngineProvider = BackupEngineProvider._();

final class BackupEngineProvider
    extends $FunctionalProvider<BackupEngine, BackupEngine, BackupEngine>
    with $Provider<BackupEngine> {
  BackupEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupEngineHash();

  @$internal
  @override
  $ProviderElement<BackupEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackupEngine create(Ref ref) {
    return backupEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupEngine>(value),
    );
  }
}

String _$backupEngineHash() => r'4335cef33dab500c5ce2dad28fa0075208e456d3';
