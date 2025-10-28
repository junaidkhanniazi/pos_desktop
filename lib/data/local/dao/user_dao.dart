import 'package:logger/logger.dart';
import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/user_model.dart';

class UserDao {
  final _db = DatabaseHelper();
  final _log = Logger();

  /// Insert user (avoid duplicate username)
  Future<int> insertUser(UserModel user) async {
    final db = await _db.database;

    final dup = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [user.username],
      limit: 1,
    );

    if (dup.isNotEmpty) {
      _log.w('⚠️ Username already exists: ${user.username}');
      return dup.first['id'] as int;
    }

    final id = await db.insert('users', user.toMap());
    _log.i(
      '👤 User inserted id=$id (owner=${user.ownerId}, role=${user.role})',
    );
    return id;
  }

  /// Fetch all users (filter by owner if provided)
  Future<List<UserModel>> getUsers({int? ownerId}) async {
    final db = await _db.database;
    final result = await db.query(
      'users',
      where: ownerId != null ? 'owner_id = ?' : null,
      whereArgs: ownerId != null ? [ownerId] : null,
      orderBy: 'id DESC',
    );
    return result.map((map) => UserModel.fromMap(map)).toList();
  }

  /// Login check
  Future<UserModel?> getByCredentials(
    int ownerId,
    String username,
    String password,
  ) async {
    final db = await _db.database;
    final res = await db.query(
      'users',
      where: 'owner_id = ? AND username = ? AND password = ? AND is_active = 1',
      whereArgs: [ownerId, username, password],
      limit: 1,
    );

    if (res.isNotEmpty) {
      _log.i('✅ User login: $username (owner=$ownerId)');
      return UserModel.fromMap(res.first);
    }

    _log.w('🚫 Invalid credentials for $username (owner=$ownerId)');
    return null;
  }

  /// Update user details
  Future<int> updateUser(UserModel user) async {
    final db = await _db.database;
    final count = await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
    _log.i('🔄 User updated id=${user.id} · rows=$count');
    return count;
  }

  /// Toggle active state
  Future<int> setActive(int id, bool isActive) async {
    final db = await _db.database;
    final count = await db.update(
      'users',
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    _log.i('🟢 User setActive id=$id → $isActive · rows=$count');
    return count;
  }

  /// Delete user
  Future<int> deleteUser(int id) async {
    final db = await _db.database;
    final count = await db.delete('users', where: 'id = ?', whereArgs: [id]);
    _log.i('🗑️ User deleted id=$id · rows=$count');
    return count;
  }
}
