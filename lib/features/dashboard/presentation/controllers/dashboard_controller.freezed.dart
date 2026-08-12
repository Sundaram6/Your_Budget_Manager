// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DashboardState {

 int get monthlyTotal; DailyAllowance? get dailyAllowance; Budget? get overallMonthlyBudget; List<CategoryBreakdown> get categoryBreakdown; List<BudgetProgress> get budgetProgress; List<Transaction> get recentTransactions; List<AiInsight> get insights; int get healthScore;
/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardStateCopyWith<DashboardState> get copyWith => _$DashboardStateCopyWithImpl<DashboardState>(this as DashboardState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardState&&(identical(other.monthlyTotal, monthlyTotal) || other.monthlyTotal == monthlyTotal)&&(identical(other.dailyAllowance, dailyAllowance) || other.dailyAllowance == dailyAllowance)&&const DeepCollectionEquality().equals(other.overallMonthlyBudget, overallMonthlyBudget)&&const DeepCollectionEquality().equals(other.categoryBreakdown, categoryBreakdown)&&const DeepCollectionEquality().equals(other.budgetProgress, budgetProgress)&&const DeepCollectionEquality().equals(other.recentTransactions, recentTransactions)&&const DeepCollectionEquality().equals(other.insights, insights)&&(identical(other.healthScore, healthScore) || other.healthScore == healthScore));
}


@override
int get hashCode => Object.hash(runtimeType,monthlyTotal,dailyAllowance,const DeepCollectionEquality().hash(overallMonthlyBudget),const DeepCollectionEquality().hash(categoryBreakdown),const DeepCollectionEquality().hash(budgetProgress),const DeepCollectionEquality().hash(recentTransactions),const DeepCollectionEquality().hash(insights),healthScore);

@override
String toString() {
  return 'DashboardState(monthlyTotal: $monthlyTotal, dailyAllowance: $dailyAllowance, overallMonthlyBudget: $overallMonthlyBudget, categoryBreakdown: $categoryBreakdown, budgetProgress: $budgetProgress, recentTransactions: $recentTransactions, insights: $insights, healthScore: $healthScore)';
}


}

