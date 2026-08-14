// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_lock_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppLockController)
final appLockControllerProvider = AppLockControllerProvider._();

final class AppLockControllerProvider
    extends $NotifierProvider<AppLockController, bool> {
  AppLockControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLockControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLockControllerHash();

  @$internal
  @override
  AppLockController create() => AppLockController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$appLockControllerHash() => r'bb94db578ad627c287c04244a40e94199507aceb';

abstract class _$AppLockController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
