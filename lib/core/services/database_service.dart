import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/match.dart';
import '../models/message.dart';

class DatabaseService {
  static const String _dbName = 'roomsync.db';
  static const int _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        // Table for cached messages
        await db.execute('''
          CREATE TABLE messages (
            id TEXT PRIMARY KEY,
            matchId TEXT NOT NULL,
            senderId TEXT NOT NULL,
            receiverId TEXT NOT NULL,
            content TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            isRead INTEGER NOT NULL,
            messageType TEXT NOT NULL,
            meetupDetails TEXT
          )
        ''');

        // Table for cached matches
        await db.execute('''
          CREATE TABLE matches (
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            targetUserId TEXT NOT NULL,
            targetUserJson TEXT,
            compatibilityScore REAL NOT NULL,
            scoreBreakdownJson TEXT,
            isMutual INTEGER NOT NULL,
            lastMessage TEXT,
            lastMessageAt TEXT,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Insert or update message
  Future<void> saveMessage(Message message) async {
    final db = await database;
    await db.insert(
      'messages',
      {
        'id': message.id,
        'matchId': message.matchId,
        'senderId': message.senderId,
        'receiverId': message.receiverId,
        'content': message.content,
        'timestamp': message.timestamp.toIso8601String(),
        'isRead': message.isRead ? 1 : 0,
        'messageType': message.messageType.name,
        'meetupDetails': message.meetupDetails != null
            ? message.meetupDetails!.venueName
            : null,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get cached messages for a match
  Future<List<Map<String, dynamic>>> getCachedMessages(String matchId) async {
    final db = await database;
    return await db.query(
      'messages',
      where: 'matchId = ?',
      whereArgs: [matchId],
      orderBy: 'timestamp ASC',
    );
  }

  // Clear local DB cache
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('messages');
    await db.delete('matches');
  }
}

