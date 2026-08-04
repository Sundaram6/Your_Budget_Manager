// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RecurringTransactionModel _$RecurringTransactionModelFromJson(
  Map<String, dynamic> json,
) {
  return _RecurringTransactionModel.fromJson(json);
}

/// @nodoc
mixin _$RecurringTransactionModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount_paise')
  int get amountPaise => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_id')
  String get categoryId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get frequency => throw _privateConstructorUsedError;
  @JsonKey(name: 'interval_days')
  int? get intervalDays => throw _privateConstructorUsedError;
  @YyyyMmDdConverter()
  @JsonKey(name: 'start_date')
  DateTime get startDate => throw _privateConstructorUsedError;
  @NullableYyyyMmDdConverter()
  @JsonKey(name: 'end_date')
  DateTime? get endDate => throw _privateConstructorUsedError;
  @YyyyMmDdConverter()
  @JsonKey(name: 'next_due_date')
  DateTime get nextDueDate => throw _privateConstructorUsedError;
  @NullableYyyyMmDdConverter()
  @JsonKey(name: 'last_generated_date')
  DateTime? get lastGeneratedDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'auto_confirm')
  bool get autoConfirm => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @Iso8601Converter()
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @Iso8601Converter()
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this RecurringTransactionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecurringTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecurringTransactionModelCopyWith<RecurringTransactionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecurringTransactionModelCopyWith<$Res> {
  factory $RecurringTransactionModelCopyWith(
    RecurringTransactionModel value,
    $Res Function(RecurringTransactionModel) then,
  ) = _$RecurringTransactionModelCopyWithImpl<$Res, RecurringTransactionModel>;
  @useResult
  $Res call({
    String id,
    String title,
    @JsonKey(name: 'amount_paise') int amountPaise,
    @JsonKey(name: 'category_id') String categoryId,
    String type,
    String frequency,
    @JsonKey(name: 'interval_days') int? intervalDays,
    @YyyyMmDdConverter() @JsonKey(name: 'start_date') DateTime startDate,
    @NullableYyyyMmDdConverter() @JsonKey(name: 'end_date') DateTime? endDate,
    @YyyyMmDdConverter() @JsonKey(name: 'next_due_date') DateTime nextDueDate,
    @NullableYyyyMmDdConverter()
    @JsonKey(name: 'last_generated_date')
    DateTime? lastGeneratedDate,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'auto_confirm') bool autoConfirm,
    String? notes,
    @Iso8601Converter() @JsonKey(name: 'created_at') DateTime createdAt,
    @Iso8601Converter() @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$RecurringTransactionModelCopyWithImpl<
  $Res,
  $Val extends RecurringTransactionModel
>
    implements $RecurringTransactionModelCopyWith<$Res> {
  _$RecurringTransactionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecurringTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? amountPaise = null,
    Object? categoryId = null,
    Object? type = null,
    Object? frequency = null,
    Object? intervalDays = freezed,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? nextDueDate = null,
    Object? lastGeneratedDate = freezed,
    Object? isActive = null,
    Object? autoConfirm = null,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            amountPaise: null == amountPaise
                ? _value.amountPaise
                : amountPaise // ignore: cast_nullable_to_non_nullable
                      as int,
            categoryId: null == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            frequency: null == frequency
                ? _value.frequency
                : frequency // ignore: cast_nullable_to_non_nullable
                      as String,
            intervalDays: freezed == intervalDays
                ? _value.intervalDays
                : intervalDays // ignore: cast_nullable_to_non_nullable
                      as int?,
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDate: freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            nextDueDate: null == nextDueDate
                ? _value.nextDueDate
                : nextDueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastGeneratedDate: freezed == lastGeneratedDate
                ? _value.lastGeneratedDate
                : lastGeneratedDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            autoConfirm: null == autoConfirm
                ? _value.autoConfirm
                : autoConfirm // ignore: cast_nullable_to_non_nullable
                      as bool,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecurringTransactionModelImplCopyWith<$Res>
    implements $RecurringTransactionModelCopyWith<$Res> {
  factory _$$RecurringTransactionModelImplCopyWith(
    _$RecurringTransactionModelImpl value,
    $Res Function(_$RecurringTransactionModelImpl) then,
  ) = __$$RecurringTransactionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    @JsonKey(name: 'amount_paise') int amountPaise,
    @JsonKey(name: 'category_id') String categoryId,
    String type,
    String frequency,
    @JsonKey(name: 'interval_days') int? intervalDays,
    @YyyyMmDdConverter() @JsonKey(name: 'start_date') DateTime startDate,
    @NullableYyyyMmDdConverter() @JsonKey(name: 'end_date') DateTime? endDate,
    @YyyyMmDdConverter() @JsonKey(name: 'next_due_date') DateTime nextDueDate,
    @NullableYyyyMmDdConverter()
    @JsonKey(name: 'last_generated_date')
    DateTime? lastGeneratedDate,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'auto_confirm') bool autoConfirm,
    String? notes,
    @Iso8601Converter() @JsonKey(name: 'created_at') DateTime createdAt,
    @Iso8601Converter() @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$RecurringTransactionModelImplCopyWithImpl<$Res>
    extends
        _$RecurringTransactionModelCopyWithImpl<
          $Res,
          _$RecurringTransactionModelImpl
        >
    implements _$$RecurringTransactionModelImplCopyWith<$Res> {
  __$$RecurringTransactionModelImplCopyWithImpl(
    _$RecurringTransactionModelImpl _value,
    $Res Function(_$RecurringTransactionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecurringTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? amountPaise = null,
    Object? categoryId = null,
    Object? type = null,
    Object? frequency = null,
    Object? intervalDays = freezed,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? nextDueDate = null,
    Object? lastGeneratedDate = freezed,
    Object? isActive = null,
    Object? autoConfirm = null,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$RecurringTransactionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        amountPaise: null == amountPaise
            ? _value.amountPaise
            : amountPaise // ignore: cast_nullable_to_non_nullable
                  as int,
        categoryId: null == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        frequency: null == frequency
            ? _value.frequency
            : frequency // ignore: cast_nullable_to_non_nullable
                  as String,
        intervalDays: freezed == intervalDays
            ? _value.intervalDays
            : intervalDays // ignore: cast_nullable_to_non_nullable
                  as int?,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        nextDueDate: null == nextDueDate
            ? _value.nextDueDate
            : nextDueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastGeneratedDate: freezed == lastGeneratedDate
            ? _value.lastGeneratedDate
            : lastGeneratedDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        autoConfirm: null == autoConfirm
            ? _value.autoConfirm
            : autoConfirm // ignore: cast_nullable_to_non_nullable
                  as bool,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecurringTransactionModelImpl implements _RecurringTransactionModel {
  const _$RecurringTransactionModelImpl({
    required this.id,
    required this.title,
    @JsonKey(name: 'amount_paise') required this.amountPaise,
    @JsonKey(name: 'category_id') required this.categoryId,
    required this.type,
    required this.frequency,
    @JsonKey(name: 'interval_days') this.intervalDays,
    @YyyyMmDdConverter() @JsonKey(name: 'start_date') required this.startDate,
    @NullableYyyyMmDdConverter() @JsonKey(name: 'end_date') this.endDate,
    @YyyyMmDdConverter()
    @JsonKey(name: 'next_due_date')
    required this.nextDueDate,
    @NullableYyyyMmDdConverter()
    @JsonKey(name: 'last_generated_date')
    this.lastGeneratedDate,
    @JsonKey(name: 'is_active') this.isActive = true,
    @JsonKey(name: 'auto_confirm') this.autoConfirm = false,
    this.notes,
    @Iso8601Converter() @JsonKey(name: 'created_at') required this.createdAt,
    @Iso8601Converter() @JsonKey(name: 'updated_at') required this.updatedAt,
  });

  factory _$RecurringTransactionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecurringTransactionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  @JsonKey(name: 'amount_paise')
  final int amountPaise;
  @override
  @JsonKey(name: 'category_id')
  final String categoryId;
  @override
  final String type;
  @override
  final String frequency;
  @override
  @JsonKey(name: 'interval_days')
  final int? intervalDays;
  @override
  @YyyyMmDdConverter()
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @override
  @NullableYyyyMmDdConverter()
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  @override
  @YyyyMmDdConverter()
  @JsonKey(name: 'next_due_date')
  final DateTime nextDueDate;
  @override
  @NullableYyyyMmDdConverter()
  @JsonKey(name: 'last_generated_date')
  final DateTime? lastGeneratedDate;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'auto_confirm')
  final bool autoConfirm;
  @override
  final String? notes;
  @override
  @Iso8601Converter()
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @Iso8601Converter()
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'RecurringTransactionModel(id: $id, title: $title, amountPaise: $amountPaise, categoryId: $categoryId, type: $type, frequency: $frequency, intervalDays: $intervalDays, startDate: $startDate, endDate: $endDate, nextDueDate: $nextDueDate, lastGeneratedDate: $lastGeneratedDate, isActive: $isActive, autoConfirm: $autoConfirm, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecurringTransactionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.amountPaise, amountPaise) ||
                other.amountPaise == amountPaise) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.intervalDays, intervalDays) ||
                other.intervalDays == intervalDays) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.nextDueDate, nextDueDate) ||
                other.nextDueDate == nextDueDate) &&
            (identical(other.lastGeneratedDate, lastGeneratedDate) ||
                other.lastGeneratedDate == lastGeneratedDate) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.autoConfirm, autoConfirm) ||
                other.autoConfirm == autoConfirm) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    amountPaise,
    categoryId,
    type,
    frequency,
    intervalDays,
    startDate,
    endDate,
    nextDueDate,
    lastGeneratedDate,
    isActive,
    autoConfirm,
    notes,
    createdAt,
    updatedAt,
  );

  /// Create a copy of RecurringTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecurringTransactionModelImplCopyWith<_$RecurringTransactionModelImpl>
  get copyWith =>
      __$$RecurringTransactionModelImplCopyWithImpl<
        _$RecurringTransactionModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecurringTransactionModelImplToJson(this);
  }
}

