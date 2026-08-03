// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DashboardState {
  double get monthlyTotal => throw _privateConstructorUsedError;
  DailyAllowance? get dailyAllowance => throw _privateConstructorUsedError;
  Budget? get overallMonthlyBudget => throw _privateConstructorUsedError;
  List<CategoryBreakdown> get categoryBreakdown =>
      throw _privateConstructorUsedError;
  List<BudgetProgress> get budgetProgress => throw _privateConstructorUsedError;
  List<Transaction> get recentTransactions =>
      throw _privateConstructorUsedError;
  List<AiInsight> get insights => throw _privateConstructorUsedError;
  int get healthScore => throw _privateConstructorUsedError;

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardStateCopyWith<DashboardState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardStateCopyWith<$Res> {
  factory $DashboardStateCopyWith(
    DashboardState value,
    $Res Function(DashboardState) then,
  ) = _$DashboardStateCopyWithImpl<$Res, DashboardState>;
  @useResult
  $Res call({
    double monthlyTotal,
    DailyAllowance? dailyAllowance,
    Budget? overallMonthlyBudget,
    List<CategoryBreakdown> categoryBreakdown,
    List<BudgetProgress> budgetProgress,
    List<Transaction> recentTransactions,
    List<AiInsight> insights,
    int healthScore,
  });

  $DailyAllowanceCopyWith<$Res>? get dailyAllowance;
}

