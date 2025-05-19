// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';

// Future<String> getDatabasePath() async {
//   final documentsDir = await getApplicationDocumentsDirectory();
//   final dbPath = join(documentsDir.path, 'grades.db');

//   // Copy from assets if not exists
//   if (!File(dbPath).existsSync()) {
//     final data = await rootBundle.load('assets/db/grades.db');
//     final bytes = data.buffer.asUint8List();
//     await File(dbPath).writeAsBytes(bytes, flush: true);
//   }
//   return dbPath;
// }

// Future<Database> openDatabase() async {
//   final path = await getDatabasePath();
//   return await openDatabase(path);
// }

// /// CALCULATOR: Calculate final grade for a subject_id
// Future<double> calculateFinalGrade(int subjectId) async {
//   final dbPath = await getDatabasePath();
//   final db = await openDatabase(dbPath);

//   // Get root partitions for the subject
//   final rootPartitions = await db.rawQuery('''
//     SELECT id, percentage FROM partition
//     WHERE subject_id = ? AND parent_partition_id IS NULL;
//   ''', [subjectId]);

//   double finalGrade = 0.0;

//   for (final partitionRow in rootPartitions) {
//     final partitionGrade =
//         await _calculatePartitionGrade(db, partitionRow['id'] as int);
//     final partitionWeight = (partitionRow['percentage'] as double) / 100.0;
//     finalGrade += partitionGrade * partitionWeight;
//   }

//   await db.close();
//   return finalGrade;
// }

// /// Recursive helper to calculate grade for a partition
// Future<double> _calculatePartitionGrade(Database db, int partitionId) async {
//   // Check if partition has sub-partitions
//   final subPartitions = await db.rawQuery('''
//     SELECT id, percentage FROM partition
//     WHERE parent_partition_id = ?;
//   ''', [partitionId]);

//   if (subPartitions.isNotEmpty) {
//     // Aggregate weighted grades from sub-partitions
//     double total = 0.0;
//     for (final subPartition in subPartitions) {
//       final subGrade =
//           await _calculatePartitionGrade(db, subPartition['id'] as int);
//       final subWeight = (subPartition['percentage'] as double) / 100.0;
//       total += subGrade * subWeight;
//     }
//     return total;
//   } else {
//     // No sub-partitions, get components
//     final components = await db.rawQuery('''
//       SELECT score, max_score FROM component
//       WHERE partition_id = ? AND score IS NOT NULL;
//     ''', [partitionId]);

//     if (components.isEmpty) return 0.0;

//     double totalScore = 0.0;
//     double totalMax = 0.0;

//     for (final comp in components) {
//       totalScore += comp['score'] as double;
//       totalMax += comp['max_score'] as double;
//     }

//     if (totalMax == 0) return 0.0;
//     return totalScore / totalMax;
//   }
// }

// /// SAVE: Save a component
// Future<void> saveComponent(
//     {required double? score,
//     required double maxScore,
//     required int partitionId}) async {
//   final dbPath = await getDatabasePath();
//   final db = await openDatabase(dbPath);

//   await db.execute('''
//     INSERT INTO component (score, max_score, partition_id)
//     VALUES (?, ?, ?);
//   ''', [score, maxScore, partitionId]);

//   await db.close();
// }

// /// SAVE: Save a partition
// Future<void> savePartition({
//   required int? subjectId,
//   required double percentage,
//   required int? parentPartitionId,
//   required String name,
//   String? description,
// }) async {
//   final dbPath = await getDatabasePath();
//   final db = await openDatabase(dbPath);

//   await db.execute('''
//     INSERT INTO partition (subject_id, percentage, parent_partition_id, name, description)
//     VALUES (?, ?, ?, ?, ?);
//   ''', [subjectId, percentage, parentPartitionId, name, description]);

//   await db.close();
// }

// /// SAVE: Save a subject
// Future<void> saveSubject({
//   required String subjectCode,
//   required String name,
//   int? units,
//   String? description,
// }) async {
//   final dbPath = await getDatabasePath();
//   final db = await openDatabase(dbPath);

//   await db.execute('''
//     INSERT INTO subject (subject_code, name, units, description)
//     VALUES (?, ?, ?, ?);
//   ''', [subjectCode, name, units, description]);

//   await db.close();
// }

// /// Loads all subjects from the database as a List<Map<String, dynamic
// Future<List<Map<String, dynamic>>> loadSubjects() async {
//   final dbPath = await getDatabasePath();
//   final db = await openDatabase(dbPath);
//   final result = await db.rawQuery('SELECT * FROM subject');
//   final subjects = result.map((row) => Map<String, dynamic>.from(row)).toList();
//   await db.close();
//   return subjects;
// }

// /// Loads all partitions for a given subjectId as a List<Map<String, String>>
// Future<List<Map<String, String>>> loadPartitionsForSubject(
//     int subjectId) async {
//   final dbPath = await getDatabasePath();
//   final db = await openDatabase(dbPath);
//   final result = await db
//       .rawQuery('SELECT * FROM partition WHERE subject_id = ?', [subjectId]);
//   await db.close();
//   // Convert all values to String for compatibility with SubjectPartitioningScreen
//   return result
//       .map((row) => Map<String, String>.fromEntries(
//           row.entries.map((e) => MapEntry(e.key, e.value?.toString() ?? ''))))
//       .toList();
// }
