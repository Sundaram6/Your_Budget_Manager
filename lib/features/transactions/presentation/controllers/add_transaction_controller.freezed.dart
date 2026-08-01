// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'add_transaction_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AddTransactionState {
  double get amount => throw _privateConstructorUsedError;
  TransactionType get type => throw _privateConstructorUsedError;
  String? get selectedCategoryId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;
  bool get isSaving => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of AddTransactionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AddTransactionStateCopyWith<AddTransactionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddTransactionStateCopyWith<$Res> {
  factory $AddTransactionStateCopyWith(
    AddTransactionState value,
    $Res Function(AddTransactionState) then,
  ) = _$AddTransactionStateCopyWithImpl<$Res, AddTransactionState>;
  @useResult
  $Res call({
    double amount,
    TransactionType type,
    String? selectedCategoryId,
    DateTime date,
    String note,
    bool isSaving,
    String? error,
  });
}

/// @nodoc
class _$AddTransactionStateCopyWithImpl<$Res, $Val extends AddTransactionState>
    implements $AddTransactionStateCopyWith<$Res> {
  _$AddTransactionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AddTransactionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = null,
    Object? type = null,
    Object? selectedCategoryId = freezed,
    Object? date = null,
    Object? note = null,
    Object? isSaving = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as TransactionType,
            selectedCategoryId: freezed == selectedCategoryId
                ? _value.selectedCategoryId
                : selectedCategoryId // ignore: cast_nullable_to_non_nullable
                      as String?,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            note: null == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String,
            isSaving: null == isSaving
                ? _value.isSaving
                : isSaving // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AddTransactionStateImplCopyWith<$Res>
    implements $AddTransactionStateCopyWith<$Res> {
  factory _$$AddTransactionStateImplCopyWith(
    _$AddTransactionStateImpl value,
    $Res Function(_$AddTransactionStateImpl) then,
  ) = __$$AddTransactionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double amount,
    TransactionType type,
    String? selectedCategoryId,
    DateTime date,
    String note,
    bool isSaving,
    String? error,
  });
}

/// @nodoc
class __$$AddTransactionStateImplCopyWithImpl<$Res>
    extends _$AddTransactionStateCopyWithImpl<$Res, _$AddTransactionStateImpl>
    implements _$$AddTransactionStateImplCopyWith<$Res> {
  __$$AddTransactionStateImplCopyWithImpl(
    _$AddTransactionStateImpl _value,
    $Res Function(_$AddTransactionStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AddTransactionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = null,
    Object? type = null,
    Object? selectedCategoryId = freezed,
    Object? date = null,
    Object? note = null,
    Object? isSaving = null,
    Object? error = freezed,
  }) {
    return _then(
      _$AddTransactionStateImpl(
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as TransactionType,
        selectedCategoryId: freezed == selectedCategoryId
            ? _value.selectedCategoryId
            : selectedCategoryId // ignore: cast_nullable_to_non_nullable
                  as String?,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        note: null == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String,
        isSaving: null == isSaving
            ? _value.isSaving
            : isSaving // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$AddTransactionStateImpl implements _AddTransactionState {
  const _$AddTransactionStateImpl({
    this.amount = 0.0,
    this.type = TransactionType.expense,
    this.selectedCategoryId,
    required this.date,
    this.note = '',
    this.isSaving = false,
    this.error,
  });

  @override
  @JsonKey()
  final double amount;
  @override
  @JsonKey()
  final TransactionType type;
  @override
  final String? selectedCategoryId;
  @override
  final DateTime date;
  @override
  @JsonKey()
  final String note;
  @override
  @JsonKey()
  final bool isSaving;
  @override
  final String? error;

  @override
  String toString() {
    return 'AddTransactionState(amount: $amount, type: $type, selectedCategoryId: $selectedCategoryId, date: $date, note: $note, isSaving: $isSaving, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddTransactionStateImpl &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.selectedCategoryId, selectedCategoryId) ||
                other.selectedCategoryId == selectedCategoryId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.isSaving, isSaving) ||
                other.isSaving == isSaving) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    amount,
    type,
    selectedCategoryId,
    date,
    note,
    isSaving,
    error,
  );

  /// Create a copy of AddTransactionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddTransactionStateImplCopyWith<_$AddTransactionStateImpl> get copyWith =>
      __$$AddTransactionStateImplCopyWithImpl<_$AddTransactionStateImpl>(
        this,
        _$identity,
      );
}

abstract class _AddTransactionState implements AddTransactionState {
  const factory _AddTransactionState({
    final double amount,
    final TransactionType type,
    final String? selectedCategoryId,
    required final DateTime date,
    final String note,
    final bool isSaving,
    final String? error,
  }) = _$AddTransactionStateImpl;

  @override
  double get amount;
  @override
  TransactionType get type;
  @override
  String? get selectedCategoryId;
  @override
  DateTime get date;
  @override
  String get note;
  @override
  bool get isSaving;
  @override
  String? get error;

  /// Create a copy of AddTransactionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddTransactionStateImplCopyWith<_$AddTransactionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
