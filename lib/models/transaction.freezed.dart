// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) {
  return _TransactionModel.fromJson(json);
}

/// @nodoc
mixin _$TransactionModel {
  String get id => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount_paise')
  int get amountPaise => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_id')
  String get categoryId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  @YyyyMmDdConverter()
  DateTime get date => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_recurring')
  bool get isRecurring => throw _privateConstructorUsedError;
  @JsonKey(name: 'recurring_id')
  String? get recurringId => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_auto_captured')
  bool get isAutoCaptured => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_app')
  String? get sourceApp => throw _privateConstructorUsedError;
  @Iso8601Converter()
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TransactionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransactionModelCopyWith<TransactionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionModelCopyWith<$Res> {
  factory $TransactionModelCopyWith(
    TransactionModel value,
    $Res Function(TransactionModel) then,
  ) = _$TransactionModelCopyWithImpl<$Res, TransactionModel>;
  @useResult
  $Res call({
    String id,
    String? title,
    @JsonKey(name: 'amount_paise') int amountPaise,
    @JsonKey(name: 'category_id') String categoryId,
    String type,
    @YyyyMmDdConverter() DateTime date,
    String? notes,
    @JsonKey(name: 'is_recurring') bool isRecurring,
    @JsonKey(name: 'recurring_id') String? recurringId,
    @JsonKey(name: 'is_auto_captured') bool isAutoCaptured,
    @JsonKey(name: 'source_app') String? sourceApp,
    @Iso8601Converter() @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$TransactionModelCopyWithImpl<$Res, $Val extends TransactionModel>
    implements $TransactionModelCopyWith<$Res> {
  _$TransactionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = freezed,
    Object? amountPaise = null,
    Object? categoryId = null,
    Object? type = null,
    Object? date = null,
    Object? notes = freezed,
    Object? isRecurring = null,
    Object? recurringId = freezed,
    Object? isAutoCaptured = null,
    Object? sourceApp = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
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
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            isRecurring: null == isRecurring
                ? _value.isRecurring
                : isRecurring // ignore: cast_nullable_to_non_nullable
                      as bool,
            recurringId: freezed == recurringId
                ? _value.recurringId
                : recurringId // ignore: cast_nullable_to_non_nullable
                      as String?,
            isAutoCaptured: null == isAutoCaptured
                ? _value.isAutoCaptured
                : isAutoCaptured // ignore: cast_nullable_to_non_nullable
                      as bool,
            sourceApp: freezed == sourceApp
                ? _value.sourceApp
                : sourceApp // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TransactionModelImplCopyWith<$Res>
    implements $TransactionModelCopyWith<$Res> {
  factory _$$TransactionModelImplCopyWith(
    _$TransactionModelImpl value,
    $Res Function(_$TransactionModelImpl) then,
  ) = __$$TransactionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? title,
    @JsonKey(name: 'amount_paise') int amountPaise,
    @JsonKey(name: 'category_id') String categoryId,
    String type,
    @YyyyMmDdConverter() DateTime date,
    String? notes,
    @JsonKey(name: 'is_recurring') bool isRecurring,
    @JsonKey(name: 'recurring_id') String? recurringId,
    @JsonKey(name: 'is_auto_captured') bool isAutoCaptured,
    @JsonKey(name: 'source_app') String? sourceApp,
    @Iso8601Converter() @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$$TransactionModelImplCopyWithImpl<$Res>
    extends _$TransactionModelCopyWithImpl<$Res, _$TransactionModelImpl>
    implements _$$TransactionModelImplCopyWith<$Res> {
  __$$TransactionModelImplCopyWithImpl(
    _$TransactionModelImpl _value,
    $Res Function(_$TransactionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = freezed,
    Object? amountPaise = null,
    Object? categoryId = null,
    Object? type = null,
    Object? date = null,
    Object? notes = freezed,
    Object? isRecurring = null,
    Object? recurringId = freezed,
    Object? isAutoCaptured = null,
    Object? sourceApp = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$TransactionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
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
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        isRecurring: null == isRecurring
            ? _value.isRecurring
            : isRecurring // ignore: cast_nullable_to_non_nullable
                  as bool,
        recurringId: freezed == recurringId
            ? _value.recurringId
            : recurringId // ignore: cast_nullable_to_non_nullable
                  as String?,
        isAutoCaptured: null == isAutoCaptured
            ? _value.isAutoCaptured
            : isAutoCaptured // ignore: cast_nullable_to_non_nullable
                  as bool,
        sourceApp: freezed == sourceApp
            ? _value.sourceApp
            : sourceApp // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TransactionModelImpl implements _TransactionModel {
  const _$TransactionModelImpl({
    required this.id,
    this.title,
    @JsonKey(name: 'amount_paise') required this.amountPaise,
    @JsonKey(name: 'category_id') required this.categoryId,
    required this.type,
    @YyyyMmDdConverter() required this.date,
    this.notes,
    @JsonKey(name: 'is_recurring') this.isRecurring = false,
    @JsonKey(name: 'recurring_id') this.recurringId,
    @JsonKey(name: 'is_auto_captured') this.isAutoCaptured = false,
    @JsonKey(name: 'source_app') this.sourceApp,
    @Iso8601Converter() @JsonKey(name: 'created_at') this.createdAt,
  });

  factory _$TransactionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String? title;
  @override
  @JsonKey(name: 'amount_paise')
  final int amountPaise;
  @override
  @JsonKey(name: 'category_id')
  final String categoryId;
  @override
  final String type;
  @override
  @YyyyMmDdConverter()
  final DateTime date;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'is_recurring')
  final bool isRecurring;
  @override
  @JsonKey(name: 'recurring_id')
  final String? recurringId;
  @override
  @JsonKey(name: 'is_auto_captured')
  final bool isAutoCaptured;
  @override
  @JsonKey(name: 'source_app')
  final String? sourceApp;
  @override
  @Iso8601Converter()
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'TransactionModel(id: $id, title: $title, amountPaise: $amountPaise, categoryId: $categoryId, type: $type, date: $date, notes: $notes, isRecurring: $isRecurring, recurringId: $recurringId, isAutoCaptured: $isAutoCaptured, sourceApp: $sourceApp, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.amountPaise, amountPaise) ||
                other.amountPaise == amountPaise) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isRecurring, isRecurring) ||
                other.isRecurring == isRecurring) &&
            (identical(other.recurringId, recurringId) ||
                other.recurringId == recurringId) &&
            (identical(other.isAutoCaptured, isAutoCaptured) ||
                other.isAutoCaptured == isAutoCaptured) &&
            (identical(other.sourceApp, sourceApp) ||
                other.sourceApp == sourceApp) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
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
    date,
    notes,
    isRecurring,
    recurringId,
    isAutoCaptured,
    sourceApp,
    createdAt,
  );

  /// Create a copy of TransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionModelImplCopyWith<_$TransactionModelImpl> get copyWith =>
      __$$TransactionModelImplCopyWithImpl<_$TransactionModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionModelImplToJson(this);
  }
}

abstract class _TransactionModel implements TransactionModel {
  const factory _TransactionModel({
    required final String id,
    final String? title,
    @JsonKey(name: 'amount_paise') required final int amountPaise,
    @JsonKey(name: 'category_id') required final String categoryId,
    required final String type,
    @YyyyMmDdConverter() required final DateTime date,
    final String? notes,
    @JsonKey(name: 'is_recurring') final bool isRecurring,
    @JsonKey(name: 'recurring_id') final String? recurringId,
    @JsonKey(name: 'is_auto_captured') final bool isAutoCaptured,
    @JsonKey(name: 'source_app') final String? sourceApp,
    @Iso8601Converter() @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$TransactionModelImpl;

  factory _TransactionModel.fromJson(Map<String, dynamic> json) =
      _$TransactionModelImpl.fromJson;

  @override
  String get id;
  @override
  String? get title;
  @override
  @JsonKey(name: 'amount_paise')
  int get amountPaise;
  @override
  @JsonKey(name: 'category_id')
  String get categoryId;
  @override
  String get type;
  @override
  @YyyyMmDdConverter()
  DateTime get date;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'is_recurring')
  bool get isRecurring;
  @override
  @JsonKey(name: 'recurring_id')
  String? get recurringId;
  @override
  @JsonKey(name: 'is_auto_captured')
  bool get isAutoCaptured;
  @override
  @JsonKey(name: 'source_app')
  String? get sourceApp;
  @override
  @Iso8601Converter()
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of TransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionModelImplCopyWith<_$TransactionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
