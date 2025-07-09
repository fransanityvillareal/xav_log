library;

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'profile.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xavlog_core/services/database_services.dart';
import 'package:xavlog_core/services/dashboard_services.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key}); //(Key? key) : super(Key? keu)

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String _name = 'Loading...';
  String _averageQPI = 'Loading...';
  String _topSubject = 'Loading...'; 
  String _totalSubjects = 'Loading...';
  String _totalUnits = 'Loading...';
  String _description = '';
  String _profileImageUrl = 'https://i.imgur.com/4STeKWS.png'; // Default image URL

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Task'; // Default category
  DateTime _selectedDate = DateTime.now();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final List<String> _activityCategories = [
    'Task',
    'Project',
    'Event',
  ];

  // Activities shown on the dashboard
  // BACKEND: Should be fetched from API based on user ID and relevance
  // DYNAMIC: Should update in real-time as new activities are added
  // Example activities
    // Activity(
    //   title: 'Midterm Examination',
    //   description: 'Comprehensive exam covering chapters 1-5',
    //   date: DateTime.now()
    //       .add(const Duration(days: 2)), // DYNAMIC: Calculate from current date
    //   category: 'Academic', // Used for filtering and categorization
    // ),
    
    //Add more activities as needed through add button on upcoming activities
  List<Activity> activities = [];
  bool _isLoadingActivities = false;

  // Upload activity to Firebase
  Future<void> _uploadActivityToFirebase() async {
    if (_titleController.text.isEmpty) return;
    
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    
    try {
      await FirebaseFirestore.instance.collection('user_activities').add({
        'userId': currentUser.uid,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'date': Timestamp.fromDate(_selectedDate),
        'category': _selectedCategory,
        'createdAt': FieldValue.serverTimestamp(),    // pwede tikalin
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity added successfully!')),
      );
      
      // Refresh the activities list
      await _loadActivitiesFromFirebase();
        
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding activity: $e')),
      );
    }
  }

  // Load activities from Firebase
  Future<void> _loadActivitiesFromFirebase() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    
    setState(() {
      _isLoadingActivities = true;
    });
    
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('user_activities')
          .where('userId', isEqualTo: currentUser.uid)
          .get();
      
      final loadedActivities = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Activity(
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          date: (data['date'] as Timestamp).toDate(),
          category: data['category'] ?? 'Academic',
          documentId: doc.id,
        );
      }).toList();
      loadedActivities.sort((a, b) => a.date.compareTo(b.date));
      
      setState(() {
        activities = loadedActivities;
        _isLoadingActivities = false;
      });
      
    } catch (e) {
      setState(() {
        _isLoadingActivities = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading activities: $e')),
      );
    }
  }

  //delete from both Firebase and local storage
  Future<void> _deleteActivity(int index) async {
    try {
      final activity = activities[index];
      
      // Show confirmation dialog
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Activity'),
          content: Text('Are you sure you want to delete "${activity.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      
      if (shouldDelete == true) {
        // Remove from local list
        setState(() {
          activities.removeAt(index);
        });
        
        // Delete from Firebase
        if (activity.documentId != null) {
          try {
            await FirebaseFirestore.instance
                .collection('user_activities')
                .doc(activity.documentId!)
                .delete();
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Activity deleted successfully!')),
            );
            
          } catch (e) {
            // If Firebase deletion fails, show error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Warning: Failed to sync deletion with server: $e')),
            );
          }
        }
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting activity: $e')),
      );
    }
  }

  void _showAddActivityDialog() {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final fontSize = width * 0.03;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Add New Activity',
            style: TextStyle(
              fontSize: fontSize * 1.3,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF071D99),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter activity title',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter activity description',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _activityCategories.map((String category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(
                    '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _titleController.clear();
                _descriptionController.clear();
                _selectedCategory = 'Academic';
                _selectedDate = DateTime.now();
              },
              child: const Text('Cancel'),
            ),
           ElevatedButton(
            onPressed: () async {
              if (_titleController.text.isNotEmpty) {
                await _uploadActivityToFirebase();
                
                Navigator.pop(context);
                _titleController.clear();
                _descriptionController.clear();
                _selectedCategory = 'Academic';
                _selectedDate = DateTime.now();
              }
            },
            child: const Text('Add Activity'),
          ),
          ],
        );
      },
    );
  }

  final List<String> _carouselImages = [
    'https://i0.wp.com/dateline-ibalon.com/wp-content/uploads/2024/01/Fr-Olin-adnu-church-wally-ocampo-ritratos-ni-wally.jpg?resize=930%2C450&ssl=1',
    'https://ol-content-api.global.ssl.fastly.net/sites/default/files/styles/scale_and_crop_center_890x320/public/2023-01/ateneodenaga-banner-1786x642.jpg?itok=oNejbYDa', // Added Ateneo de Naga University logo
    'https://jhs.adnu.edu.ph/pluginfile.php/17657/mod_page/content/12/main-campus.jpg',
    'https://live.staticflickr.com/2336/2144157090_cb221623eb_h.jpg',
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF071D99),
            colorScheme: const ColorScheme.light(primary: Color(0xFF071D99)),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Calculate final grade for all subjects
  Future<void> _loadAverageQPI() async {
    try {
      final qpi = await DatabaseService.instance.calculateAverageQPI();
      setState(() {
        _averageQPI = qpi.toStringAsFixed(2);
      });
    } catch (e) {
      setState(() {
        _averageQPI = 'Error';
      });
    }
  }

  //gets the top subjects
  Future<void> _loadTopSubject() async {
    try {
      final topSubjectCode = await DatabaseService.instance.getTopPerformingSubjectCode();
      setState(() {
        _topSubject = topSubjectCode ?? 'No data';
      });
    } catch (e) {
      setState(() {
        _topSubject = 'Error';
      });
    }
  }

  // Count upcoming tasks specifically
  int _getUpcomingActivitiesCount() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextWeek = today.add(const Duration(days: 7));
    
    return activities.where((activity) {
      final activityDate = DateTime(activity.date.year, activity.date.month, activity.date.day);
      return (activity.category == 'Project' || activity.category == 'Task') &&
            activityDate.compareTo(today) >= 0 && // Today or after
            activityDate.compareTo(nextWeek) < 0;  // Before next week
    }).length;
  }

  // Count upcoming events specifically
  int _getUpcomingEventsCount() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextWeek = today.add(const Duration(days: 7));
    
    return activities.where((activity) {
      final activityDate = DateTime(activity.date.year, activity.date.month, activity.date.day);
      return activity.category == 'Event' && 
            activityDate.compareTo(today) >= 0 && // Today or after
            activityDate.compareTo(nextWeek) < 0;  // Before next week
    }).length;
  }

  Future<void> _loadTotalSubjects() async {
    try {
      final count = await DatabaseService.instance.getTotalSubjectsCount();
      setState(() {
        _totalSubjects = count;
      });
    } catch (e) {
      setState(() {
        _totalSubjects = 'Error';
      });
    }
  }

  Future<void> _loadTotalUnits() async {
    try {
      final units = await DatabaseService.instance.getTotalUnits();
      setState(() {
        _totalUnits = units;
      });
    } catch (e) {
      setState(() {
        _totalUnits = 'Error';
      });
    }
  }

  Widget _buildAnalyticsSummary() {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final fontSize = width * 0.03;

    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                fontFamily: 'Jost',
                color: Color(0xFF071D99),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              color: Colors.white,
              shadowColor: Color(0xFF071D99),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      children: [
                        /////////////// change numbers according to computations of analytics //////////////
                        _buildStatCard(
                          'Average QPI',
                          _averageQPI,
                          Icons.assignment,
                          fontSize * 1.5,
                        ),
                        _buildStatCard(
                          'Excelling',
                          _topSubject,
                          Icons.trending_up,
                          fontSize * 1.5,
                        ),
                        _buildStatCard(
                          'Upcoming Activities',
                          _getUpcomingActivitiesCount().toString(),
                          Icons.class_,
                          fontSize * 1.5,
                        ),
                        _buildStatCard(
                          'Upcoming Events',
                          _getUpcomingEventsCount().toString(),
                          Icons.event,
                          fontSize * 1.5,
                        ),
                      ],
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(
                        Icons.analytics,
                        color: Color(0xFF071D99),
                      ),
                      title: const Text('View Full Analytics'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        _showAnalyticsSheet();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnalyticsSheet() {
  final screenSize = MediaQuery.of(context).size;
  final width = screenSize.width;
  final fontSize = width * 0.035;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: screenSize.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detailed Analytics',
                  style: TextStyle(
                    fontFamily: 'Jost',
                    fontSize: fontSize * 1.4,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF071D99),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Academic Performance Section
                _buildDetailedSection(
                  'Academic Performance',
                  fontSize,
                  [
                    _buildDetailCard(
                      'Average QPI',
                      _averageQPI,
                      Icons.assignment,
                      Colors.blue,
                      'Current semester QPI based on all subjects',
                    ),
                    _buildDetailCard(
                      'Top Subject',
                      _topSubject,
                      Icons.trending_up,
                      Colors.green,
                      'Subject with highest grade performance',
                    ),
                    _buildStatRow('Total Subjects',_totalSubjects , Icons.school),
                    _buildStatRow('Total Units', _totalUnits, Icons.book),
                  ],
                ),

                const SizedBox(height: 20),

                // Subject Performance Chart
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subject Performance Overview',
                          style: TextStyle(
                            fontFamily: 'Jost',
                            fontSize: fontSize * 1.2,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF071D99),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FutureBuilder<Widget>(
                          future: buildSubjectPerformanceChart(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(
                                height: 200,
                                child: Center(child: CircularProgressIndicator()),
                              );
                            } else {
                              return snapshot.data ?? buildErrorChart();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Activity Management Section
                _buildDetailedSection(
                  'Activity Management',
                  fontSize,
                  [
                    _buildDetailCard(
                      'Upcoming Tasks & Projects',
                      _getUpcomingActivitiesCount().toString(),
                      Icons.assignment_turned_in,
                      Colors.orange,
                      'Tasks and projects due in the next 7 days',
                    ),
                    _buildDetailCard(
                      'Upcoming Events',
                      _getUpcomingEventsCount().toString(),
                      Icons.event,
                      Colors.purple,
                      'Events scheduled for the next 7 days',
                    ),
                    _buildStatRow('Total Activities', activities.length.toString(), Icons.list),
                    _buildStatRow('This Week', _getThisWeekActivitiesCount().toString(), Icons.date_range),
                  ],
                ),

                const SizedBox(height: 20),

                // Activity Breakdown Chart
                Card(
                  color: const Color(0xFFF5F5F5),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activity Breakdown',
                          style: TextStyle(
                            fontFamily: 'Jost',
                            fontSize: fontSize * 1.2,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF071D99),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildActivityPieChart('Tasks', _getTaskCount(), const Color(0xFF071D99)),
                            _buildActivityPieChart('Projects', _getProjectCount(), const Color(0xFFD7A61F)),
                            _buildActivityPieChart('Events', _getEventCount(), Colors.green),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),

                // Productivity Insights
                _buildDetailedSection(
                  'Productivity Insights',
                  fontSize,
                  [
                    _buildProductivityCard('Most Active Day', _getMostActiveDay(), Icons.calendar_today),
                    _buildProductivityCard('Average Activities/Week', _getAverageActivitiesPerWeek().toString(), Icons.trending_up),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  // Helper methods for the enhanced analytics
  Widget _buildDetailedSection(String title, double fontSize, List<Widget> children) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Jost',
                fontSize: fontSize * 1.2,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF071D99),
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }



Widget _buildDetailCard(String title, String value, IconData icon, Color color, String description) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.bold),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildStatRow(String label, String value, IconData icon) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF071D99)),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontFamily: 'Jost'))),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Jost',
            fontWeight: FontWeight.bold,
            color: Color(0xFF071D99),
          ),
        ),
      ],
    ),
  );
}

