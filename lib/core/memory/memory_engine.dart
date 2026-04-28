import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

/// 🧠 Memory Engine — Persistent Memory with SQLite
class MemoryEngine extends ChangeNotifier {
  static final MemoryEngine I = MemoryEngine._();
  MemoryEngine._();

  late Database _db;
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dbPath, 'droidclaw.db'),
      onCreate: (db, v) async {
        await db.execute('CREATE TABLE conversations(id TEXT PRIMARY KEY,title TEXT,created_at TEXT,updated_at TEXT)');
        await db.execute('CREATE TABLE messages(id TEXT PRIMARY KEY,conv_id TEXT,role TEXT,content TEXT,timestamp TEXT,tools TEXT)');
        await db.execute('CREATE TABLE memory(key TEXT PRIMARY KEY,value TEXT,category TEXT,created_at TEXT,access_count INT)');
        await db.execute('CREATE TABLE knowledge(id TEXT PRIMARY KEY,topic TEXT,content TEXT,source TEXT,created_at TEXT)');
        await db.execute('CREATE TABLE tool_log(id INTEGER PRIMARY KEY AUTOINCREMENT,tool TEXT,params TEXT,result TEXT,success INT,timestamp TEXT)');
      },
      version: 1,
    );
  }

  Future<void> addTurn({required String sessionId, required String user, required String assistant, List<String>? tools}) async {
    final now = DateTime.now().toIso8601String();
    await _db.insert('messages', {'id': '${sessionId}_${now}_u', 'conv_id': sessionId, 'role': 'user', 'content': user, 'timestamp': now});
    await _db.insert('messages', {'id': '${sessionId}_${now}_a', 'conv_id': sessionId, 'role': 'assistant', 'content': assistant, 'timestamp': now, 'tools': tools?.join(',')});
  }

  Future<List<Map<String, dynamic>>> getHistory(String sessionId, {int limit = 50}) async {
    return await _db.query('messages', where: 'conv_id = ?', whereArgs: [sessionId], orderBy: 'timestamp ASC', limit: limit);
  }

  Future<void> saveMemory(String key, String value, {String category = 'general'}) async {
    await _db.insert('memory', {'key': key, 'value': value, 'category': category, 'created_at': DateTime.now().toIso8601String(), 'access_count': 0}, conflictAlgorithm: ConflictAlgorithm.replace);
    notifyListeners();
  }

  Future<String?> recall(String key) async {
    final rows = await _db.query('memory', where: 'key = ?', whereArgs: [key]);
    if (rows.isNotEmpty) {
      await _db.update('memory', {'access_count': (rows.first['access_count'] as int) + 1}, where: 'key = ?', whereArgs: [key]);
      return rows.first['value'] as String;
    }
    return null;
  }

  Future<List<MemoryEntry>> getRelevantContext(String query) async {
    final words = query.toLowerCase().split(' ').where((w) => w.length > 2).toList();
    final results = <MemoryEntry>[];
    for (var word in words.take(5)) {
      final rows = await _db.query('memory', where: 'key LIKE ? OR value LIKE ?', whereArgs: ['%$word%', '%$word%'], limit: 5);
      results.addAll(rows.map((r) => MemoryEntry(key: r['key'] as String, value: r['value'] as String, category: r['category'] as String)));
    }
    return results;
  }

  Future<List<MemoryEntry>> getAllMemories() async {
    final rows = await _db.query('memory', orderBy: 'access_count DESC');
    return rows.map((r) => MemoryEntry(key: r['key'] as String, value: r['value'] as String, category: r['category'] as String)).toList();
  }

  Future<void> deleteMemory(String key) async {
    await _db.delete('memory', where: 'key = ?', whereArgs: [key]);
    notifyListeners();
  }

  Future<MemoryStats> getStats() async {
    final conv = Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM conversations')) ?? 0;
    final msg = Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM messages')) ?? 0;
    final mem = Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM memory')) ?? 0;
    final kb = Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM knowledge')) ?? 0;
    return MemoryStats(conversations: conv, messages: msg, memories: mem, knowledge: kb);
  }

  Future<void> clearAll() async {
    await _db.delete('messages');
    await _db.delete('memory');
    await _db.delete('knowledge');
    await _db.delete('tool_log');
    notifyListeners();
  }
}

class MemoryEntry {
  final String key;
  final String value;
  final String category;
  MemoryEntry({required this.key, required this.value, required this.category});
}

class MemoryStats {
  final int conversations;
  final int messages;
  final int memories;
  final int knowledge;
  MemoryStats({required this.conversations, required this.messages, required this.memories, required this.knowledge});
}
