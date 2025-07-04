import 'package:flutter/material.dart';

import 'package:xavlog_core/services/database_services.dart';
import 'package:auto_size_text/auto_size_text.dart';

class PartitionScreen extends StatefulWidget {
  final String subjectTitle;
  final int id;
  final int subjectId; 
  final String type;
  const PartitionScreen({
    super.key,
    required this.type,
    required this.subjectTitle, 
    required this.id,
    required this.subjectId,
    });
  
  
  @override
  State<PartitionScreen> createState() => _PartitionScreenState();
}

class _PartitionScreenState extends State<PartitionScreen> {
  Map<String, dynamic>? selfDetails = {};
  List<Map<String, dynamic>> components = [];
    // Example components
  //   {
  //   'type': 'partition',
  //   'id': '2',
  //   'subjectCode': 'CS101',
  //   'parentId': '1',
  //   'name': 'Midterm',
  //   'percentage': 0.0,
  // },
  String? errorMessage;

  //bool showOverlay = false;
  double displayGrade = 0.0;
  final TextEditingController partitionNameController = TextEditingController();
  final TextEditingController percentageController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController classworkNameController = TextEditingController();
  final TextEditingController classworkScoreController = TextEditingController();
  final TextEditingController classworkMaxScoreController = TextEditingController();
  bool showClassworkOverlay = false;

