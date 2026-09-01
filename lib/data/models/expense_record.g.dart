// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseRecordImpl _$$ExpenseRecordImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseRecordImpl(
      id: (json['id'] as num?)?.toInt(),
      amount: (json['amount'] as num).toDouble(),
      category: const ExpenseCategoryConverter().fromJson(
        json['category'] as String,
      ),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$$ExpenseRecordImplToJson(_$ExpenseRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'category': const ExpenseCategoryConverter().toJson(instance.category),
      'date': instance.date.toIso8601String(),
      'note': instance.note,
    };
