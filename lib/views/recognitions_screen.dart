import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../models/recognition.dart';
import '../viewmodels/recognition_viewmodel.dart';

class RecognitionsScreen extends StatefulWidget {
  const RecognitionsScreen({super.key});

  @override
  State<RecognitionsScreen> createState() => _RecognitionsScreenState();
}

class _RecognitionsScreenState extends State<RecognitionsScreen> {
  late Employee _employee;
  bool _initialized = false;
  // Evita exibir por 1 frame a lista do funcionário visitado antes,
  // já que o ViewModel é compartilhado pelo app inteiro
  bool _loadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _employee = ModalRoute.of(context)!.settings.arguments as Employee;
      _initialized = true;
      Future.microtask(() {
        if (mounted) {
          _loadStarted = true;
          context.read<RecognitionViewModel>().loadReceived(_employee.id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecognitionViewModel>();

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Reconhecimentos — ${_employee.name.split(' ').first}'),
        backgroundColor: const Color(0xFF43A047),
        foregroundColor: Colors.white,
      ),
      body: !_loadStarted || vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.received.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum reconhecimento ainda.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Reconhecimentos enviados pelos colegas\naparecem aqui e no feed do Dashboard.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey[400], fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.received.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return _ReceivedRecognitionCard(
                        recognition: vm.received[index]);
                  },
                ),
    );
  }
}

class _ReceivedRecognitionCard extends StatelessWidget {
  final Recognition recognition;
  const _ReceivedRecognitionCard({required this.recognition});

  @override
  Widget build(BuildContext context) {
    final emoji = categoryEmojis[recognition.category] ?? '⭐';
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recognition.senderName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        recognition.date,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF43A047).withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    recognition.category,
                    style: const TextStyle(
                        color: Color(0xFF43A047),
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '"${recognition.message}"',
              style: TextStyle(
                  fontStyle: FontStyle.italic, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