/// @nodoc
abstract mixin class $DashboardStateCopyWith<$Res>  {
  factory $DashboardStateCopyWith(DashboardState value, $Res Function(DashboardState) _then) = _$DashboardStateCopyWithImpl;
@useResult
$Res call({
 int monthlyTotal, DailyAllowance? dailyAllowance, Budget? overallMonthlyBudget, List<CategoryBreakdown> categoryBreakdown, List<BudgetProgress> budgetProgress, List<Transaction> recentTransactions, List<AiInsight> insights, int healthScore
});


$DailyAllowanceCopyWith<$Res>? get dailyAllowance;

}
/// @nodoc
class _$DashboardStateCopyWithImpl<$Res>
    implements $DashboardStateCopyWith<$Res> {
  _$DashboardStateCopyWithImpl(this._self, this._then);

  final DashboardState _self;
  final $Res Function(DashboardState) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? monthlyTotal = null,Object? dailyAllowance = freezed,Object? overallMonthlyBudget = freezed,Object? categoryBreakdown = null,Object? budgetProgress = null,Object? recentTransactions = null,Object? insights = null,Object? healthScore = null,}) {
  return _then(_self.copyWith(
monthlyTotal: null == monthlyTotal ? _self.monthlyTotal : monthlyTotal // ignore: cast_nullable_to_non_nullable
as int,dailyAllowance: freezed == dailyAllowance ? _self.dailyAllowance : dailyAllowance // ignore: cast_nullable_to_non_nullable
as DailyAllowance?,overallMonthlyBudget: freezed == overallMonthlyBudget ? _self.overallMonthlyBudget : overallMonthlyBudget // ignore: cast_nullable_to_non_nullable
as Budget?,categoryBreakdown: null == categoryBreakdown ? _self.categoryBreakdown : categoryBreakdown // ignore: cast_nullable_to_non_nullable
as List<CategoryBreakdown>,budgetProgress: null == budgetProgress ? _self.budgetProgress : budgetProgress // ignore: cast_nullable_to_non_nullable
as List<BudgetProgress>,recentTransactions: null == recentTransactions ? _self.recentTransactions : recentTransactions // ignore: cast_nullable_to_non_nullable
as List<Transaction>,insights: null == insights ? _self.insights : insights // ignore: cast_nullable_to_non_nullable
as List<AiInsight>,healthScore: null == healthScore ? _self.healthScore : healthScore // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DailyAllowanceCopyWith<$Res>? get dailyAllowance {
    if (_self.dailyAllowance == null) {
    return null;
  }

  return $DailyAllowanceCopyWith<$Res>(_self.dailyAllowance!, (value) {
    return _then(_self.copyWith(dailyAllowance: value));
  });
}
}


/// Adds pattern-matching-related methods to [DashboardState].
extension DashboardStatePatterns on DashboardState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardState value)  $default,){
final _that = this;
switch (_that) {
case _DashboardState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardState value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int monthlyTotal,  DailyAllowance? dailyAllowance,  Budget? overallMonthlyBudget,  List<CategoryBreakdown> categoryBreakdown,  List<BudgetProgress> budgetProgress,  List<Transaction> recentTransactions,  List<AiInsight> insights,  int healthScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
return $default(_that.monthlyTotal,_that.dailyAllowance,_that.overallMonthlyBudget,_that.categoryBreakdown,_that.budgetProgress,_that.recentTransactions,_that.insights,_that.healthScore);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int monthlyTotal,  DailyAllowance? dailyAllowance,  Budget? overallMonthlyBudget,  List<CategoryBreakdown> categoryBreakdown,  List<BudgetProgress> budgetProgress,  List<Transaction> recentTransactions,  List<AiInsight> insights,  int healthScore)  $default,) {final _that = this;
switch (_that) {
case _DashboardState():
return $default(_that.monthlyTotal,_that.dailyAllowance,_that.overallMonthlyBudget,_that.categoryBreakdown,_that.budgetProgress,_that.recentTransactions,_that.insights,_that.healthScore);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int monthlyTotal,  DailyAllowance? dailyAllowance,  Budget? overallMonthlyBudget,  List<CategoryBreakdown> categoryBreakdown,  List<BudgetProgress> budgetProgress,  List<Transaction> recentTransactions,  List<AiInsight> insights,  int healthScore)?  $default,) {final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
return $default(_that.monthlyTotal,_that.dailyAllowance,_that.overallMonthlyBudget,_that.categoryBreakdown,_that.budgetProgress,_that.recentTransactions,_that.insights,_that.healthScore);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardState implements DashboardState {
  const _DashboardState({required this.monthlyTotal, this.dailyAllowance, this.overallMonthlyBudget, required final  List<CategoryBreakdown> categoryBreakdown, required final  List<BudgetProgress> budgetProgress, required final  List<Transaction> recentTransactions, final  List<AiInsight> insights = const [], this.healthScore = 100}): _categoryBreakdown = categoryBreakdown,_budgetProgress = budgetProgress,_recentTransactions = recentTransactions,_insights = insights;
  

@override final  int monthlyTotal;
@override final  DailyAllowance? dailyAllowance;
@override final  Budget? overallMonthlyBudget;
 final  List<CategoryBreakdown> _categoryBreakdown;
@override List<CategoryBreakdown> get categoryBreakdown {
  if (_categoryBreakdown is EqualUnmodifiableListView) return _categoryBreakdown;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categoryBreakdown);
}

 final  List<BudgetProgress> _budgetProgress;
@override List<BudgetProgress> get budgetProgress {
  if (_budgetProgress is EqualUnmodifiableListView) return _budgetProgress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_budgetProgress);
}

 final  List<Transaction> _recentTransactions;
@override List<Transaction> get recentTransactions {
  if (_recentTransactions is EqualUnmodifiableListView) return _recentTransactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentTransactions);
}

 final  List<AiInsight> _insights;
@override@JsonKey() List<AiInsight> get insights {
  if (_insights is EqualUnmodifiableListView) return _insights;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_insights);
}

