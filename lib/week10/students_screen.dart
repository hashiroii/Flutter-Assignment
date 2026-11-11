import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Student>? _students;
  Object? _error;
  static final _api = FakeApi();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _students = null;
      _error = null;
    });
    try {
      final list = await _api.fetchStudents();
      if (!mounted) return;
      setState(() => _students = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Future<void> _save(BuildContext context, int n) async {
    setState(() => _saving = true);
    try {
      await _api.save(n);
      if (!context.mounted) return;
      Navigator.pop(context);
    } on StateError catch (e) {
      if (!context.mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final students = _students;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students (by hand)'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: students == null
          ? null
          : FloatingActionButton(
              onPressed: _saving ? null : () => _save(context, students.length),
              child: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
            ),
      body: switch ((_error, students)) {
        (Object(), _) => ErrorView(onRetry: _load),
        (_, null) => const LoadingView(),
        (_, []) => const EmptyView(),
        (_, final list?) => StudentList(list),
      },
    );
  }
}
