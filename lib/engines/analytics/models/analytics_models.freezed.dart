// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CategoryBreakdown {

 String get categoryId; String get categoryName; int get color; String get icon; int get total; double get percentage;
/// Create a copy of CategoryBreakdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryBreakdownCopyWith<CategoryBreakdown> get copyWith => _$CategoryBreakdownCopyWithImpl<CategoryBreakdown>(this as CategoryBreakdown, _$identity);

  /// Serializes this CategoryBreakdown to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryBreakdown&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.color, color) || other.color == color)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.total, total) || other.total == total)&&(identical(other.percentage, percentage) || other.percentage == percentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,categoryName,color,icon,total,percentage);

@override
String toString() {
  return 'CategoryBreakdown(categoryId: $categoryId, categoryName: $categoryName, color: $color, icon: $icon, total: $total, percentage: $percentage)';
}


}

/// @nodoc
abstract mixin class $CategoryBreakdownCopyWith<$Res>  {
  factory $CategoryBreakdownCopyWith(CategoryBreakdown value, $Res Function(CategoryBreakdown) _then) = _$CategoryBreakdownCopyWithImpl;
@useResult
$Res call({
 String categoryId, String categoryName, int color, String icon, int total, double percentage
});




}
/// @nodoc
class _$CategoryBreakdownCopyWithImpl<$Res>
    implements $CategoryBreakdownCopyWith<$Res> {
  _$CategoryBreakdownCopyWithImpl(this._self, this._then);

  final CategoryBreakdown _self;
  final $Res Function(CategoryBreakdown) _then;

/// Create a copy of CategoryBreakdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = null,Object? categoryName = null,Object? color = null,Object? icon = null,Object? total = null,Object? percentage = null,}) {
  return _then(_self.copyWith(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryBreakdown].
extension CategoryBreakdownPatterns on CategoryBreakdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryBreakdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryBreakdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryBreakdown value)  $default,){
final _that = this;
switch (_that) {
case _CategoryBreakdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryBreakdown value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryBreakdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String categoryId,  String categoryName,  int color,  String icon,  int total,  double percentage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryBreakdown() when $default != null:
return $default(_that.categoryId,_that.categoryName,_that.color,_that.icon,_that.total,_that.percentage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String categoryId,  String categoryName,  int color,  String icon,  int total,  double percentage)  $default,) {final _that = this;
switch (_that) {
case _CategoryBreakdown():
return $default(_that.categoryId,_that.categoryName,_that.color,_that.icon,_that.total,_that.percentage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String categoryId,  String categoryName,  int color,  String icon,  int total,  double percentage)?  $default,) {final _that = this;
switch (_that) {
case _CategoryBreakdown() when $default != null:
return $default(_that.categoryId,_that.categoryName,_that.color,_that.icon,_that.total,_that.percentage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CategoryBreakdown implements CategoryBreakdown {
  const _CategoryBreakdown({required this.categoryId, required this.categoryName, required this.color, required this.icon, required this.total, required this.percentage});
  factory _CategoryBreakdown.fromJson(Map<String, dynamic> json) => _$CategoryBreakdownFromJson(json);

@override final  String categoryId;
@override final  String categoryName;
@override final  int color;
@override final  String icon;
@override final  int total;
@override final  double percentage;

/// Create a copy of CategoryBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryBreakdownCopyWith<_CategoryBreakdown> get copyWith => __$CategoryBreakdownCopyWithImpl<_CategoryBreakdown>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryBreakdownToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryBreakdown&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.color, color) || other.color == color)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.total, total) || other.total == total)&&(identical(other.percentage, percentage) || other.percentage == percentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,categoryName,color,icon,total,percentage);

@override
String toString() {
  return 'CategoryBreakdown(categoryId: $categoryId, categoryName: $categoryName, color: $color, icon: $icon, total: $total, percentage: $percentage)';
}


}

/// @nodoc
abstract mixin class _$CategoryBreakdownCopyWith<$Res> implements $CategoryBreakdownCopyWith<$Res> {
  factory _$CategoryBreakdownCopyWith(_CategoryBreakdown value, $Res Function(_CategoryBreakdown) _then) = __$CategoryBreakdownCopyWithImpl;
@override @useResult
$Res call({
 String categoryId, String categoryName, int color, String icon, int total, double percentage
});




}
/// @nodoc
class __$CategoryBreakdownCopyWithImpl<$Res>
    implements _$CategoryBreakdownCopyWith<$Res> {
  __$CategoryBreakdownCopyWithImpl(this._self, this._then);

  final _CategoryBreakdown _self;
  final $Res Function(_CategoryBreakdown) _then;

/// Create a copy of CategoryBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = null,Object? categoryName = null,Object? color = null,Object? icon = null,Object? total = null,Object? percentage = null,}) {
  return _then(_CategoryBreakdown(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$DailyTrend {

 DateTime get date; int get total;
/// Create a copy of DailyTrend
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyTrendCopyWith<DailyTrend> get copyWith => _$DailyTrendCopyWithImpl<DailyTrend>(this as DailyTrend, _$identity);

  /// Serializes this DailyTrend to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyTrend&&(identical(other.date, date) || other.date == date)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,total);

@override
String toString() {
  return 'DailyTrend(date: $date, total: $total)';
}


}

/// @nodoc
abstract mixin class $DailyTrendCopyWith<$Res>  {
  factory $DailyTrendCopyWith(DailyTrend value, $Res Function(DailyTrend) _then) = _$DailyTrendCopyWithImpl;
@useResult
$Res call({
 DateTime date, int total
});




}
/// @nodoc
class _$DailyTrendCopyWithImpl<$Res>
    implements $DailyTrendCopyWith<$Res> {
  _$DailyTrendCopyWithImpl(this._self, this._then);

  final DailyTrend _self;
  final $Res Function(DailyTrend) _then;

/// Create a copy of DailyTrend
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? total = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyTrend].
extension DailyTrendPatterns on DailyTrend {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyTrend value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyTrend() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyTrend value)  $default,){
final _that = this;
switch (_that) {
case _DailyTrend():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyTrend value)?  $default,){
final _that = this;
switch (_that) {
case _DailyTrend() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyTrend() when $default != null:
return $default(_that.date,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  int total)  $default,) {final _that = this;
switch (_that) {
case _DailyTrend():
return $default(_that.date,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  int total)?  $default,) {final _that = this;
switch (_that) {
case _DailyTrend() when $default != null:
return $default(_that.date,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DailyTrend implements DailyTrend {
  const _DailyTrend({required this.date, required this.total});
  factory _DailyTrend.fromJson(Map<String, dynamic> json) => _$DailyTrendFromJson(json);

@override final  DateTime date;
@override final  int total;

/// Create a copy of DailyTrend
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyTrendCopyWith<_DailyTrend> get copyWith => __$DailyTrendCopyWithImpl<_DailyTrend>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DailyTrendToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyTrend&&(identical(other.date, date) || other.date == date)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,total);

@override
String toString() {
  return 'DailyTrend(date: $date, total: $total)';
}


}

/// @nodoc
abstract mixin class _$DailyTrendCopyWith<$Res> implements $DailyTrendCopyWith<$Res> {
  factory _$DailyTrendCopyWith(_DailyTrend value, $Res Function(_DailyTrend) _then) = __$DailyTrendCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, int total
});




}
/// @nodoc
class __$DailyTrendCopyWithImpl<$Res>
    implements _$DailyTrendCopyWith<$Res> {
  __$DailyTrendCopyWithImpl(this._self, this._then);

  final _DailyTrend _self;
  final $Res Function(_DailyTrend) _then;

/// Create a copy of DailyTrend
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? total = null,}) {
  return _then(_DailyTrend(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$MonthOverMonthComparison {

 int get currentTotal; int get previousTotal; double get changePercent;
/// Create a copy of MonthOverMonthComparison
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthOverMonthComparisonCopyWith<MonthOverMonthComparison> get copyWith => _$MonthOverMonthComparisonCopyWithImpl<MonthOverMonthComparison>(this as MonthOverMonthComparison, _$identity);

  /// Serializes this MonthOverMonthComparison to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthOverMonthComparison&&(identical(other.currentTotal, currentTotal) || other.currentTotal == currentTotal)&&(identical(other.previousTotal, previousTotal) || other.previousTotal == previousTotal)&&(identical(other.changePercent, changePercent) || other.changePercent == changePercent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentTotal,previousTotal,changePercent);

@override
String toString() {
  return 'MonthOverMonthComparison(currentTotal: $currentTotal, previousTotal: $previousTotal, changePercent: $changePercent)';
}


}

/// @nodoc
abstract mixin class $MonthOverMonthComparisonCopyWith<$Res>  {
  factory $MonthOverMonthComparisonCopyWith(MonthOverMonthComparison value, $Res Function(MonthOverMonthComparison) _then) = _$MonthOverMonthComparisonCopyWithImpl;
@useResult
$Res call({
 int currentTotal, int previousTotal, double changePercent
});




}
/// @nodoc
class _$MonthOverMonthComparisonCopyWithImpl<$Res>
    implements $MonthOverMonthComparisonCopyWith<$Res> {
  _$MonthOverMonthComparisonCopyWithImpl(this._self, this._then);

  final MonthOverMonthComparison _self;
  final $Res Function(MonthOverMonthComparison) _then;

/// Create a copy of MonthOverMonthComparison
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentTotal = null,Object? previousTotal = null,Object? changePercent = null,}) {
  return _then(_self.copyWith(
currentTotal: null == currentTotal ? _self.currentTotal : currentTotal // ignore: cast_nullable_to_non_nullable
as int,previousTotal: null == previousTotal ? _self.previousTotal : previousTotal // ignore: cast_nullable_to_non_nullable
as int,changePercent: null == changePercent ? _self.changePercent : changePercent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthOverMonthComparison].
extension MonthOverMonthComparisonPatterns on MonthOverMonthComparison {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthOverMonthComparison value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthOverMonthComparison() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthOverMonthComparison value)  $default,){
final _that = this;
switch (_that) {
case _MonthOverMonthComparison():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthOverMonthComparison value)?  $default,){
final _that = this;
switch (_that) {
case _MonthOverMonthComparison() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentTotal,  int previousTotal,  double changePercent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthOverMonthComparison() when $default != null:
return $default(_that.currentTotal,_that.previousTotal,_that.changePercent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentTotal,  int previousTotal,  double changePercent)  $default,) {final _that = this;
switch (_that) {
case _MonthOverMonthComparison():
return $default(_that.currentTotal,_that.previousTotal,_that.changePercent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentTotal,  int previousTotal,  double changePercent)?  $default,) {final _that = this;
switch (_that) {
case _MonthOverMonthComparison() when $default != null:
return $default(_that.currentTotal,_that.previousTotal,_that.changePercent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MonthOverMonthComparison implements MonthOverMonthComparison {
  const _MonthOverMonthComparison({required this.currentTotal, required this.previousTotal, required this.changePercent});
  factory _MonthOverMonthComparison.fromJson(Map<String, dynamic> json) => _$MonthOverMonthComparisonFromJson(json);

@override final  int currentTotal;
@override final  int previousTotal;
@override final  double changePercent;

/// Create a copy of MonthOverMonthComparison
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthOverMonthComparisonCopyWith<_MonthOverMonthComparison> get copyWith => __$MonthOverMonthComparisonCopyWithImpl<_MonthOverMonthComparison>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthOverMonthComparisonToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthOverMonthComparison&&(identical(other.currentTotal, currentTotal) || other.currentTotal == currentTotal)&&(identical(other.previousTotal, previousTotal) || other.previousTotal == previousTotal)&&(identical(other.changePercent, changePercent) || other.changePercent == changePercent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentTotal,previousTotal,changePercent);

@override
String toString() {
  return 'MonthOverMonthComparison(currentTotal: $currentTotal, previousTotal: $previousTotal, changePercent: $changePercent)';
}


}

/// @nodoc
abstract mixin class _$MonthOverMonthComparisonCopyWith<$Res> implements $MonthOverMonthComparisonCopyWith<$Res> {
  factory _$MonthOverMonthComparisonCopyWith(_MonthOverMonthComparison value, $Res Function(_MonthOverMonthComparison) _then) = __$MonthOverMonthComparisonCopyWithImpl;
@override @useResult
$Res call({
 int currentTotal, int previousTotal, double changePercent
});




}
/// @nodoc
class __$MonthOverMonthComparisonCopyWithImpl<$Res>
    implements _$MonthOverMonthComparisonCopyWith<$Res> {
  __$MonthOverMonthComparisonCopyWithImpl(this._self, this._then);

  final _MonthOverMonthComparison _self;
  final $Res Function(_MonthOverMonthComparison) _then;

/// Create a copy of MonthOverMonthComparison
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentTotal = null,Object? previousTotal = null,Object? changePercent = null,}) {
  return _then(_MonthOverMonthComparison(
currentTotal: null == currentTotal ? _self.currentTotal : currentTotal // ignore: cast_nullable_to_non_nullable
as int,previousTotal: null == previousTotal ? _self.previousTotal : previousTotal // ignore: cast_nullable_to_non_nullable
as int,changePercent: null == changePercent ? _self.changePercent : changePercent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