  void _showAddComponentDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Add Component'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.layers, color: Color(0xFFD7A61F)),
              label: Text('Add Partition', style: TextStyle(color: Color(0xFFD7A61F))),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(color: Color(0xFFD7A61F)),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _addPartition();
              },
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.assignment, color: Color(0xFF283AA3)),
              label: Text('Add Classwork', style: TextStyle(color: Color(0xFF283AA3))),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(color: Color(0xFF283AA3)),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _addClasswork();
              },
            ),
          ],
        ),
      );
    },
  );
}
//CREATE functions
  void _addPartition() {
    // Clear controllers before showing dialog
    partitionNameController.clear();
    percentageController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Partition'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildInputField("Partition Name* (e.g., Exams)", controller: partitionNameController),
                SizedBox(height: 18),
                buildInputField("Percentage*", controller: percentageController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (partitionNameController.text.isNotEmpty &&
                    percentageController.text.isNotEmpty &&
                    double.tryParse(percentageController.text) != null) {
                  // Add to database first
                  int? parentId;
                  if (widget.type == 'partition') {
                    // If this is a sub-partition, use the current partition's id
                    parentId = widget.id;
                  } else if (widget.type == 'subject') {
                    // If this is a top-level partition, parentId can be null
                    parentId = null;
                  }

                  int id = await DatabaseService.instance.addPartition(
                    'partition',
                    widget.subjectId, // parentSubjectId
                    parentId, // parentId can be null for top-level partitions
                    partitionNameController.text,
                    double.tryParse(percentageController.text) ?? 0.0,
                  );

                  final newComponent = {
                    'type': 'partition',
                    'id': id,
                    'parentSubjectId': widget.subjectId,
                    'parentId': parentId,
                    'partitionName': partitionNameController.text,
                    'percentage': double.tryParse(percentageController.text) ?? 0.0,
                    'description': descriptionController.text,
                  };
                  setState(() {
                    components.add(newComponent);
                  });
                  await _updateDisplayGrade();
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill in all required fields.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
    
  }

  //Add classworks
  void _addClasswork() {
    // Clear controllers before showing dialog
    classworkNameController.clear();
    classworkScoreController.clear();
    classworkMaxScoreController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Classwork'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildInputField("Classwork Name*", controller: classworkNameController),
                SizedBox(height: 18),
                buildInputField("Score", controller: classworkScoreController),
                SizedBox(height: 18),
                buildInputField("Max Score*", controller: classworkMaxScoreController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (classworkNameController.text.isNotEmpty &&
                    classworkMaxScoreController.text.isNotEmpty &&
                    double.tryParse(classworkScoreController.text) != null &&
                    double.tryParse(classworkMaxScoreController.text) != null) {
                  int? parentId;
                  if (widget.type == 'partition') {
                    parentId = widget.id;
                  } else {
                    parentId = null;
                  }

                  int id = await DatabaseService.instance.addClasswork(
                    'classwork',
                    widget.subjectId,
                    parentId,
                    classworkNameController.text,
                    double.tryParse(classworkScoreController.text) ?? 0.0,
                    double.tryParse(classworkMaxScoreController.text) ?? 0.0,
                    0.0, // You can calculate percentage later if needed
                  );

                  final newClasswork = {
                    'type': 'classwork',
                    'id': id,
                    'parentSubjectId': widget.subjectId,
                    'parentId': parentId,
                    'name': classworkNameController.text,
                    'score': double.tryParse(classworkScoreController.text) ?? 0.0,
                    'maxScore': double.tryParse(classworkMaxScoreController.text) ?? 0.0,
                    'percentage': 0.0,
                  };
                  setState(() {
                    components.add(newClasswork);
                  });
                  await _updateDisplayGrade();
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill in all required fields.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  //Update a classwork by ID
  void _updateClassworkById(int classworkId) async {
    // Find the classwork in the components list
    final index = components.indexWhere((c) => c['type'] == 'classwork' && c['id'] == classworkId);
    if (index == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Classwork not found.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Pre-fill controllers with current values
    classworkNameController.text = components[index]['name'] ?? '';
    classworkScoreController.text = components[index]['score']?.toString() ?? '';
    classworkMaxScoreController.text = components[index]['maxScore']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Edit Classwork'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildInputField("Classwork Name*", controller: classworkNameController),
              SizedBox(height: 18),
              buildInputField("Score*", controller: classworkScoreController),
              SizedBox(height: 18),
              buildInputField("Max Score*", controller: classworkMaxScoreController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (classworkNameController.text.isNotEmpty &&
                  classworkScoreController.text.isNotEmpty &&
                  classworkMaxScoreController.text.isNotEmpty &&
                  double.tryParse(classworkScoreController.text) != null &&
                  double.tryParse(classworkMaxScoreController.text) != null) {
                await DatabaseService.instance.updateClasswork(
                  classworkId,
                  {
                    'name': classworkNameController.text,
                    'score': double.tryParse(classworkScoreController.text) ?? 0.0,
                    'maxScore': double.tryParse(classworkMaxScoreController.text) ?? 0.0,
                  },
                );
                setState(() {
                  components[index]['name'] = classworkNameController.text;
                  components[index]['score'] = double.tryParse(classworkScoreController.text) ?? 0.0;
                  components[index]['maxScore'] = double.tryParse(classworkMaxScoreController.text) ?? 0.0;
                });
              await _loadComponents();
              await _updateDisplayGrade();
              Navigator.of(dialogContext).pop(); 
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill in all required fields.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
  //update partition by ID


//READ functions
  Future<void> _loadComponents() async {
    List<Map<String, dynamic>> loadedComponents = [];
    if (widget.type == 'partition') {
      // Load components for a partition
      loadedComponents = await DatabaseService.instance.getComponents(widget.id);
    } else if (widget.type == 'subject') {
      // Load top-level components for a subject
      loadedComponents = await DatabaseService.instance.getTopLevelComponents(widget.subjectId);
    }

    setState(() {
      components = List<Map<String, dynamic>>.from(loadedComponents);
      errorMessage = null;
    });
    await _updateDisplayGrade();
  }

//UPDATE functions
  void _updatePartitionById(int partitionId) async {
    // Fetch the partition details from the database
    final partition = await DatabaseService.instance.getPartition(partitionId);
    print('Row to be updated: $partition');
    if (partition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Partition not found.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final TextEditingController nameController = TextEditingController(text: partition['partitionName'] ?? '');
    final TextEditingController percentageController = TextEditingController(text: partition['percentage']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Partition'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildInputField("Partition Name*", controller: nameController),
              SizedBox(height: 18),
              buildInputField("Percentage*", controller: percentageController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  percentageController.text.isNotEmpty &&
                  double.tryParse(percentageController.text) != null) {
                await DatabaseService.instance.updatePartition(
                  partitionId,
                  {
                    'partitionName': nameController.text,
                    'percentage': double.tryParse(percentageController.text) ?? 0.0,
                  },
                );
                setState(() {
                  selfDetails?['partitionName'] = nameController.text;
                  selfDetails?['percentage'] = double.tryParse(percentageController.text) ?? 0.0;
                });
                await _updateDisplayGrade();
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill in all required fields.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  //update Subject
  void _updateSubjectById(int subjectId) async {
    // Fetch the subject details from the database
    final subject = await DatabaseService.instance.getSubject(subjectId);
    if (subject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Subject not found.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final TextEditingController codeController = TextEditingController(text: subject['subjectCode'] ?? '');
    final TextEditingController titleController = TextEditingController(text: subject['subjectTitle'] ?? '');
    final TextEditingController unitsController = TextEditingController(text: subject['units']?.toString() ?? '');
    final TextEditingController descriptionController = TextEditingController(text: subject['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Subject'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildInputField("Subject Code*", controller: codeController),
              SizedBox(height: 12),
              buildInputField("Subject Title*", controller: titleController),
              SizedBox(height: 12),
              buildInputField("Units*", controller: unitsController),
              SizedBox(height: 12),
              buildInputField("Description", controller: descriptionController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (codeController.text.isNotEmpty &&
                  titleController.text.isNotEmpty &&
                  unitsController.text.isNotEmpty) {
                await DatabaseService.instance.updateSubject(
                  subjectId,
                  {
                    'subjectCode': codeController.text,
                    'subjectTitle': titleController.text,
                    'units': double.tryParse(unitsController.text) ?? 0.0,
                    'description': descriptionController.text,
                  },
                );
                setState(() {
                  selfDetails?['subjectCode'] = codeController.text;
                  selfDetails?['subjectTitle'] = titleController.text;
                  selfDetails?['units'] = double.tryParse(unitsController.text) ?? 0.0;
                  selfDetails?['description'] = descriptionController.text;
                });
                await _updateDisplayGrade();
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill in all required fields.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  //Update grade display
  Future<void> _updateDisplayGrade() async {
    double grade = 0.0;
    if (widget.type == 'subject') {
      // Calculate and update the subject's final grade
      grade = await DatabaseService.instance.calculateFinalGrade(widget.id);
      await DatabaseService.instance.updateFinalGrade(widget.id, grade);
    } else if (widget.type == 'partition') {
      // Calculate the partition's grade
      grade = await DatabaseService.instance.calculatePartitionGrade(widget.id);
    }
    setState(() {
      displayGrade = grade;
    });
  }

  Widget buildInputField(String label, {required TextEditingController controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      keyboardType: label.contains('Percentage') || label.contains('Score') || label.contains('Max Score') ? TextInputType.number : TextInputType.text,
    );
  }


//DELETE functions
  void _deleteComponent(int id, String type) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type == 'partition' ? 'Delete Partition' : 'Delete Classwork'),
        content: Text('Are you sure you want to delete this ${type == 'partition' ? 'partition' : 'classwork'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Delete from database based on type
              if (type == 'partition') {
                await DatabaseService.instance.deletePartition(id);
              } else if (type == 'classwork') {
                await DatabaseService.instance.deleteClasswork(id);
              }
              // Remove from local state
              setState(() {
                components.removeWhere((component) => component['id'] == id && component['type'] == type);
              });
              await _updateDisplayGrade();
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // Load from SQLite based on type and id

    Future.microtask(() async {
      Map<String, dynamic>? details = {};
      if (widget.type == 'partition') {
        details = await DatabaseService.instance.getPartition(widget.id);
      } else if (widget.type == 'subject') {
        details = await DatabaseService.instance.getSubject(widget.id);
      }

      if (details == null) {
        setState(() {
          errorMessage = 'No details found for this partition.';
        });
        return;
      }
      setState(() {
        selfDetails = Map<String, dynamic>.from(details ?? {});
        errorMessage = null;
      });
    });
    // Load components
    _loadComponents();
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 64),
            SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(
                color: Colors.red,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Tap anywhere to go back',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
    return Stack(
    children: [ Scaffold(
      backgroundColor: Colors.white, // Set main background to white
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Text(
              widget.subjectTitle,
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Builder(
          builder: (context) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GestureDetector(
                      onLongPress: () {
                        if (widget.type == 'partition') {
                          _updatePartitionById(widget.id);
                        } else if (widget.type == 'subject') {
                          _updateSubjectById(widget.id);
                        }
                      },
                      child: Container(
                        width: 380,
                        height: 81,
                        color: Color(0xFFD7A61F),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 24.0),
                              child: SizedBox(
                                width: 180,
                                child: AutoSizeText(
                                  widget.type == 'partition'
                                    ? (selfDetails?['partitionName'] ?? 'Partition Name')
                                    : (selfDetails?['subjectTitle'] ?? 'Subject Title'),
                                  style: TextStyle(
                                    fontFamily: 'Jost',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 35.0,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  minFontSize: 10,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 24.0),
                              child: Text(
                                displayGrade.toStringAsFixed(2),
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
                  ),
                  // Dinamically generated cards
                  if (components.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 48.0),
                      child: Center(
                        child: Text(
                          'No components',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  else
                   ...components.map((component) {
                    if (component['type'] == 'partition') {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: Icon(Icons.layers, color: Color(0xFFD7A61F)),
                          title: Text(
                            component['partitionName'] ?? component['name'] ?? 'Unknown',
                            style: TextStyle(color: Color(0xFFD7A61F), fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Partition • ${component['percentage']}%',
                            style: TextStyle(color: Color(0xFFD7A61F)),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFFD7A61F)),
                          onTap: () async{
                            // Navigate to partition details or edit screen
                          
                            print('Navigating to partition with id: ${component['id']}');
                            print('Navigating to partition with subjectId: ${widget.subjectId}');
                            print('Navigating to partition with subjectTitle: ${widget.subjectTitle}');
                            print('Navigating to partition with type: ${component['type']}');
                            print('Navigating to partition with parentId: ${component['parentId']}');

                            await Navigator.push(
                              context,
                              
                              MaterialPageRoute(

                                //ALL OF THIS IS A PLACEHOLDER, ADJUST AS NEEDED

                                builder: (context) => PartitionScreen(
                                  subjectTitle: widget.subjectTitle,
                                  id: component['id'],
                                  type: 'partition',
                                  subjectId: widget.subjectId, // Pass the subjectId
                                ),
                              ),
                            );
                            await _loadComponents(); // Reload components after navigation
                            await _updateDisplayGrade();
                          },
                          onLongPress: () {
                            _deleteComponent(component['id'], component['type']);
                          },
                          
                        ),
                      );
                    } else if (component['type'] == 'classwork') {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: Icon(Icons.assignment, color: Color(0xFF283AA3)),
                          title: Text(
                            component['name'],
                            style: TextStyle(color: Color(0xFF283AA3), fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Classwork • ${component['score']}/${component['maxScore']}',
                            style: TextStyle(color: Color(0xFF283AA3)),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFF283AA3)),
                          onTap: () {
                            setState(() {
                              _updateClassworkById(component['id']);
                            });
                          },
                          onLongPress: () {
                            _deleteComponent(component['id'], component['type']);
                          },
                        ),
                      );
                    } else {
                      // fallback for unknown type
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(component['name'] ?? 'Unknown'),
                        ),
                      );
                    }
                  }),
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
            // Action to add a new component
            setState(() {
              _showAddComponentDialog();
            });
          },
          backgroundColor: const Color(0xFFD7A61F),
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