Widget _buildProductivityCard(String title, String value, IconData icon) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.blue.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(fontFamily: 'Jost'))),
        Text(value, style: const TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

Widget _buildActivityPieChart(String label, int count, Color color) {
  final total = activities.length;
  final percentage = total > 0 ? count / total : 0.0;
  
  return Column(
    children: [
      Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: percentage,
              strokeWidth: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Text(
            count.toString(),
            style: const TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.bold),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(fontFamily: 'Jost', fontSize: 12)),
    ],
  );
}

int _getThisWeekActivitiesCount() {
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final endOfWeek = startOfWeek.add(const Duration(days: 6));
  
  return activities.where((activity) {
    return activity.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           activity.date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }).length;
}

String _getMostActiveDay() {
  if (activities.isEmpty) return 'No data';
  
  final dayCount = <String, int>{};
  final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  
  for (var activity in activities) {
    final dayName = days[activity.date.weekday - 1];
    dayCount[dayName] = (dayCount[dayName] ?? 0) + 1;
  }
  
  if (dayCount.isEmpty) return 'No data';
  
  final mostActiveDay = dayCount.entries.reduce((a, b) => a.value > b.value ? a : b);
  return mostActiveDay.key;
}

double _getAverageActivitiesPerWeek() {
  if (activities.isEmpty) return 0;
  
  final weeks = activities.length > 0 ? 
    (activities.last.date.difference(activities.first.date).inDays / 7).ceil() : 1;
  return activities.length / weeks;
}

