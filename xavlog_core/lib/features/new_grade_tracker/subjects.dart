import 'package:flutter/material.dart';
import 'package:xavlog_core/features/new_grade_tracker/partitions.dart';
import 'package:xavlog_core/services/database_services.dart';
class SubjectScreen extends StatefulWidget {
  const SubjectScreen({super.key});
  
  
  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  List<Map<String, dynamic>> subjects = [];
  // Example subject structure
  // {
  //     'subjectCode': 'CS101',
  //     'subjectTitle': 'Introduction to Computer Science',
  //     'units': 3,
  //     'description': 'Basic concepts of computer science.',
  //     'finalGrade': 0.0, // Default final grade
  // },
  bool showOverlay = false;
  double finalGrade = 0.0;
  final TextEditingController subjectCodeController = TextEditingController();
  final TextEditingController subjectTitleController = TextEditingController();
  final TextEditingController unitsController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void _addSubject() async {
    if (subjectCodeController.text.isNotEmpty &&
        subjectTitleController.text.isNotEmpty &&
        unitsController.text.isNotEmpty) {
      // Insert into SQLite DB first
      int id = await DatabaseService.instance.addSubject(
        subjectCodeController.text,
        subjectTitleController.text,
        double.tryParse(unitsController.text) ?? 0.0,
        descriptionController.text,
        0.0, // Default final grade
      );

      final newSubject = {
        'id': id,
        'subjectCode': subjectCodeController.text,
        'subjectTitle': subjectTitleController.text,
        'units': double.tryParse(unitsController.text) ?? 0.0,
        'description': descriptionController.text,
        'finalGrade': 0.0,
      };
      setState(() {
        subjects.add(newSubject);
        subjectCodeController.clear();
        subjectTitleController.clear();
        unitsController.clear();
        descriptionController.clear();
      });
      updateAverageQPIGrade();
    }
  }

  void _AddSubjectDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Add New Subject',
          style: TextStyle(
            fontFamily: 'Jost',
            fontWeight: FontWeight.w600,
            fontSize: 18.0,
          ),
        ),
        content: SingleChildScrollView(
          child: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildInputField("Subject Code*", controller: subjectCodeController),
                SizedBox(height: 16),
                buildInputField("Subject Title*", controller: subjectTitleController),
                SizedBox(height: 16),
                buildInputField("Units*", controller: unitsController),
                SizedBox(height: 16),
                buildInputField("Description", isLarge: true, controller: descriptionController),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Clear controllers and close dialog
              subjectCodeController.clear();
              subjectTitleController.clear();
              unitsController.clear();
              descriptionController.clear();
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (subjectCodeController.text.isNotEmpty &&
                  subjectTitleController.text.isNotEmpty &&
                  unitsController.text.isNotEmpty) {
                _addSubject();
                Navigator.of(context).pop();
              } else {
                // Show validation message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill in all required fields'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF283AA3),
              foregroundColor: Colors.white,
            ),
            child: Text('Add Subject'),
          ),
        ],
      );
    },
  );
}
  // Load subjects from SQLite
  Future<void> _loadSubjects() async {
    List<Map<String, dynamic>> loadedSubjects = await DatabaseService.instance.getSubjects();
    setState(() {
      subjects = List<Map<String, dynamic>>.from(loadedSubjects); // Make a modifiable copy
    });
  }
  // Calculate final grade for all subjects
  Future<void> updateAverageQPIGrade() async {
  double avgQPI = await DatabaseService.instance.calculateAverageQPI();
  setState(() {
    finalGrade = avgQPI;
  });
}

  //TESTER
  Future<void> printAllSubjects() async {
  final db = await DatabaseService.instance.database;
  final List<Map<String, dynamic>> results = await db.query('subjects');
  for (var row in results) {
    print(row);
  }
}


  @override
  void initState() {
    super.initState();
    // Load from SQLite
    _loadSubjects();
    // Calculate final grade
    updateAverageQPIGrade();
    // Print all subjects for debugging
    printAllSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
    children: [ Scaffold(
      backgroundColor: Colors.white, // Set main background to white
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                'xavLOG',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.0,
                ),
              ),
            ),
          ],
        ),
        toolbarHeight: 60.0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Builder(
          builder: (context) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 380,
                      height: 81,
                      color: Color(0xFF283AA3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 24.0),
                            child: Text(
                              'QPI',
                              style: TextStyle(
                                fontFamily: 'Jost',
                                fontWeight: FontWeight.w600,
                                fontSize: 35.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 24.0),
                            child: Text(
                              finalGrade.toStringAsFixed(2), // Display final grade
                              style: TextStyle(
                                fontFamily: 'Jost',
                                fontWeight: FontWeight.w600,
                                fontSize: 35.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Dinamically generated subject cards
                  if (subjects.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 48.0),
                      child: Center(
                        child: Text(
                          'No Subjects',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  else
                  ...subjects.map((subject) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(subject['subjectTitle']),
                      subtitle: Text('Final Grade: ${subject['finalGrade'] != null ? (subject['finalGrade'] as double).toStringAsFixed(2) : '0.00'}%'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PartitionScreen(
                              subjectTitle: subject['subjectTitle'],
                              id: subject['id'],
                              type: 'subject',
                              subjectId: subject['id'],
                            ),
                          ),
                        );
                        // Reload subjects after returning from PartitionScreen
                        await _loadSubjects();
                        await updateAverageQPIGrade();
                      },
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete Subject'),
                            content: Text('Are you sure you want to delete this subject?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await DatabaseService.instance.deleteSubject(subject['id']);
                                  setState(() {
                                    subjects.remove(subject);
                                  });
                                  await updateAverageQPIGrade();
                                  Navigator.of(context).pop();
                                },
                                child: Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ))
                ],
              ),
            );
          },
        )),
      floatingActionButton: SizedBox(
        width: 68,
        height: 68,
        child: FloatingActionButton(
          onPressed: () {
            // Action to add a new subject
            setState(() {
                _AddSubjectDialog();
            });
          },
          backgroundColor: const Color(0xFF283AA3),
          child: const Icon(Icons.add, size: 34.0, color: Colors.white),
        ),
      ),
    ),
  
    ], 
    );
  }
}

Widget buildInputField(String hintText,
    {bool isLarge = false, required TextEditingController controller}) {
  return Material(
    child: Container(
      width: 323,
      height: isLarge ? 90.9 : 48.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color.fromARGB(255, 217, 217, 219),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
          ),
          style: const TextStyle(
            fontFamily: 'Jost',
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            color: Color(0xFF475569),
          ),
        ),
      ),
    ),
  );
}
