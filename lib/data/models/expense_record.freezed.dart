// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExpenseRecord _$ExpenseRecordFromJson(Map<String, dynamic> json) {
  return _ExpenseRecord.fromJson(json);
}

/// @nodoc
mixin _$ExpenseRecord {
  int? get id => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  @ExpenseCategoryConverter()
  ExpenseCategory get category => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get customCategory => throw _privateConstructorUsedError;

  /// Serializes this ExpenseRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExpenseRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExpenseRecordCopyWith<ExpenseRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpenseRecordCopyWith<$Res> {
  factory $ExpenseRecordCopyWith(
    ExpenseRecord value,
    $Res Function(ExpenseRecord) then,
  ) = _$ExpenseRecordCopyWithImpl<$Res, ExpenseRecord>;
  @useResult
  $Res call({
    int? id,
    double amount,
    @ExpenseCategoryConverter() ExpenseCategory category,
    DateTime date,
    String? note,
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? customCategory,
  });
}

/// @nodoc
class _$ExpenseRecordCopyWithImpl<$Res, $Val extends ExpenseRecord>
    implements $ExpenseRecordCopyWith<$Res> {
  _$ExpenseRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExpenseRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? amount = null,
    Object? category = null,
    Object? date = null,
    Object? note = freezed,
    Object? customCategory = freezed,
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
            customCategory: freezed == customCategory
                ? _value.customCategory
                : customCategory // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExpenseRecordImplCopyWith<$Res>
    implements $ExpenseRecordCopyWith<$Res> {
  factory _$$ExpenseRecordImplCopyWith(
    _$ExpenseRecordImpl value,
    $Res Function(_$ExpenseRecordImpl) then,
  ) = __$$ExpenseRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    double amount,
    @ExpenseCategoryConverter() ExpenseCategory category,
    DateTime date,
    String? note,
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? customCategory,
  });
}

/// @nodoc
class __$$ExpenseRecordImplCopyWithImpl<$Res>
    extends _$ExpenseRecordCopyWithImpl<$Res, _$ExpenseRecordImpl>
    implements _$$ExpenseRecordImplCopyWith<$Res> {
  __$$ExpenseRecordImplCopyWithImpl(
    _$ExpenseRecordImpl _value,
    $Res Function(_$ExpenseRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExpenseRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? amount = null,
    Object? category = null,
    Object? date = null,
    Object? note = freezed,
    Object? customCategory = freezed,
  }) {
    return _then(
      _$ExpenseRecordImpl(
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
        customCategory: freezed == customCategory
            ? _value.customCategory
            : customCategory // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExpenseRecordImpl extends _ExpenseRecord {
  const _$ExpenseRecordImpl({
    this.id,
    required this.amount,
    @ExpenseCategoryConverter() required this.category,
    required this.date,
    this.note,
    @JsonKey(includeFromJson: false, includeToJson: false) this.customCategory,
  }) : super._();

  factory _$ExpenseRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExpenseRecordImplFromJson(json);

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
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? customCategory;

  @override
  String toString() {
    return 'ExpenseRecord(id: $id, amount: $amount, category: $category, date: $date, note: $note, customCategory: $customCategory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpenseRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.customCategory, customCategory) ||
                other.customCategory == customCategory));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    amount,
    category,
    date,
    note,
    customCategory,
  );

  /// Create a copy of ExpenseRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpenseRecordImplCopyWith<_$ExpenseRecordImpl> get copyWith =>
      __$$ExpenseRecordImplCopyWithImpl<_$ExpenseRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExpenseRecordImplToJson(this);
  }
}

abstract class _ExpenseRecord extends ExpenseRecord {
  const factory _ExpenseRecord({
    final int? id,
    required final double amount,
    @ExpenseCategoryConverter() required final ExpenseCategory category,
    required final DateTime date,
    final String? note,
    @JsonKey(includeFromJson: false, includeToJson: false)
    final String? customCategory,
  }) = _$ExpenseRecordImpl;
  const _ExpenseRecord._() : super._();

  factory _ExpenseRecord.fromJson(Map<String, dynamic> json) =
      _$ExpenseRecordImpl.fromJson;

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
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get customCategory;

  /// Create a copy of ExpenseRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpenseRecordImplCopyWith<_$ExpenseRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
