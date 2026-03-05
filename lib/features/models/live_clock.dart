import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class LiveClock extends StatefulWidget {
  final TextStyle? style;

  const LiveClock({super.key, this.style});

  @override
  State<LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  String _timeString = "";
  Timer? _timer;

  @override
  void initState() {
    super.initState(); // initialize the state
    _timeString = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => _getCurrentTime(),
    );
  }

  @override
  void dispose() { // dispose the timer
    _timer?.cancel();
    super.dispose();
  }

  void _getCurrentTime() {
    final DateTime now = DateTime.now();
    final String formattedTime = _formatDateTime(now);
    setState(() {
      _timeString = formattedTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('h:mm:ss a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _timeString,
      style:
          widget.style ??
          const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
    );
  }
}
