import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'database.g.dart';

// تعریف جدول هزینه‌ها
@DataClassName('Expense')
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get description => text().withLength(max: 255)();
  DateTimeColumn get date => dateTime()();
}

// تعریف جدول درآمدها
@DataClassName('Income')
class Incomes extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get description => text().withLength(max: 255)();
  DateTimeColumn get date => dateTime()();
}

// تعریف دیتابیس
@DriftDatabase(tables: [Expenses, Incomes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // عملیات CRUD برای هزینه‌ها
  Future<List<Expense>> getAllExpenses() => select(expenses).get();
  Future<int> addExpense(ExpensesCompanion expense) =>
      into(expenses).insert(expense);
  Future<bool> updateExpense(Expense expense) =>
      update(expenses).replace(expense);
  Future<int> deleteExpense(int id) =>
      (delete(expenses)..where((tbl) => tbl.id.equals(id))).go();

  // عملیات CRUD برای درآمدها
  Future<List<Income>> getAllIncomes() => select(incomes).get();
  Future<int> addIncome(IncomesCompanion income) =>
      into(incomes).insert(income);
  Future<bool> updateIncome(Income income) => update(incomes).replace(income);
  Future<int> deleteIncome(int id) =>
      (delete(incomes)..where((tbl) => tbl.id.equals(id))).go();
}

// اتصال به دیتابیس
QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'finance_app.sqlite'));
    return NativeDatabase(file);
  });
}
