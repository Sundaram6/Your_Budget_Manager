// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CategoryBreakdown _$CategoryBreakdownFromJson(Map<String, dynamic> json) {
  return _CategoryBreakdown.fromJson(json);
}

/// @nodoc
mixin _$CategoryBreakdown {
  String get categoryId => throw _privateConstructorUsedError;
  String get categoryName => throw _privateConstructorUsedError;
  int get color => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  double get percentage => throw _privateConstructorUsedError;

  /// Serializes this CategoryBreakdown to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CategoryBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategoryBreakdownCopyWith<CategoryBreakdown> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryBreakdownCopyWith<$Res> {
  factory $CategoryBreakdownCopyWith(
    CategoryBreakdown value,
    $Res Function(CategoryBreakdown) then,
  ) = _$CategoryBreakdownCopyWithImpl<$Res, CategoryBreakdown>;
  @useResult
  $Res call({
    String categoryId,
    String categoryName,
    int color,
    String icon,
    double total,
    double percentage,
  });
}

/// @nodoc
class _$CategoryBreakdownCopyWithImpl<$Res, $Val extends CategoryBreakdown>
    implements $CategoryBreakdownCopyWith<$Res> {
  _$CategoryBreakdownCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CategoryBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryId = null,
    Object? categoryName = null,
    Object? color = null,
    Object? icon = null,
    Object? total = null,
    Object? percentage = null,
  }) {
    return _then(
      _value.copyWith(
            categoryId: null == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String,
            categoryName: null == categoryName
                ? _value.categoryName
                : categoryName // ignore: cast_nullable_to_non_nullable
                      as String,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as int,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as double,
            percentage: null == percentage
                ? _value.percentage
                : percentage // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CategoryBreakdownImplCopyWith<$Res>
    implements $CategoryBreakdownCopyWith<$Res> {
  factory _$$CategoryBreakdownImplCopyWith(
    _$CategoryBreakdownImpl value,
    $Res Function(_$CategoryBreakdownImpl) then,
  ) = __$$CategoryBreakdownImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String categoryId,
    String categoryName,
    int color,
    String icon,
    double total,
    double percentage,
  });
}

/// @nodoc
class __$$CategoryBreakdownImplCopyWithImpl<$Res>
    extends _$CategoryBreakdownCopyWithImpl<$Res, _$CategoryBreakdownImpl>
    implements _$$CategoryBreakdownImplCopyWith<$Res> {
  __$$CategoryBreakdownImplCopyWithImpl(
    _$CategoryBreakdownImpl _value,
    $Res Function(_$CategoryBreakdownImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CategoryBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryId = null,
    Object? categoryName = null,
    Object? color = null,
    Object? icon = null,
    Object? total = null,
    Object? percentage = null,
  }) {
    return _then(
      _$CategoryBreakdownImpl(
        categoryId: null == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryName: null == categoryName
            ? _value.categoryName
            : categoryName // ignore: cast_nullable_to_non_nullable
                  as String,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as int,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as double,
        percentage: null == percentage
            ? _value.percentage
            : percentage // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CategoryBreakdownImpl implements _CategoryBreakdown {
  const _$CategoryBreakdownImpl({
    required this.categoryId,
    required this.categoryName,
    required this.color,
    required this.icon,
    required this.total,
    required this.percentage,
  });

  factory _$CategoryBreakdownImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategoryBreakdownImplFromJson(json);

  @override
  final String categoryId;
  @override
  final String categoryName;
  @override
  final int color;
  @override
  final String icon;
  @override
  final double total;
  @override
  final double percentage;

  @override
  String toString() {
    return 'CategoryBreakdown(categoryId: $categoryId, categoryName: $categoryName, color: $color, icon: $icon, total: $total, percentage: $percentage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryBreakdownImpl &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    categoryId,
    categoryName,
    color,
    icon,
    total,
    percentage,
  );

  /// Create a copy of CategoryBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryBreakdownImplCopyWith<_$CategoryBreakdownImpl> get copyWith =>
      __$$CategoryBreakdownImplCopyWithImpl<_$CategoryBreakdownImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CategoryBreakdownImplToJson(this);
  }
}

abstract class _CategoryBreakdown implements CategoryBreakdown {
  const factory _CategoryBreakdown({
    required final String categoryId,
    required final String categoryName,
    required final int color,
    required final String icon,
    required final double total,
    required final double percentage,
  }) = _$CategoryBreakdownImpl;

  factory _CategoryBreakdown.fromJson(Map<String, dynamic> json) =
      _$CategoryBreakdownImpl.fromJson;

  @override
  String get categoryId;
  @override
  String get categoryName;
  @override
  int get color;
  @override
  String get icon;
  @override
  double get total;
  @override
  double get percentage;

  /// Create a copy of CategoryBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategoryBreakdownImplCopyWith<_$CategoryBreakdownImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyTrend _$DailyTrendFromJson(Map<String, dynamic> json) {
  return _DailyTrend.fromJson(json);
}

/// @nodoc
mixin _$DailyTrend {
  DateTime get date => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;

  /// Serializes this DailyTrend to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyTrend
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyTrendCopyWith<DailyTrend> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyTrendCopyWith<$Res> {
  factory $DailyTrendCopyWith(
    DailyTrend value,
    $Res Function(DailyTrend) then,
  ) = _$DailyTrendCopyWithImpl<$Res, DailyTrend>;
  @useResult
  $Res call({DateTime date, double total});
}

/// @nodoc
class _$DailyTrendCopyWithImpl<$Res, $Val extends DailyTrend>
    implements $DailyTrendCopyWith<$Res> {
  _$DailyTrendCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyTrend
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? date = null, Object? total = null}) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyTrendImplCopyWith<$Res>
    implements $DailyTrendCopyWith<$Res> {
  factory _$$DailyTrendImplCopyWith(
    _$DailyTrendImpl value,
    $Res Function(_$DailyTrendImpl) then,
  ) = __$$DailyTrendImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, double total});
}

/// @nodoc
class __$$DailyTrendImplCopyWithImpl<$Res>
    extends _$DailyTrendCopyWithImpl<$Res, _$DailyTrendImpl>
    implements _$$DailyTrendImplCopyWith<$Res> {
  __$$DailyTrendImplCopyWithImpl(
    _$DailyTrendImpl _value,
    $Res Function(_$DailyTrendImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyTrend
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? date = null, Object? total = null}) {
    return _then(
      _$DailyTrendImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyTrendImpl implements _DailyTrend {
  const _$DailyTrendImpl({required this.date, required this.total});

  factory _$DailyTrendImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyTrendImplFromJson(json);

  @override
  final DateTime date;
  @override
  final double total;

  @override
  String toString() {
    return 'DailyTrend(date: $date, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyTrendImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, total);

  /// Create a copy of DailyTrend
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyTrendImplCopyWith<_$DailyTrendImpl> get copyWith =>
      __$$DailyTrendImplCopyWithImpl<_$DailyTrendImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyTrendImplToJson(this);
  }
}

abstract class _DailyTrend implements DailyTrend {
  const factory _DailyTrend({
    required final DateTime date,
    required final double total,
  }) = _$DailyTrendImpl;

  factory _DailyTrend.fromJson(Map<String, dynamic> json) =
      _$DailyTrendImpl.fromJson;

  @override
  DateTime get date;
  @override
  double get total;

  /// Create a copy of DailyTrend
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyTrendImplCopyWith<_$DailyTrendImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MonthOverMonthComparison _$MonthOverMonthComparisonFromJson(
  Map<String, dynamic> json,
) {
  return _MonthOverMonthComparison.fromJson(json);
}

/// @nodoc
mixin _$MonthOverMonthComparison {
  double get currentTotal => throw _privateConstructorUsedError;
  double get previousTotal => throw _privateConstructorUsedError;
  double get changePercent => throw _privateConstructorUsedError;

  /// Serializes this MonthOverMonthComparison to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MonthOverMonthComparison
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthOverMonthComparisonCopyWith<MonthOverMonthComparison> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthOverMonthComparisonCopyWith<$Res> {
  factory $MonthOverMonthComparisonCopyWith(
    MonthOverMonthComparison value,
    $Res Function(MonthOverMonthComparison) then,
  ) = _$MonthOverMonthComparisonCopyWithImpl<$Res, MonthOverMonthComparison>;
  @useResult
  $Res call({double currentTotal, double previousTotal, double changePercent});
}

/// @nodoc
class _$MonthOverMonthComparisonCopyWithImpl<
  $Res,
  $Val extends MonthOverMonthComparison
>
    implements $MonthOverMonthComparisonCopyWith<$Res> {
  _$MonthOverMonthComparisonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthOverMonthComparison
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentTotal = null,
    Object? previousTotal = null,
    Object? changePercent = null,
  }) {
    return _then(
      _value.copyWith(
            currentTotal: null == currentTotal
                ? _value.currentTotal
                : currentTotal // ignore: cast_nullable_to_non_nullable
                      as double,
            previousTotal: null == previousTotal
                ? _value.previousTotal
                : previousTotal // ignore: cast_nullable_to_non_nullable
                      as double,
            changePercent: null == changePercent
                ? _value.changePercent
                : changePercent // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MonthOverMonthComparisonImplCopyWith<$Res>
    implements $MonthOverMonthComparisonCopyWith<$Res> {
  factory _$$MonthOverMonthComparisonImplCopyWith(
    _$MonthOverMonthComparisonImpl value,
    $Res Function(_$MonthOverMonthComparisonImpl) then,
  ) = __$$MonthOverMonthComparisonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double currentTotal, double previousTotal, double changePercent});
}

/// @nodoc
class __$$MonthOverMonthComparisonImplCopyWithImpl<$Res>
    extends
        _$MonthOverMonthComparisonCopyWithImpl<
          $Res,
          _$MonthOverMonthComparisonImpl
        >
    implements _$$MonthOverMonthComparisonImplCopyWith<$Res> {
  __$$MonthOverMonthComparisonImplCopyWithImpl(
    _$MonthOverMonthComparisonImpl _value,
    $Res Function(_$MonthOverMonthComparisonImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MonthOverMonthComparison
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentTotal = null,
    Object? previousTotal = null,
    Object? changePercent = null,
  }) {
    return _then(
      _$MonthOverMonthComparisonImpl(
        currentTotal: null == currentTotal
            ? _value.currentTotal
            : currentTotal // ignore: cast_nullable_to_non_nullable
                  as double,
        previousTotal: null == previousTotal
            ? _value.previousTotal
            : previousTotal // ignore: cast_nullable_to_non_nullable
                  as double,
        changePercent: null == changePercent
            ? _value.changePercent
            : changePercent // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MonthOverMonthComparisonImpl implements _MonthOverMonthComparison {
  const _$MonthOverMonthComparisonImpl({
    required this.currentTotal,
    required this.previousTotal,
    required this.changePercent,
  });

  factory _$MonthOverMonthComparisonImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonthOverMonthComparisonImplFromJson(json);

  @override
  final double currentTotal;
  @override
  final double previousTotal;
  @override
  final double changePercent;

  @override
  String toString() {
    return 'MonthOverMonthComparison(currentTotal: $currentTotal, previousTotal: $previousTotal, changePercent: $changePercent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthOverMonthComparisonImpl &&
            (identical(other.currentTotal, currentTotal) ||
                other.currentTotal == currentTotal) &&
            (identical(other.previousTotal, previousTotal) ||
                other.previousTotal == previousTotal) &&
            (identical(other.changePercent, changePercent) ||
                other.changePercent == changePercent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, currentTotal, previousTotal, changePercent);

  /// Create a copy of MonthOverMonthComparison
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthOverMonthComparisonImplCopyWith<_$MonthOverMonthComparisonImpl>
  get copyWith =>
      __$$MonthOverMonthComparisonImplCopyWithImpl<
        _$MonthOverMonthComparisonImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MonthOverMonthComparisonImplToJson(this);
  }
}

abstract class _MonthOverMonthComparison implements MonthOverMonthComparison {
  const factory _MonthOverMonthComparison({
    required final double currentTotal,
    required final double previousTotal,
    required final double changePercent,
  }) = _$MonthOverMonthComparisonImpl;

  factory _MonthOverMonthComparison.fromJson(Map<String, dynamic> json) =
      _$MonthOverMonthComparisonImpl.fromJson;

  @override
  double get currentTotal;
  @override
  double get previousTotal;
  @override
  double get changePercent;

  /// Create a copy of MonthOverMonthComparison
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthOverMonthComparisonImplCopyWith<_$MonthOverMonthComparisonImpl>
  get copyWith => throw _privateConstructorUsedError;
}