abstract class _RecurringTransactionModel implements RecurringTransactionModel {
  const factory _RecurringTransactionModel({
    required final String id,
    required final String title,
    @JsonKey(name: 'amount_paise') required final int amountPaise,
    @JsonKey(name: 'category_id') required final String categoryId,
    required final String type,
    required final String frequency,
    @JsonKey(name: 'interval_days') final int? intervalDays,
    @YyyyMmDdConverter()
    @JsonKey(name: 'start_date')
    required final DateTime startDate,
    @NullableYyyyMmDdConverter()
    @JsonKey(name: 'end_date')
    final DateTime? endDate,
    @YyyyMmDdConverter()
    @JsonKey(name: 'next_due_date')
    required final DateTime nextDueDate,
    @NullableYyyyMmDdConverter()
    @JsonKey(name: 'last_generated_date')
    final DateTime? lastGeneratedDate,
    @JsonKey(name: 'is_active') final bool isActive,
    @JsonKey(name: 'auto_confirm') final bool autoConfirm,
    final String? notes,
    @Iso8601Converter()
    @JsonKey(name: 'created_at')
    required final DateTime createdAt,
    @Iso8601Converter()
    @JsonKey(name: 'updated_at')
    required final DateTime updatedAt,
  }) = _$RecurringTransactionModelImpl;

  factory _RecurringTransactionModel.fromJson(Map<String, dynamic> json) =
      _$RecurringTransactionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  @JsonKey(name: 'amount_paise')
  int get amountPaise;
  @override
  @JsonKey(name: 'category_id')
  String get categoryId;
  @override
  String get type;
  @override
  String get frequency;
  @override
  @JsonKey(name: 'interval_days')
  int? get intervalDays;
  @override
  @YyyyMmDdConverter()
  @JsonKey(name: 'start_date')
  DateTime get startDate;
  @override
  @NullableYyyyMmDdConverter()
  @JsonKey(name: 'end_date')
  DateTime? get endDate;
  @override
  @YyyyMmDdConverter()
  @JsonKey(name: 'next_due_date')
  DateTime get nextDueDate;
  @override
  @NullableYyyyMmDdConverter()
  @JsonKey(name: 'last_generated_date')
  DateTime? get lastGeneratedDate;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'auto_confirm')
  bool get autoConfirm;
  @override
  String? get notes;
  @override
  @Iso8601Converter()
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @Iso8601Converter()
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of RecurringTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecurringTransactionModelImplCopyWith<_$RecurringTransactionModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
