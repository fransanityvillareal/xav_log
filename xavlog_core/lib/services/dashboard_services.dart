import 'package:flutter/material.dart';

import 'package:xavlog_core/services/database_services.dart';

 Widget buildDynamicBarChart(List<Map<String, dynamic>> subjects) {
    // Handle empty data case
    if (subjects.isEmpty) {
      return buildNoDataChart();
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: subjects.take(4).map((subject) {
        final grade = subject['finalGrade'] as double? ?? 0.0;
        final title = subject['subjectTitle'] as String? ?? 'Unknown';
        final percentage = grade / 4.0; // Assuming 4.0 is max grade
        
        return _buildBar(
          title.length > 8 ? title.substring(0, 8) : title,
          percentage,
          percentage > 0.8 ? const Color(0xFF071D99) : const Color(0xFFD7A61F),
        );
      }).toList(),
    );
  }

    Widget buildNoDataChart() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Subject Data',
              style: TextStyle(
                fontFamily: 'Jost',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add subjects to see performance chart',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced function that can be called anywhere
  Future<Widget> buildSubjectPerformanceChart() async {
    try {
      final subjects = await DatabaseService.instance.getSubjectNamesAndGrades();
      
      if (subjects.isEmpty) {
        return buildNoDataChart();
      }
      
      return SizedBox(
        height: 200,
        child: buildDynamicBarChart(subjects),
      );
    } catch (e) {
      return buildErrorChart();
    }
  }

  // Add error chart helper
  Widget buildErrorChart() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: TextStyle(
                fontFamily: 'Jost',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to load subject performance',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String label, double value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 40,
          height: 150 * value,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontFamily: 'Jost', fontSize: 12),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${(value * 100).toInt()}%',
          style: const TextStyle(
            fontFamily: 'Jost',
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }


//Getters
  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Task':
        return Icons.school;
      case 'Project':
        return Icons.assignment;
      case 'Event':
        return Icons.groups;
      default:
        return Icons.event;
    }
  }

  String formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
