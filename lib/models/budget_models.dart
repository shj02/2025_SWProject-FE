import 'package:flutter/material.dart';

enum ExpenseCategory { shared, personal }

class PersonalBudget {
  PersonalBudget({
    required this.memberName,
    required this.total,
  });

  final String memberName;
  double total;
}

class ExpenseEntry {
  ExpenseEntry({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.memo,
    required this.participants,
    this.payer,
    DateTime? createdAt,
    bool isSettled = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        _isSettled = isSettled;

  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final String memo;
  final List<String> participants;
  final String? payer;
  final DateTime createdAt;
  bool _isSettled;

  bool get isShared => category == ExpenseCategory.shared;

  String? get personalOwner =>
      category == ExpenseCategory.personal && participants.isNotEmpty ? participants.first : null;

  bool get isSettled => _isSettled;

  ExpenseEntry copyWith({
    String? title,
    double? amount,
    ExpenseCategory? category,
    String? memo,
    List<String>? participants,
    String? payer,
    DateTime? createdAt,
    bool? isSettled,
  }) {
    return ExpenseEntry(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      memo: memo ?? this.memo,
      participants: participants ?? List<String>.from(this.participants),
      payer: payer ?? this.payer,
      createdAt: createdAt ?? this.createdAt,
      isSettled: isSettled ?? _isSettled,
    );
  }

  void markSettled() => _isSettled = true;
}