int _getTaskCount() => activities.where((a) => a.category == 'Task').length;
int _getProjectCount() => activities.where((a) => a.category == 'Project').length;
int _getEventCount() => activities.where((a) => a.category == 'Event').length;


  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    double fontSize,
  ) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF071D99), size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Jost',
              color: Color(0xFF071D99),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: fontSize * 0.8,
              fontFamily: 'Inter',
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingActivities() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Activities',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                fontFamily: 'Jost',
                color: Color(0xFF071D99),
              ),
            ),
            GestureDetector(
              onTap: _showAddActivityDialog,
              child: Tooltip(
                message: 'Add Activity',
                child: CircleAvatar(
                  backgroundColor: const Color(0xFFD7A61F),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Replace StreamBuilder with conditional rendering
        _isLoadingActivities
            ? const Center(child: CircularProgressIndicator())
            : activities.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No activities yet. Add your first activity!',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      
                      return Card(
                        color: Colors.white,
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF071D99).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              getCategoryIcon(activity.category),
                              color: const Color(0xFF071D99),
                            ),
                          ),
                          title: Text(
                            activity.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF071D99),
                            ),
                          ),
                          subtitle: Text(
                            formatDate(activity.date),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteActivity(index),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.category,
                                        size: 20,
                                        color: Color(0xFF071D99),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Category: ${activity.category}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.description,
                                        size: 20,
                                        color: Color(0xFF071D99),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          activity.description,
                                          style: TextStyle(color: Colors.grey[800]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ],
    ),
  );
}
  List<Activity> _getEventsForDay(DateTime day) {
    return activities
        .where(
          (activity) =>
              activity.date.year == day.year &&
              activity.date.month == day.month &&
              activity.date.day == day.day,
        )
        .toList();
  }
  void _showEventsBottomSheet(DateTime selectedDay) {
    final screenSize = MediaQuery.of(context).size;
    final fontSize = screenSize.width * 0.03;
    final events = _getEventsForDay(selectedDay);

    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Activities on ${selectedDay.month}/${selectedDay.day}/${selectedDay.year}',
                          style: TextStyle(
                            fontSize: fontSize * 1.2,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF071D99),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  events.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'No events for this day',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: fontSize,
                            ),
                          ),
                        )
                      : Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              final event = events[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF071D99,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      getCategoryIcon(event.category),
                                      color: const Color(0xFF071D99),
                                    ),
                                  ),
                                  title: Text(
                                    event.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF071D99),
                                    ),
                                  ),
                                  subtitle: Text(event.description),
                                ),
                              );
                            },
                          ),
                        ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
                ],
              ),
            ));
  }

  Widget _buildCalendarSection() {
    final screenSize = MediaQuery.of(context).size;
    final fontSize = screenSize.width * 0.03;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Calendar',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              fontFamily: 'Jost',
              color: const Color(0xFF071D99),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD7A61F)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _showEventsBottomSheet(selectedDay);
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  eventLoader: _getEventsForDay,
                  calendarStyle: const CalendarStyle(
                    markersMaxCount: 3,
                    markerDecoration: BoxDecoration(
                      color: Color(0xFF071D99),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Color(0xFF071D99),
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Color(0xFFD7A61F),
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: fontSize * 1.2,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF071D99),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _loadActivitiesFromFirebase();
    _loadAverageQPI();
    _loadTopSubject();
    _loadTotalSubjects();
    _loadTotalUnits(); 
  }

  Future<void> _fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _name =
              '${data?['firstName'] ?? 'NoName'} ${data?['lastName'] ?? ''}';
          _description =
              '${data?['program'] ?? ''} - ${data?['department'] ?? ''}';
          // Fetch profile image from Firestore, fallback to placeholder
          String url =
              data?['profileImageUrl'] ?? 'https://picsum.photos/200?random=1';
          // Add a timestamp to avoid caching issues
          _profileImageUrl = '$url?ts=${DateTime.now().millisecondsSinceEpoch}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final fontSize = width * 0.03;

    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        backgroundColor:
            const Color.fromARGB(255, 255, 255, 255), // Blue background
        body: SingleChildScrollView(
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).padding.top + 30),
          child: Column(
            children: [
              // Profile Section
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 32.0,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF071D99),
                      Color(0xFFD7A61F),
                    ], // Blue to Yellow gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(
                              isOrganization: false,
                              orgName: _name,
                              description: _description,
                            ),
                          ),
                        )
                            .then((result) {
                          // Update dashboard with the returned profile data
                          if (result != null &&
                              result is Map<String, dynamic>) {
                            setState(() {
                              _name = result['name'] ?? _name;
                              _description =
                                  result['description'] ?? _description;
                            });
                          }
                        });
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Hero(
                          tag: 'orgProfileImage',
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(_profileImageUrl),
                            onBackgroundImageError: (_, __) {
                              setState(() {
                                _profileImageUrl =
                                    'https://i.imgur.com/4STeKWS.png';
                              });
                            },
                            child: _profileImageUrl.isEmpty
                                ? const Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Color(0xFF071D99),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $_name',
                            style: TextStyle(
                              fontSize: fontSize * 1.4,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Jost',
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _description,
                            style: TextStyle(
                              fontSize: fontSize * 1.2,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Carousel Banner with shimmer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildCarouselBanner(context),
              ),

              const SizedBox(height: 20),

              // Analytics Summary
              _buildAnalyticsSummary(),

              const SizedBox(height: 20),

              const SizedBox(height: 20),

              // Calendar Section
              _buildCalendarSection(),

              const SizedBox(height: 20),

              // Upcoming Activities
              _buildUpcomingActivities(),
            ],
          ),
        ),
      ),
    );
  }

