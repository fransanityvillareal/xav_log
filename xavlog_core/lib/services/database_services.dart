import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  // Subjects table 
  final String _subjectsTableName = 'subjects';
  final String _subjectsId = 'id';
  final String _subjectsSubjectCode = 'subjectCode';
  final String _subjectsSubjectTitle = 'subjectTitle';
  final String _subjectsUnits = 'units';
  final String _subjectsDescription = 'description';
  final String _subjectsFinalGrade = 'finalGrade';

  // Partitions table 
  final String _partitionsTableName = 'partitions';
  final String _partitionsType = 'type';
  final String _partitionsId = 'id';
  final String _partitionsParentSubjectId = 'parentSubjectId';
  final String _partitionsParentId = 'parentId';
  final String _partitionsPartitionName = 'partitionName';
  final String _partitionsPercentage = 'percentage';

  // Classworks table 
  final String _classworksTableName = 'classworks';
  final String _classworksType = 'type';
  final String _classworksId = 'id';
  final String _classworksParentSubjectId = 'parentSubjectId';
  final String _classworksParentId = 'parentId';
  final String _classworksName = 'name';
  final String _classworksScore = 'score';
  final String _classworksMaxScore = 'maxScore';
  final String _classworksPercentage = 'percentage';

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    
    final databasePath = join(databaseDirPath, 'grades.db');
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_subjectsTableName (
            $_subjectsId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_subjectsSubjectCode TEXT NOT NULL UNIQUE,
            $_subjectsSubjectTitle TEXT NOT NULL,
            $_subjectsUnits REAL NOT NULL,
            $_subjectsDescription TEXT,
            $_subjectsFinalGrade REAL
          );
        ''');

        await db.execute('''
          CREATE TABLE $_partitionsTableName (
            $_partitionsType TEXT NOT NULL,
            $_partitionsId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_partitionsParentSubjectId INTEGER NOT NULL,
            $_partitionsParentId INTEGER,
            $_partitionsPartitionName TEXT NOT NULL,
            $_partitionsPercentage REAL NOT NULL,
            FOREIGN KEY($_partitionsParentSubjectId) REFERENCES $_subjectsTableName($_subjectsId) ON DELETE CASCADE,
            FOREIGN KEY($_partitionsParentId) REFERENCES $_partitionsTableName($_partitionsId) ON DELETE CASCADE
          );
        ''');

        await db.execute('''
          CREATE TABLE $_classworksTableName (
            $_classworksType TEXT NOT NULL,
            $_classworksId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_classworksParentSubjectId INTEGER NOT NULL,
            $_classworksParentId INTEGER,
            $_classworksName TEXT NOT NULL,
            $_classworksScore REAL,
            $_classworksMaxScore REAL,
            $_classworksPercentage REAL,
            FOREIGN KEY($_classworksParentSubjectId) REFERENCES $_subjectsTableName($_subjectsId) ON DELETE CASCADE,
            FOREIGN KEY($_classworksParentId) REFERENCES $_partitionsTableName($_partitionsId) ON DELETE CASCADE
          );
        ''');
      },
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

    );
    return database;
  }
  //Add methods for inserting data into the tables
  Future<int> addSubject(String subjectCode,
                  String subjectTitle, 
                  double units, 
                  String description, 
                  double finalGrade) async 
  {
    final db = await database;
    int id = await db.insert(
      _subjectsTableName,
      {
        _subjectsSubjectCode: subjectCode,
        _subjectsSubjectTitle: subjectTitle,
        _subjectsUnits: units,
        _subjectsDescription: description,
        _subjectsFinalGrade: finalGrade
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }
  Future<int> addPartition(String type,
                    int parentSubjectId, 
                    int? parentId, 
                    String partitionName, 
                    double percentage) async 
  {
    final db = await database;
    int id = await db.insert(
      _partitionsTableName,
      {
        _partitionsType: type,
        _partitionsParentSubjectId: parentSubjectId,
        _partitionsParentId: parentId,
        _partitionsPartitionName: partitionName,
        _partitionsPercentage: percentage
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<int> addClasswork(String type,
                    int parentSubjectId, 
                    int? parentId, 
                    String name, 
                    double score, 
                    double maxScore, 
                    double percentage) async 
  {
    final db = await database;
    int id = await db.insert(
      _classworksTableName,
      {
        _classworksType: type,
        _classworksParentSubjectId: parentSubjectId,
        _classworksParentId: parentId,
        _classworksName: name,
        _classworksScore: score,
        _classworksMaxScore: maxScore,
        _classworksPercentage: percentage
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  //Get methods for retrieving data from the tables

  //get specific subject
  Future<Map<String, dynamic>?> getSubject(int id) async {
    final db = await database;
    final result = await db.query(_subjectsTableName,
      where: '$_subjectsId = ?',
      whereArgs: [id]);
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  //get specific partition
  Future<Map<String, dynamic>?> getPartition(int id) async {
    final db = await database;
    final result = await db.query(
      _partitionsTableName,
      where: '$_partitionsId = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  //get all subjects
  Future<List<Map<String, dynamic>>> getSubjects() async {
    final db = await database;
    return await db.query(_subjectsTableName);
  }

  //get all top level components (partitions and classworks) for a subject
  Future<List<Map<String, dynamic>>> getTopLevelComponents(int parentSubjectId) async {
    final db = await database;

    // Get top-level partitions (parentId is null)
    final partitions = await db.query(
      _partitionsTableName,
      where: '$_partitionsParentSubjectId = ? AND $_partitionsParentId IS NULL',
      whereArgs: [parentSubjectId],
    );

    // Get top-level classworks (parentId is null)
    final classworks = await db.query(
      _classworksTableName,
      where: '$_classworksParentSubjectId = ? AND $_classworksParentId IS NULL',
      whereArgs: [parentSubjectId],
    );

    // Combine and return
    return [...partitions, ...classworks];
  }

  //get all components (partitions and classworks) for a parentId
  Future<List<Map<String, dynamic>>> getComponents(int parentId) async {
    final db = await database;

    // Get partitions with the given parentId
    final partitions = await db.query(
      _partitionsTableName,
      where: '$_partitionsParentId = ?',
      whereArgs: [parentId],
    );

    // Get classworks with the given parentId
    final classworks = await db.query(
      _classworksTableName,
      where: '$_classworksParentId = ?',
      whereArgs: [parentId],
    );

    // Combine and return
    return [...partitions, ...classworks];
  }

//Update methods for updating data in the tables

  Future<int> updateSubject(int id, Map<String, dynamic> values) async {
    final db = await database;
    return await db.update(
      _subjectsTableName,
      values,
      where: '$_subjectsId = ?',
      whereArgs: [id],
    );
  }
  Future<int> updateFinalGrade(int subjectId, double finalGrade) async {
  final db = await database;
  return await db.update(
    _subjectsTableName,
    {
      _subjectsFinalGrade: finalGrade,
    },
    where: '$_subjectsId = ?',
    whereArgs: [subjectId],
  );
}

  Future<int> updatePartition(int id, Map<String, dynamic> values) async {
    final db = await database;
    return await db.update(
      _partitionsTableName,
      values,
      where: '$_partitionsId = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateClasswork(int id, Map<String, dynamic> values) async {
    final db = await database;
    return await db.update(
      _classworksTableName,
      values,
      where: '$_classworksId = ?',
      whereArgs: [id],
    );
  }

  //delete methods for deleting data from the tables

  // Delete a subject and all its partitions and classworks
  Future<int> deleteSubject(int id) async {
    final db = await database;
    return await db.delete(
      _subjectsTableName,
      where: '$_subjectsId = ?',
      whereArgs: [id],
    );
  }

  // Deletes all children as well
  Future<int> deletePartition(int id) async {
    final db = await database;
    return await db.delete(
      _partitionsTableName,
      where: '$_partitionsId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteClasswork(int id) async {
    final db = await database;
    return await db.delete(
      _classworksTableName,
      where: '$_classworksId = ?',
      whereArgs: [id],
    );
  }

  //Calculation methods for calculating grades
  Future<double> calculatePartitionGrade(int partitionId) async {
  final db = await database;

  // Get all direct child classworks of this partition
  final classworks = await db.query(
    _classworksTableName,
    where: '$_classworksParentId = ?',
    whereArgs: [partitionId],
  );

  // Calculate total score and total max score for classworks
  double totalScore = 0.0;
  double totalMaxScore = 0.0;
  for (var cw in classworks) {
    totalScore += (cw[_classworksScore] ?? 0.0) as double;
    totalMaxScore += (cw[_classworksMaxScore] ?? 0.0) as double;
  }

  // Get all child partitions of this partition
  final childPartitions = await db.query(
    _partitionsTableName,
    where: '$_partitionsParentId = ?',
    whereArgs: [partitionId],
  );

  // Recursively calculate grades for child partitions and add to totals
  for (var partition in childPartitions) {
    double childGrade = await calculatePartitionGrade(partition[_partitionsId] as int);
    double percentage = (partition[_partitionsPercentage] ?? 0.0) as double;
    // Weighted by partition percentage
    totalScore += childGrade * (percentage / 100.0);
    totalMaxScore += percentage; // For weighted partitions, treat percentage as max
  }

  // If there are no classworks or partitions, return 0
  if (totalMaxScore == 0.0) return 0.0;

  // Return the weighted grade as a percentage
  return (totalScore / totalMaxScore) * 100.0;
}

//calculate final grade for a subject
Future<double> calculateFinalGrade(int subjectId) async {
  final db = await database;

  // Get all top-level partitions for this subject (parentId IS NULL)
  final partitions = await db.query(
    _partitionsTableName,
    where: '$_partitionsParentSubjectId = ? AND $_partitionsParentId IS NULL',
    whereArgs: [subjectId],
  );

  // Get all top-level classworks for this subject (parentId IS NULL)
  final classworks = await db.query(
    _classworksTableName,
    where: '$_classworksParentSubjectId = ? AND $_classworksParentId IS NULL',
    whereArgs: [subjectId],
  );

  double totalScore = 0.0;
  double totalMaxScore = 0.0;
  double totalPartitionPercentage = 0.0;

  // Calculate and sum partition grades, weighted by their percentage
  for (var partition in partitions) {
    double partitionGrade = await calculatePartitionGrade(partition[_partitionsId] as int);
    double percentage = (partition[_partitionsPercentage] ?? 0.0) as double;
    totalScore += partitionGrade * (percentage / 100.0);
    totalMaxScore += percentage;
    totalPartitionPercentage += percentage;
  }

  // The remaining percentage is for top-level classworks
  double remainingPercentage = 100.0 - totalPartitionPercentage;

  // If there are top-level classworks and remaining percentage > 0, calculate their contribution
  if (classworks.isNotEmpty && remainingPercentage > 0) {
    double classworkScore = 0.0;
    double classworkMaxScore = 0.0;
    for (var cw in classworks) {
      classworkScore += (cw[_classworksScore] ?? 0.0) as double;
      classworkMaxScore += (cw[_classworksMaxScore] ?? 0.0) as double;
    }
    if (classworkMaxScore > 0) {
      double classworkGrade = (classworkScore / classworkMaxScore) * 100.0;
      totalScore += classworkGrade * (remainingPercentage / 100.0);
      totalMaxScore += remainingPercentage;
    }
  }

  // If there are no partitions or classworks, return 0
  if (totalMaxScore == 0.0) return 0.0;

  // Return the weighted final grade as a percentage
  return (totalScore / totalMaxScore) * 100.0;
}

Future<double> calculateAverageQPI() async {
  final db = await database;
  final subjects = await db.query(_subjectsTableName);

  double totalQpiUnits = 0.0;
  double totalUnits = 0.0;

  double gradeToQPI(double grade) {
    if (grade >= 96) return 4.0;
    if (grade >= 91) return 3.5;
    if (grade >= 88) return 3.0;
    if (grade >= 82) return 2.5;
    if (grade >= 76) return 2.0;
    if (grade >= 69) return 1.5;
    if (grade >= 63) return 1.0;
    return 0.0;
  }

  for (var subject in subjects) {
    double grade = (subject[_subjectsFinalGrade] ?? 0.0) as double;
    double units = (subject[_subjectsUnits] ?? 0.0) as double;
    double qpi = gradeToQPI(grade);
    totalQpiUnits += qpi * units;
    totalUnits += units;
  }

  if (totalUnits == 0.0) return 0.0;
  return totalQpiUnits / totalUnits;
}


}
