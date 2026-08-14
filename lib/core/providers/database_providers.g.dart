// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'b189f0af306321b262536f6598295ca9be3f1f7b';

@ProviderFor(categoryRepository)
final categoryRepositoryProvider = CategoryRepositoryProvider._();

final class CategoryRepositoryProvider
    extends
        $FunctionalProvider<
          CategoryRepository,
          CategoryRepository,
          CategoryRepository
        >
    with $Provider<CategoryRepository> {
  CategoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<CategoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CategoryRepository create(Ref ref) {
    return categoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryRepository>(value),
    );
  }
}

String _$categoryRepositoryHash() =>
    r'28f68a2fe03d45ea3276701dfa43d08c9411e3fd';

@ProviderFor(transactionRepository)
final transactionRepositoryProvider = TransactionRepositoryProvider._();

final class TransactionRepositoryProvider
    extends
        $FunctionalProvider<
          TransactionRepository,
          TransactionRepository,
          TransactionRepository
        >
    with $Provider<TransactionRepository> {
  TransactionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionRepositoryHash();

  @$internal
  @override
  $ProviderElement<TransactionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransactionRepository create(Ref ref) {
    return transactionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionRepository>(value),
    );
  }
}

String _$transactionRepositoryHash() =>
    r'b75a873a7daafe6ca90878728a05328cc1dbf4b7';

@ProviderFor(budgetRepository)
final budgetRepositoryProvider = BudgetRepositoryProvider._();

final class BudgetRepositoryProvider
    extends
        $FunctionalProvider<
          BudgetRepository,
          BudgetRepository,
          BudgetRepository
        >
    with $Provider<BudgetRepository> {
  BudgetRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetRepositoryHash();

  @$internal
  @override
  $ProviderElement<BudgetRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BudgetRepository create(Ref ref) {
    return budgetRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetRepository>(value),
    );
  }
}

String _$budgetRepositoryHash() => r'6226b43465676891e0296a12532fa0d6e8c009e4';

@ProviderFor(recurringRepository)
final recurringRepositoryProvider = RecurringRepositoryProvider._();

final class RecurringRepositoryProvider
    extends
        $FunctionalProvider<
          RecurringRepository,
          RecurringRepository,
          RecurringRepository
        >
    with $Provider<RecurringRepository> {
  RecurringRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringRepositoryHash();

  @$internal
  @override
  $ProviderElement<RecurringRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecurringRepository create(Ref ref) {
    return recurringRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecurringRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecurringRepository>(value),
    );
  }
}

String _$recurringRepositoryHash() =>
    r'284ed0353e3ecec54e28f997cc03433eb5f573f2';

@ProviderFor(savingsGoalDao)
final savingsGoalDaoProvider = SavingsGoalDaoProvider._();

final class SavingsGoalDaoProvider
    extends $FunctionalProvider<SavingsGoalDao, SavingsGoalDao, SavingsGoalDao>
    with $Provider<SavingsGoalDao> {
  SavingsGoalDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savingsGoalDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savingsGoalDaoHash();

  @$internal
  @override
  $ProviderElement<SavingsGoalDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SavingsGoalDao create(Ref ref) {
    return savingsGoalDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavingsGoalDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavingsGoalDao>(value),
    );
  }
}

String _$savingsGoalDaoHash() => r'148c3f060fed35ab77f0c4ddf8944ad51ad3e4d5';

@ProviderFor(savingsGoalRepository)
final savingsGoalRepositoryProvider = SavingsGoalRepositoryProvider._();

final class SavingsGoalRepositoryProvider
    extends
        $FunctionalProvider<
          SavingsGoalRepository,
          SavingsGoalRepository,
          SavingsGoalRepository
        >
    with $Provider<SavingsGoalRepository> {
  SavingsGoalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savingsGoalRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savingsGoalRepositoryHash();

  @$internal
  @override
  $ProviderElement<SavingsGoalRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SavingsGoalRepository create(Ref ref) {
    return savingsGoalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavingsGoalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavingsGoalRepository>(value),
    );
  }
}

String _$savingsGoalRepositoryHash() =>
    r'd700427a01d1b2ef743bb8c4d193988ad166af43';
