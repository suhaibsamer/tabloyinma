import 'package:flutter/material.dart';
import 'package:tabloy_iman/services/call_times_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class CallTimesPage extends StatefulWidget {
  const CallTimesPage({super.key});

  @override
  State<CallTimesPage> createState() => _CallTimesPageState();
}

class _CallTimesPageState extends State<CallTimesPage> {
  List<Map<String, dynamic>> _callTimes = [];
  Map<String, dynamic>? _nextCallAtHome;

  @override
  void initState() {
    super.initState();
    _loadCallTimes();
    _loadNextCallAtHome();
  }

  Future<void> _loadCallTimes() async {
    final callTimes = await CallTimesService.getCallTimes();
    setState(() {
      _callTimes = callTimes;
    });
  }

  Future<void> _loadNextCallAtHome() async {
    final prefs = await SharedPreferences.getInstance();
    final nextCallJson = prefs.getString('next_call_at_home');

    if (nextCallJson != null) {
      final Map<String, dynamic> nextCall = json.decode(nextCallJson);
      setState(() {
        _nextCallAtHome = nextCall;
      });
    }
  }

  Future<void> _setNextCallAtHome() async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 9, 0); // Default to 9 AM tomorrow

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: tomorrow,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(tomorrow),
      );

      if (selectedTime != null && mounted) {  // Check mounted here as well
        final scheduledDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        final nextCall = {
          'datetime': scheduledDateTime.toIso8601String(),
          'note': 'Next call at home',
        };

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('next_call_at_home', json.encode(nextCall));

        if (mounted) {  // Check if widget is still mounted
          setState(() {
            _nextCallAtHome = nextCall;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Next call at home scheduled successfully')),
          );
        }
      }
    }
  }

  Future<void> _removeNextCallAtHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('next_call_at_home');

    if (mounted) {  // Check if widget is still mounted
      setState(() {
        _nextCallAtHome = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scheduled call removed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        title: const Text(
          'کاتی گوتن',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'add_incoming') {
                _addSampleCallTime('incoming');
              } else if (value == 'add_outgoing') {
                _addSampleCallTime('outgoing');
              } else if (value == 'schedule_next') {
                _setNextCallAtHome();
              } else if (value == 'clear') {
                _confirmClearCallTimes();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_incoming',
                child: Text('زیادکردنی گوتنی هاتوو'),
              ),
              const PopupMenuItem(
                value: 'add_outgoing',
                child: Text('زیادکردنی گوتنی چوو'),
              ),
              const PopupMenuItem(
                value: 'schedule_next',
                child: Text('دیاریکردنی داهاتوو'),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Text('سڕینەوەی هەموو'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Next Call At Home Section
          if (_nextCallAtHome != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2d2d2d),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     Text(
                          'دیاریکراوە بۆ ماوەی داهاتوو',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),


                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: _removeNextCallAtHome,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3a3a3a),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.home,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDateTime(_nextCallAtHome!['datetime']),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _nextCallAtHome!['note'],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // All Call Times Section
          Expanded(
            child: _callTimes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.phone_missed,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'هیچ کاتی گوتن نیه',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'کاتی گوتنەکانت دەتوانرێت لێرەدا نیشان بدەرێت',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadCallTimes,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _callTimes.length,
                      itemBuilder: (context, index) {
                        final callTime = _callTimes[index];
                        return _buildCallTimeCard(callTime);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallTimeCard(Map<String, dynamic> callTime) {
    final dateTime = DateTime.parse(callTime['datetime']);
    final formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    final formattedTime = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return Card(
      color: const Color(0xFF2d2d2d),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF3a3a3a),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.phone,
            color: Colors.green,
          ),
        ),
        title:  Text(
            callTime['contactName'] ?? 'Unknown Contact',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

        subtitle:
           Text(
            '$formattedDate - $formattedTime',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

        trailing: callTime['type'] == 'incoming'
            ? const Icon(Icons.call_received, color: Colors.green)
            : const Icon(Icons.call_made, color: Colors.orange),
      ),
    );
  }

  String _formatDateTime(String isoString) {
    final dateTime = DateTime.parse(isoString);
    final formatter = DateFormat('MMM dd, yyyy - HH:mm');
    return formatter.format(dateTime);
  }

  Future<void> _addSampleCallTime(String type) async {
    await CallTimesService.addCallTime(
      type: type,
      contactName: type == 'incoming'
          ? 'Contact ${_callTimes.length + 1}'
          : 'Outgoing Call ${_callTimes.length + 1}',
    );
    _loadCallTimes(); // Reload the list
  }

  Future<void> _confirmClearCallTimes() async {
    final result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('سڕینەوەی هەموو'),
        content: const Text('دڵنیای لە سڕینەوەی هەموو کاتی گوتنەکان؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('نەخێر'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('بەڵێ'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      await CallTimesService.clearCallTimes();
      _loadCallTimes(); // Reload the list
    }
  }
}