@override@JsonKey() final  int healthScore;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardStateCopyWith<_DashboardState> get copyWith => __$DashboardStateCopyWithImpl<_DashboardState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardState&&(identical(other.monthlyTotal, monthlyTotal) || other.monthlyTotal == monthlyTotal)&&(identical(other.dailyAllowance, dailyAllowance) || other.dailyAllowance == dailyAllowance)&&const DeepCollectionEquality().equals(other.overallMonthlyBudget, overallMonthlyBudget)&&const DeepCollectionEquality().equals(other._categoryBreakdown, _categoryBreakdown)&&const DeepCollectionEquality().equals(other._budgetProgress, _budgetProgress)&&const DeepCollectionEquality().equals(other._recentTransactions, _recentTransactions)&&const DeepCollectionEquality().equals(other._insights, _insights)&&(identical(other.healthScore, healthScore) || other.healthScore == healthScore));
}


@override
int get hashCode => Object.hash(runtimeType,monthlyTotal,dailyAllowance,const DeepCollectionEquality().hash(overallMonthlyBudget),const DeepCollectionEquality().hash(_categoryBreakdown),const DeepCollectionEquality().hash(_budgetProgress),const DeepCollectionEquality().hash(_recentTransactions),const DeepCollectionEquality().hash(_insights),healthScore);

@override
String toString() {
  return 'DashboardState(monthlyTotal: $monthlyTotal, dailyAllowance: $dailyAllowance, overallMonthlyBudget: $overallMonthlyBudget, categoryBreakdown: $categoryBreakdown, budgetProgress: $budgetProgress, recentTransactions: $recentTransactions, insights: $insights, healthScore: $healthScore)';
}


}

/// @nodoc
abstract mixin class _$DashboardStateCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory _$DashboardStateCopyWith(_DashboardState value, $Res Function(_DashboardState) _then) = __$DashboardStateCopyWithImpl;
@override @useResult
$Res call({
 int monthlyTotal, DailyAllowance? dailyAllowance, Budget? overallMonthlyBudget, List<CategoryBreakdown> categoryBreakdown, List<BudgetProgress> budgetProgress, List<Transaction> recentTransactions, List<AiInsight> insights, int healthScore
});


@override $DailyAllowanceCopyWith<$Res>? get dailyAllowance;

}
/// @nodoc
class __$DashboardStateCopyWithImpl<$Res>
    implements _$DashboardStateCopyWith<$Res> {
  __$DashboardStateCopyWithImpl(this._self, this._then);

  final _DashboardState _self;
  final $Res Function(_DashboardState) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? monthlyTotal = null,Object? dailyAllowance = freezed,Object? overallMonthlyBudget = freezed,Object? categoryBreakdown = null,Object? budgetProgress = null,Object? recentTransactions = null,Object? insights = null,Object? healthScore = null,}) {
  return _then(_DashboardState(
monthlyTotal: null == monthlyTotal ? _self.monthlyTotal : monthlyTotal // ignore: cast_nullable_to_non_nullable
as int,dailyAllowance: freezed == dailyAllowance ? _self.dailyAllowance : dailyAllowance // ignore: cast_nullable_to_non_nullable
as DailyAllowance?,overallMonthlyBudget: freezed == overallMonthlyBudget ? _self.overallMonthlyBudget : overallMonthlyBudget // ignore: cast_nullable_to_non_nullable
as Budget?,categoryBreakdown: null == categoryBreakdown ? _self._categoryBreakdown : categoryBreakdown // ignore: cast_nullable_to_non_nullable
as List<CategoryBreakdown>,budgetProgress: null == budgetProgress ? _self._budgetProgress : budgetProgress // ignore: cast_nullable_to_non_nullable
as List<BudgetProgress>,recentTransactions: null == recentTransactions ? _self._recentTransactions : recentTransactions // ignore: cast_nullable_to_non_nullable
as List<Transaction>,insights: null == insights ? _self._insights : insights // ignore: cast_nullable_to_non_nullable
as List<AiInsight>,healthScore: null == healthScore ? _self.healthScore : healthScore // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DailyAllowanceCopyWith<$Res>? get dailyAllowance {
    if (_self.dailyAllowance == null) {
    return null;
  }

  return $DailyAllowanceCopyWith<$Res>(_self.dailyAllowance!, (value) {
    return _then(_self.copyWith(dailyAllowance: value));
  });
}
}

// dart format on
