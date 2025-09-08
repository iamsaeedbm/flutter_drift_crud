// file: lib/database.dart

import 'package:drift/drift.dart';
import 'package:drift/web.dart';
// کتابخانه‌های جدید برای تشخیص پلتفرم و دیتابیس وب
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:drift/wasm.dart';

// کتابخانه‌های قبلی برای موبایل و دسکتاپ
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'database.g.dart';

// تعریف جدول (بدون تغییر)
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
}

// تعریف کلاس دیتابیس (بدون تغییر)
@DriftDatabase(tables: [Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // --- عملیات CRUD (بدون تغییر) ---
  Stream<List<Task>> watchAllTasks() => select(tasks).watch();
  Future<void> addTask(String title) =>
      into(tasks).insert(TasksCompanion(title: Value(title)));
  Future<void> updateTaskStatus(Task task) => update(tasks).replace(task);
  Future<void> deleteTask(int id) =>
      (delete(tasks)..where((tbl) => tbl.id.equals(id))).go();
}

// ✨ بخش اصلی تغییرات اینجاست ✨
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // اگر برنامه روی وب اجرا می‌شود
    if (kIsWeb) {
      // از WebDatabase استفاده کن که داده‌ها را در حافظه مرورگر ذخیره می‌کند
      return WebDatabase('db');
    }
    // در غیر این صورت (موبایل، دسکتاپ)
    else {
      // از همان روش قبلی یعنی NativeDatabase استفاده کن
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'db.sqlite'));
      return NativeDatabase(file);
    }
  });
}