// Bottom Navigation Bar


  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- Carousel Banner ---
  Widget _buildCarouselBanner(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: SizedBox(
        width: screenWidth > 700 ? 700 : screenWidth * 0.95,
        child: CarouselSlider.builder(
          itemCount: _carouselImages.length,
          itemBuilder: (context, index, realIdx) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                _carouselImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: 160,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;

                  // Show shimmer while loading
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      color: Colors.grey[300],
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  // Also show shimmer if there's an error loading the image
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      color: Colors.grey[300],
                    ),
                  );
                },
              ),
            );
          },
          options: CarouselOptions(
            height: 160,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.92,
            aspectRatio: 2.1,
            initialPage: 0,
          ),
        ),
      ),
    );
  }
}

class ScheduleManagerPage extends StatelessWidget {
  const ScheduleManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Manager'),
      ),
      body: const Center(
        child: Text('Schedule Manager Page'),
      ),
    );
  }
}

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: const Center(
        child: Text('Calendar Page'),
      ),
    );
  }
}

class DashboardItem {
  final String title;
  final IconData icon;
  final String type;

  DashboardItem({required this.title, required this.icon, this.type = 'page'});
}

class Activity {
  final String title;
  final String description;
  final DateTime date;
  final String category;
  final String? documentId;
  bool isExpanded;

  Activity({
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    this.documentId,
    this.isExpanded = false,
  });
}
