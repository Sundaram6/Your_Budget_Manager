// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parsed_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ParsedTransaction _$ParsedTransactionFromJson(Map<String, dynamic> json) {
  return _ParsedTransaction.fromJson(json);
}

/// @nodoc
mixin _$ParsedTransaction {
  String get smsId =>
      throw _privateConstructorUsedError; // unique ID of the SMS
  double get amount => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get merchantName => throw _privateConstructorUsedError;
  String get merchantId => throw _privateConstructorUsedError;
  String get categoryId => throw _privateConstructorUsedError;
  String get originalSmsBody => throw _privateConstructorUsedError;

  /// Serializes this ParsedTransaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParsedTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParsedTransactionCopyWith<ParsedTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParsedTransactionCopyWith<$Res> {
  factory $ParsedTransactionCopyWith(
    ParsedTransaction value,
    $Res Function(ParsedTransaction) then,
  ) = _$ParsedTransactionCopyWithImpl<$Res, ParsedTransaction>;
  @useResult
  $Res call({
    String smsId,
    double amount,
    DateTime date,
    String merchantName,
    String merchantId,
    String categoryId,
    String originalSmsBody,
  });
}

/// @nodoc
class _$ParsedTransactionCopyWithImpl<$Res, $Val extends ParsedTransaction>
    implements $ParsedTransactionCopyWith<$Res> {
  _$ParsedTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParsedTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? smsId = null,
    Object? amount = null,
    Object? date = null,
    Object? merchantName = null,
    Object? merchantId = null,
    Object? categoryId = null,
    Object? originalSmsBody = null,
  }) {
    return _then(
      _value.copyWith(
            smsId: null == smsId
                ? _value.smsId
                : smsId // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            merchantName: null == merchantName
                ? _value.merchantName
                : merchantName // ignore: cast_nullable_to_non_nullable
                      as String,
            merchantId: null == merchantId
                ? _value.merchantId
                : merchantId // ignore: cast_nullable_to_non_nullable
                      as String,
            categoryId: null == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String,
            originalSmsBody: null == originalSmsBody
                ? _value.originalSmsBody
                : originalSmsBody // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ParsedTransactionImplCopyWith<$Res>
    implements $ParsedTransactionCopyWith<$Res> {
  factory _$$ParsedTransactionImplCopyWith(
    _$ParsedTransactionImpl value,
    $Res Function(_$ParsedTransactionImpl) then,
  ) = __$$ParsedTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String smsId,
    double amount,
    DateTime date,
    String merchantName,
    String merchantId,
    String categoryId,
    String originalSmsBody,
  });
}

/// @nodoc
class __$$ParsedTransactionImplCopyWithImpl<$Res>
    extends _$ParsedTransactionCopyWithImpl<$Res, _$ParsedTransactionImpl>
    implements _$$ParsedTransactionImplCopyWith<$Res> {
  __$$ParsedTransactionImplCopyWithImpl(
    _$ParsedTransactionImpl _value,
    $Res Function(_$ParsedTransactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ParsedTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? smsId = null,
    Object? amount = null,
    Object? date = null,
    Object? merchantName = null,
    Object? merchantId = null,
    Object? categoryId = null,
    Object? originalSmsBody = null,
  }) {
    return _then(
      _$ParsedTransactionImpl(
        smsId: null == smsId
            ? _value.smsId
            : smsId // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        merchantName: null == merchantName
            ? _value.merchantName
            : merchantName // ignore: cast_nullable_to_non_nullable
                  as String,
        merchantId: null == merchantId
            ? _value.merchantId
            : merchantId // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryId: null == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String,
        originalSmsBody: null == originalSmsBody
            ? _value.originalSmsBody
            : originalSmsBody // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ParsedTransactionImpl implements _ParsedTransaction {
  const _$ParsedTransactionImpl({
    required this.smsId,
    required this.amount,
    required this.date,
    required this.merchantName,
    required this.merchantId,
    required this.categoryId,
    required this.originalSmsBody,
  });

  factory _$ParsedTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParsedTransactionImplFromJson(json);

  @override
  final String smsId;
  // unique ID of the SMS
  @override
  final double amount;
  @override
  final DateTime date;
  @override
  final String merchantName;
  @override
  final String merchantId;
  @override
  final String categoryId;
  @override
  final String originalSmsBody;

  @override
  String toString() {
    return 'ParsedTransaction(smsId: $smsId, amount: $amount, date: $date, merchantName: $merchantName, merchantId: $merchantId, categoryId: $categoryId, originalSmsBody: $originalSmsBody)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParsedTransactionImpl &&
            (identical(other.smsId, smsId) || other.smsId == smsId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.merchantName, merchantName) ||
                other.merchantName == merchantName) &&
            (identical(other.merchantId, merchantId) ||
                other.merchantId == merchantId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.originalSmsBody, originalSmsBody) ||
                other.originalSmsBody == originalSmsBody));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    smsId,
    amount,
    date,
    merchantName,
    merchantId,
    categoryId,
    originalSmsBody,
  );

  /// Create a copy of ParsedTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParsedTransactionImplCopyWith<_$ParsedTransactionImpl> get copyWith =>
      __$$ParsedTransactionImplCopyWithImpl<_$ParsedTransactionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ParsedTransactionImplToJson(this);
  }
}

abstract class _ParsedTransaction implements ParsedTransaction {
  const factory _ParsedTransaction({
    required final String smsId,
    required final double amount,
    required final DateTime date,
    required final String merchantName,
    required final String merchantId,
    required final String categoryId,
    required final String originalSmsBody,
  }) = _$ParsedTransactionImpl;

  factory _ParsedTransaction.fromJson(Map<String, dynamic> json) =
      _$ParsedTransactionImpl.fromJson;

  @override
  String get smsId; // unique ID of the SMS
  @override
  double get amount;
  @override
  DateTime get date;
  @override
  String get merchantName;
  @override
  String get merchantId;
  @override
  String get categoryId;
  @override
  String get originalSmsBody;

  /// Create a copy of ParsedTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParsedTransactionImplCopyWith<_$ParsedTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