/// @nodoc
class _$DashboardStateCopyWithImpl<$Res, $Val extends DashboardState>
    implements $DashboardStateCopyWith<$Res> {
  _$DashboardStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthlyTotal = null,
    Object? dailyAllowance = freezed,
    Object? overallMonthlyBudget = freezed,
    Object? categoryBreakdown = null,
    Object? budgetProgress = null,
    Object? recentTransactions = null,
    Object? insights = null,
    Object? healthScore = null,
  }) {
    return _then(
      _value.copyWith(
            monthlyTotal: null == monthlyTotal
                ? _value.monthlyTotal
                : monthlyTotal // ignore: cast_nullable_to_non_nullable
                      as double,
            dailyAllowance: freezed == dailyAllowance
                ? _value.dailyAllowance
                : dailyAllowance // ignore: cast_nullable_to_non_nullable
                      as DailyAllowance?,
            overallMonthlyBudget: freezed == overallMonthlyBudget
                ? _value.overallMonthlyBudget
                : overallMonthlyBudget // ignore: cast_nullable_to_non_nullable
                      as Budget?,
            categoryBreakdown: null == categoryBreakdown
                ? _value.categoryBreakdown
                : categoryBreakdown // ignore: cast_nullable_to_non_nullable
                      as List<CategoryBreakdown>,
            budgetProgress: null == budgetProgress
                ? _value.budgetProgress
                : budgetProgress // ignore: cast_nullable_to_non_nullable
                      as List<BudgetProgress>,
            recentTransactions: null == recentTransactions
                ? _value.recentTransactions
                : recentTransactions // ignore: cast_nullable_to_non_nullable
                      as List<Transaction>,
            insights: null == insights
                ? _value.insights
                : insights // ignore: cast_nullable_to_non_nullable
                      as List<AiInsight>,
            healthScore: null == healthScore
                ? _value.healthScore
                : healthScore // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DailyAllowanceCopyWith<$Res>? get dailyAllowance {
    if (_value.dailyAllowance == null) {
      return null;
    }

    return $DailyAllowanceCopyWith<$Res>(_value.dailyAllowance!, (value) {
      return _then(_value.copyWith(dailyAllowance: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DashboardStateImplCopyWith<$Res>
    implements $DashboardStateCopyWith<$Res> {
  factory _$$DashboardStateImplCopyWith(
    _$DashboardStateImpl value,
    $Res Function(_$DashboardStateImpl) then,
  ) = __$$DashboardStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double monthlyTotal,
    DailyAllowance? dailyAllowance,
    Budget? overallMonthlyBudget,
    List<CategoryBreakdown> categoryBreakdown,
    List<BudgetProgress> budgetProgress,
    List<Transaction> recentTransactions,
    List<AiInsight> insights,
    int healthScore,
  });

  @override
  $DailyAllowanceCopyWith<$Res>? get dailyAllowance;
}

/// @nodoc
class __$$DashboardStateImplCopyWithImpl<$Res>
    extends _$DashboardStateCopyWithImpl<$Res, _$DashboardStateImpl>
    implements _$$DashboardStateImplCopyWith<$Res> {
  __$$DashboardStateImplCopyWithImpl(
    _$DashboardStateImpl _value,
    $Res Function(_$DashboardStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthlyTotal = null,
    Object? dailyAllowance = freezed,
    Object? overallMonthlyBudget = freezed,
    Object? categoryBreakdown = null,
    Object? budgetProgress = null,
    Object? recentTransactions = null,
    Object? insights = null,
    Object? healthScore = null,
  }) {
    return _then(
      _$DashboardStateImpl(
        monthlyTotal: null == monthlyTotal
            ? _value.monthlyTotal
            : monthlyTotal // ignore: cast_nullable_to_non_nullable
                  as double,
        dailyAllowance: freezed == dailyAllowance
            ? _value.dailyAllowance
            : dailyAllowance // ignore: cast_nullable_to_non_nullable
                  as DailyAllowance?,
        overallMonthlyBudget: freezed == overallMonthlyBudget
            ? _value.overallMonthlyBudget
            : overallMonthlyBudget // ignore: cast_nullable_to_non_nullable
                  as Budget?,
        categoryBreakdown: null == categoryBreakdown
            ? _value._categoryBreakdown
            : categoryBreakdown // ignore: cast_nullable_to_non_nullable
                  as List<CategoryBreakdown>,
        budgetProgress: null == budgetProgress
            ? _value._budgetProgress
            : budgetProgress // ignore: cast_nullable_to_non_nullable
                  as List<BudgetProgress>,
        recentTransactions: null == recentTransactions
            ? _value._recentTransactions
            : recentTransactions // ignore: cast_nullable_to_non_nullable
                  as List<Transaction>,
        insights: null == insights
            ? _value._insights
            : insights // ignore: cast_nullable_to_non_nullable
                  as List<AiInsight>,
        healthScore: null == healthScore
            ? _value.healthScore
            : healthScore // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$DashboardStateImpl implements _DashboardState {
  const _$DashboardStateImpl({
    required this.monthlyTotal,
    this.dailyAllowance,
    this.overallMonthlyBudget,
    required final List<CategoryBreakdown> categoryBreakdown,
    required final List<BudgetProgress> budgetProgress,
    required final List<Transaction> recentTransactions,
    final List<AiInsight> insights = const [],
    this.healthScore = 100,
  }) : _categoryBreakdown = categoryBreakdown,
       _budgetProgress = budgetProgress,
       _recentTransactions = recentTransactions,
       _insights = insights;

  @override
  final double monthlyTotal;
  @override
  final DailyAllowance? dailyAllowance;
  @override
  final Budget? overallMonthlyBudget;
  final List<CategoryBreakdown> _categoryBreakdown;
  @override
  List<CategoryBreakdown> get categoryBreakdown {
    if (_categoryBreakdown is EqualUnmodifiableListView)
      return _categoryBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categoryBreakdown);
  }

  final List<BudgetProgress> _budgetProgress;
  @override
  List<BudgetProgress> get budgetProgress {
    if (_budgetProgress is EqualUnmodifiableListView) return _budgetProgress;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_budgetProgress);
  }

  final List<Transaction> _recentTransactions;
  @override
  List<Transaction> get recentTransactions {
    if (_recentTransactions is EqualUnmodifiableListView)
      return _recentTransactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentTransactions);
  }

  final List<AiInsight> _insights;
  @override
  @JsonKey()
  List<AiInsight> get insights {
    if (_insights is EqualUnmodifiableListView) return _insights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_insights);
  }

  @override
  @JsonKey()
  final int healthScore;

  @override
  String toString() {
    return 'DashboardState(monthlyTotal: $monthlyTotal, dailyAllowance: $dailyAllowance, overallMonthlyBudget: $overallMonthlyBudget, categoryBreakdown: $categoryBreakdown, budgetProgress: $budgetProgress, recentTransactions: $recentTransactions, insights: $insights, healthScore: $healthScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardStateImpl &&
            (identical(other.monthlyTotal, monthlyTotal) ||
                other.monthlyTotal == monthlyTotal) &&
            (identical(other.dailyAllowance, dailyAllowance) ||
                other.dailyAllowance == dailyAllowance) &&
            const DeepCollectionEquality().equals(
              other.overallMonthlyBudget,
              overallMonthlyBudget,
            ) &&
            const DeepCollectionEquality().equals(
              other._categoryBreakdown,
              _categoryBreakdown,
            ) &&
            const DeepCollectionEquality().equals(
              other._budgetProgress,
              _budgetProgress,
            ) &&
            const DeepCollectionEquality().equals(
              other._recentTransactions,
              _recentTransactions,
            ) &&
            const DeepCollectionEquality().equals(other._insights, _insights) &&
            (identical(other.healthScore, healthScore) ||
                other.healthScore == healthScore));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    monthlyTotal,
    dailyAllowance,
    const DeepCollectionEquality().hash(overallMonthlyBudget),
    const DeepCollectionEquality().hash(_categoryBreakdown),
    const DeepCollectionEquality().hash(_budgetProgress),
    const DeepCollectionEquality().hash(_recentTransactions),
    const DeepCollectionEquality().hash(_insights),
    healthScore,
  );

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardStateImplCopyWith<_$DashboardStateImpl> get copyWith =>
      __$$DashboardStateImplCopyWithImpl<_$DashboardStateImpl>(
        this,
        _$identity,
      );
}

abstract class _DashboardState implements DashboardState {
  const factory _DashboardState({
    required final double monthlyTotal,
    final DailyAllowance? dailyAllowance,
    final Budget? overallMonthlyBudget,
    required final List<CategoryBreakdown> categoryBreakdown,
    required final List<BudgetProgress> budgetProgress,
    required final List<Transaction> recentTransactions,
    final List<AiInsight> insights,
    final int healthScore,
  }) = _$DashboardStateImpl;

  @override
  double get monthlyTotal;
  @override
  DailyAllowance? get dailyAllowance;
  @override
  Budget? get overallMonthlyBudget;
  @override
  List<CategoryBreakdown> get categoryBreakdown;
  @override
  List<BudgetProgress> get budgetProgress;
  @override
  List<Transaction> get recentTransactions;
  @override
  List<AiInsight> get insights;
  @override
  int get healthScore;

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardStateImplCopyWith<_$DashboardStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
