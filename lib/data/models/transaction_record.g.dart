// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionRecordImpl _$$TransactionRecordImplFromJson(
  Map<String, dynamic> json,
) => _$TransactionRecordImpl(
  id: (json['id'] as num?)?.toInt(),
  amount: (json['amount'] as num).toDouble(),
  category: const ExpenseCategoryConverter().fromJson(
    json['category'] as String,
  ),
  date: DateTime.parse(json['date'] as String),
  note: json['note'] as String?,
);

Map<String, dynamic> _$$TransactionRecordImplToJson(
  _$TransactionRecordImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'category': const ExpenseCategoryConverter().toJson(instance.category),
  'date': instance.date.toIso8601String(),
  'note': instance.note,
};
