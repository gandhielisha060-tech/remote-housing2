import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class SqliteDatabase {
  Database? _database;
  Future<Database?>? _opening;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _opening ??= _open();
    return _opening;
  }

  Future<Database?> _open() async {
    try {
      final database = await databaseFactoryFfiWebNoWebWorker.openDatabase(
        'mau_housing.sqlite',
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE users (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                email TEXT NOT NULL UNIQUE,
                password_hash TEXT NOT NULL,
                role TEXT NOT NULL,
                phone TEXT,
                student_id TEXT,
                institution TEXT,
                department TEXT,
                property_address TEXT,
                email_verified INTEGER NOT NULL DEFAULT 0,
                suspended INTEGER NOT NULL DEFAULT 0
              )
            ''');
          },
          onUpgrade: (db, oldVersion, newVersion) async {
            if (oldVersion < 2) {
              await db.execute('ALTER TABLE users ADD COLUMN student_id TEXT');
              await db.execute('ALTER TABLE users ADD COLUMN institution TEXT');
              await db.execute('ALTER TABLE users ADD COLUMN department TEXT');
              await db.execute(
                'ALTER TABLE users ADD COLUMN property_address TEXT',
              );
            }
          },
        ),
      );
      _database = database;
      return database;
    } catch (_) {
      return null;
    }
  }
}
