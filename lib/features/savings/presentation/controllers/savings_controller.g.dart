// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SavingsController)
final savingsControllerProvider = SavingsControllerProvider._();

final class SavingsControllerProvider
    extends $AsyncNotifierProvider<SavingsController, void> {
  SavingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savingsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savingsControllerHash();

  @$internal
  @override
  SavingsController create() => SavingsController();
}

String _$savingsControllerHash() => r'8db7136ea6af349dc742b9d14400e09cfb421a07';

abstract class _$SavingsController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
