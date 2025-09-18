// file: lib/database.dart

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// این قسمت برای تولید کد اتوماتیک لازمه
part 'database.g.dart';

// تعریف جدول تراکنش‌ها
class Transactions extends Table {
  // شناسه اصلی که خودکار زیاد میشه
  IntColumn get id => integer().autoIncrement()();
  // عنوان تراکنش
  TextColumn get title => text().withLength(min: 1, max: 50)();
  // مبلغ تراکنش
  RealColumn get amount => real()();
  // تاریخ تراکنش که موقع ثبت، زمان حال رو میگیره
  DateTimeColumn get transactionDate =>
      dateTime().clientDefault(() => DateTime.now())();
  // نوع تراکنش: 0 برای هزینه، 1 برای درآمد
  IntColumn get transactionType => integer()();
}

// تعریف کلاس دیتابیس
@DriftDatabase(tables: [Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
  // --- توابع جدید ---

  // تابعی برای گرفتن تمام تراکنش‌ها
  Future<List<Transaction>> getAllTransactions() => select(transactions).get();

  // تابعی برای تماشای تمام تراکنش‌ها (به صورت Stream)
  // با این تابع، هر تغییری در دیتابیس، لیست رو آپدیت میکنه
  Stream<List<Transaction>> watchAllTransactions() =>
      select(transactions).watch();

  // تابعی برای اضافه کردن یک تراکنش جدید
  Future<int> addTransaction(TransactionsCompanion entry) {
    return into(transactions).insert(entry);
  }
}

// تابعی برای باز کردن و اتصال به دیتابیس
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}

// یک نمونه سراسری از دیتابیس برای دسترسی آسان
final database = AppDatabase();
