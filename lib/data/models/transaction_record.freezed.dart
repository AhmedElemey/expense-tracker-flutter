// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TransactionRecord _$TransactionRecordFromJson(Map<String, dynamic> json) {
  return _TransactionRecord.fromJson(json);
}

/// @nodoc
mixin _$TransactionRecord {
  int? get id => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  @ExpenseCategoryConverter()
  ExpenseCategory get category => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;

  /// Serializes this TransactionRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TransactionRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransactionRecordCopyWith<TransactionRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionRecordCopyWith<$Res> {
  factory $TransactionRecordCopyWith(
    TransactionRecord value,
    $Res Function(TransactionRecord) then,
  ) = _$TransactionRecordCopyWithImpl<$Res, TransactionRecord>;
  @useResult
  $Res call({
    int? id,
    double amount,
    @ExpenseCategoryConverter() ExpenseCategory category,
    DateTime date,
    String? note,
  });
}

/// @nodoc
class _$TransactionRecordCopyWithImpl<$Res, $Val extends TransactionRecord>
    implements $TransactionRecordCopyWith<$Res> {
  _$TransactionRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TransactionRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? amount = null,
    Object? category = null,
    Object? date = null,
    Object? note = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as ExpenseCategory,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TransactionRecordImplCopyWith<$Res>
    implements $TransactionRecordCopyWith<$Res> {
  factory _$$TransactionRecordImplCopyWith(
    _$TransactionRecordImpl value,
    $Res Function(_$TransactionRecordImpl) then,
  ) = __$$TransactionRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    double amount,
    @ExpenseCategoryConverter() ExpenseCategory category,
    DateTime date,
    String? note,
  });
}

/// @nodoc
class __$$TransactionRecordImplCopyWithImpl<$Res>
    extends _$TransactionRecordCopyWithImpl<$Res, _$TransactionRecordImpl>
    implements _$$TransactionRecordImplCopyWith<$Res> {
  __$$TransactionRecordImplCopyWithImpl(
    _$TransactionRecordImpl _value,
    $Res Function(_$TransactionRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TransactionRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? amount = null,
    Object? category = null,
    Object? date = null,
    Object? note = freezed,
  }) {
    return _then(
      _$TransactionRecordImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as ExpenseCategory,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TransactionRecordImpl extends _TransactionRecord {
  const _$TransactionRecordImpl({
    this.id,
    required this.amount,
    @ExpenseCategoryConverter() required this.category,
    required this.date,
    this.note,
  }) : super._();

  factory _$TransactionRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionRecordImplFromJson(json);

  @override
  final int? id;
  @override
  final double amount;
  @override
  @ExpenseCategoryConverter()
  final ExpenseCategory category;
  @override
  final DateTime date;
  @override
  final String? note;

  @override
  String toString() {
    return 'TransactionRecord(id: $id, amount: $amount, category: $category, date: $date, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, amount, category, date, note);

  /// Create a copy of TransactionRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionRecordImplCopyWith<_$TransactionRecordImpl> get copyWith =>
      __$$TransactionRecordImplCopyWithImpl<_$TransactionRecordImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionRecordImplToJson(this);
  }
}

abstract class _TransactionRecord extends TransactionRecord {
  const factory _TransactionRecord({
    final int? id,
    required final double amount,
    @ExpenseCategoryConverter() required final ExpenseCategory category,
    required final DateTime date,
    final String? note,
  }) = _$TransactionRecordImpl;
  const _TransactionRecord._() : super._();

  factory _TransactionRecord.fromJson(Map<String, dynamic> json) =
      _$TransactionRecordImpl.fromJson;

  @override
  int? get id;
  @override
  double get amount;
  @override
  @ExpenseCategoryConverter()
  ExpenseCategory get category;
  @override
  DateTime get date;
  @override
  String? get note;

  /// Create a copy of TransactionRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionRecordImplCopyWith<_$TransactionRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
