import 'dart:async';

import 'package:flutter/material.dart';

import 'api/countdown.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  bool _useStream = true;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Countdown')),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('A: StreamBuilder')),
              ButtonSegment(value: false, label: Text('B: listen')),
            ],
            selected: {_useStream},
            onSelectionChanged: (s) => setState(() => _useStream = s.first),
          ),
        ),
        Expanded(
          child: Center(
            child: _useStream
                ? const StreamCountdown()
                : const ListenCountdown(),
          ),
        ),
      ],
    ),
  );
}

class StreamCountdown extends StatefulWidget {
  const StreamCountdown({super.key});

  @override
  State<StreamCountdown> createState() => _StreamCountdownState();
}

class _StreamCountdownState extends State<StreamCountdown> {
  late final Stream<int> _stream = countdown(10);

  @override
  Widget build(BuildContext context) => StreamBuilder<int>(
    stream: _stream,
    builder: (context, snapshot) => Text(
      '${snapshot.data ?? 10}',
      style: Theme.of(context).textTheme.displayLarge,
    ),
  );
}

class ListenCountdown extends StatefulWidget {
  const ListenCountdown({super.key});

  @override
  State<ListenCountdown> createState() => _ListenCountdownState();
}

class _ListenCountdownState extends State<ListenCountdown> {
  int _left = 10;
  late StreamSubscription<int> _sub;

  @override
  void initState() {
    super.initState();
    _sub = countdown(10).listen((i) => setState(() => _left = i));
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Text('$_left', style: Theme.of(context).textTheme.displayLarge);
}
