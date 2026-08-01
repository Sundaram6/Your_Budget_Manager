// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'savings_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SavingsGoalModel _$SavingsGoalModelFromJson(Map<String, dynamic> json) {
  return _SavingsGoalModel.fromJson(json);
}

/// @nodoc
mixin _$SavingsGoalModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get targetAmount => throw _privateConstructorUsedError;
  double get currentAmount => throw _privateConstructorUsedError;
  String? get categoryId => throw _privateConstructorUsedError;
  DateTime? get targetDate => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  SavingsGoalStatus get status => throw _privateConstructorUsedError;
  String get iconName => throw _privateConstructorUsedError;
  String get colorHex => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SavingsGoalModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SavingsGoalModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SavingsGoalModelCopyWith<SavingsGoalModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SavingsGoalModelCopyWith<$Res> {
  factory $SavingsGoalModelCopyWith(
    SavingsGoalModel value,
    $Res Function(SavingsGoalModel) then,
  ) = _$SavingsGoalModelCopyWithImpl<$Res, SavingsGoalModel>;
  @useResult
  $Res call({
    String id,
    String name,
    double targetAmount,
    double currentAmount,
    String? categoryId,
    DateTime? targetDate,
    DateTime startDate,
    SavingsGoalStatus status,
    String iconName,
    String colorHex,
    String? note,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$SavingsGoalModelCopyWithImpl<$Res, $Val extends SavingsGoalModel>
    implements $SavingsGoalModelCopyWith<$Res> {
  _$SavingsGoalModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SavingsGoalModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? targetAmount = null,
    Object? currentAmount = null,
    Object? categoryId = freezed,
    Object? targetDate = freezed,
    Object? startDate = null,
    Object? status = null,
    Object? iconName = null,
    Object? colorHex = null,
    Object? note = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            targetAmount: null == targetAmount
                ? _value.targetAmount
                : targetAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            currentAmount: null == currentAmount
                ? _value.currentAmount
                : currentAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            categoryId: freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String?,
            targetDate: freezed == targetDate
                ? _value.targetDate
                : targetDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SavingsGoalStatus,
            iconName: null == iconName
                ? _value.iconName
                : iconName // ignore: cast_nullable_to_non_nullable
                      as String,
            colorHex: null == colorHex
                ? _value.colorHex
                : colorHex // ignore: cast_nullable_to_non_nullable
                      as String,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
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
abstract class _$$SavingsGoalModelImplCopyWith<$Res>
    implements $SavingsGoalModelCopyWith<$Res> {
  factory _$$SavingsGoalModelImplCopyWith(
    _$SavingsGoalModelImpl value,
    $Res Function(_$SavingsGoalModelImpl) then,
  ) = __$$SavingsGoalModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    double targetAmount,
    double currentAmount,
    String? categoryId,
    DateTime? targetDate,
    DateTime startDate,
    SavingsGoalStatus status,
    String iconName,
    String colorHex,
    String? note,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$SavingsGoalModelImplCopyWithImpl<$Res>
    extends _$SavingsGoalModelCopyWithImpl<$Res, _$SavingsGoalModelImpl>
    implements _$$SavingsGoalModelImplCopyWith<$Res> {
  __$$SavingsGoalModelImplCopyWithImpl(
    _$SavingsGoalModelImpl _value,
    $Res Function(_$SavingsGoalModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SavingsGoalModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? targetAmount = null,
    Object? currentAmount = null,
    Object? categoryId = freezed,
    Object? targetDate = freezed,
    Object? startDate = null,
    Object? status = null,
    Object? iconName = null,
    Object? colorHex = null,
    Object? note = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$SavingsGoalModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        targetAmount: null == targetAmount
            ? _value.targetAmount
            : targetAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        currentAmount: null == currentAmount
            ? _value.currentAmount
            : currentAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        categoryId: freezed == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String?,
        targetDate: freezed == targetDate
            ? _value.targetDate
            : targetDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SavingsGoalStatus,
        iconName: null == iconName
            ? _value.iconName
            : iconName // ignore: cast_nullable_to_non_nullable
                  as String,
        colorHex: null == colorHex
            ? _value.colorHex
            : colorHex // ignore: cast_nullable_to_non_nullable
                  as String,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
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
class _$SavingsGoalModelImpl extends _SavingsGoalModel {
  const _$SavingsGoalModelImpl({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.categoryId,
    this.targetDate,
    required this.startDate,
    required this.status,
    required this.iconName,
    required this.colorHex,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();

  factory _$SavingsGoalModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SavingsGoalModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final double targetAmount;
  @override
  final double currentAmount;
  @override
  final String? categoryId;
  @override
  final DateTime? targetDate;
  @override
  final DateTime startDate;
  @override
  final SavingsGoalStatus status;
  @override
  final String iconName;
  @override
  final String colorHex;
  @override
  final String? note;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'SavingsGoalModel(id: $id, name: $name, targetAmount: $targetAmount, currentAmount: $currentAmount, categoryId: $categoryId, targetDate: $targetDate, startDate: $startDate, status: $status, iconName: $iconName, colorHex: $colorHex, note: $note, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SavingsGoalModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.targetAmount, targetAmount) ||
                other.targetAmount == targetAmount) &&
            (identical(other.currentAmount, currentAmount) ||
                other.currentAmount == currentAmount) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.targetDate, targetDate) ||
                other.targetDate == targetDate) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.iconName, iconName) ||
                other.iconName == iconName) &&
            (identical(other.colorHex, colorHex) ||
                other.colorHex == colorHex) &&
            (identical(other.note, note) || other.note == note) &&
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
    name,
    targetAmount,
    currentAmount,
    categoryId,
    targetDate,
    startDate,
    status,
    iconName,
    colorHex,
    note,
    createdAt,
    updatedAt,
  );

  /// Create a copy of SavingsGoalModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SavingsGoalModelImplCopyWith<_$SavingsGoalModelImpl> get copyWith =>
      __$$SavingsGoalModelImplCopyWithImpl<_$SavingsGoalModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SavingsGoalModelImplToJson(this);
  }
}

abstract class _SavingsGoalModel extends SavingsGoalModel {
  const factory _SavingsGoalModel({
    required final String id,
    required final String name,
    required final double targetAmount,
    required final double currentAmount,
    final String? categoryId,
    final DateTime? targetDate,
    required final DateTime startDate,
    required final SavingsGoalStatus status,
    required final String iconName,
    required final String colorHex,
    final String? note,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$SavingsGoalModelImpl;
  const _SavingsGoalModel._() : super._();

  factory _SavingsGoalModel.fromJson(Map<String, dynamic> json) =
      _$SavingsGoalModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  double get targetAmount;
  @override
  double get currentAmount;
  @override
  String? get categoryId;
  @override
  DateTime? get targetDate;
  @override
  DateTime get startDate;
  @override
  SavingsGoalStatus get status;
  @override
  String get iconName;
  @override
  String get colorHex;
  @override
  String? get note;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of SavingsGoalModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SavingsGoalModelImplCopyWith<_$SavingsGoalModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
