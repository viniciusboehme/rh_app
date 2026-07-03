import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../models/feedback_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/feedback_viewmodel.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  late Employee _employee;
  bool _initialized = false;
  // Evita exibir por 1 frame a lista do funcionário visitado antes,
  // já que o ViewModel é compartilhado pelo app inteiro
  bool _loadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _employee =
          ModalRoute.of(context)!.settings.arguments as Employee;
      _initialized = true;
      Future.microtask(() {
        if (mounted) {
          _loadStarted = true;
          context.read<FeedbackViewModel>().loadFeedbacks(_employee.id);
        }
      });
    }
  }

  void _showAddFeedbackDialog() {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Mensagem',
                hintText: 'Escreva seu feedback...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.visibility_off,
                    size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'O feedback é 100% anônimo: ninguém saberá quem escreveu.',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5)),
            onPressed: () async {
              if (messageController.text.trim().isEmpty) return;
              await context.read<FeedbackViewModel>().addFeedback(
                    employeeId: _employee.id,
                    message: messageController.text.trim(),
                  );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Enviar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteFeedback(FeedbackModel feedback) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir feedback'),
        content: const Text(
            'Deseja excluir este feedback? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context
                  .read<FeedbackViewModel>()
                  .deleteFeedback(feedback.id, _employee.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Excluir',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FeedbackViewModel>();
    final authVm = context.watch<AuthViewModel>();

    // Regras de privacidade:
    // - O dono do perfil e o RH (admin) podem LER as mensagens e o total.
    // - Os demais funcionários não veem NADA (nem a contagem):
    //   podem apenas ESCREVER um feedback anônimo.
    final isOwner = authVm.currentUser?.id == _employee.id;
    final canRead = isOwner || authVm.isAdmin;
    final canWrite = authVm.isLoggedIn && !isOwner;
    // Somente o RH pode excluir feedbacks (registro histórico do funcionário)
    final canDelete = authVm.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text('Feedbacks — ${_employee.name.split(' ').first}'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: canWrite
          ? FloatingActionButton(
              onPressed: _showAddFeedbackDialog,
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
      body: !canRead
          ? _SendFeedbackInvite(employeeName: _employee.name)
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5).withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFF1E88E5).withAlpha(76)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.feedback,
                            color: Color(0xFF1E88E5)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${vm.totalCount}',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E88E5)),
                            ),
                            Text(
                              'Feedbacks recebidos',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(Icons.visibility_off,
                            size: 16, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          'Anônimos',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: !_loadStarted || vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : vm.feedbacks.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.feedback_outlined,
                                      size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Nenhum feedback ainda.',
                                    style: TextStyle(
                                        color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              itemCount: vm.feedbacks.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final feedback = vm.feedbacks[index];
                                return _FeedbackCard(
                                  feedback: feedback,
                                  canDelete: canDelete,
                                  onDelete: () =>
                                      _confirmDeleteFeedback(feedback),
                                );
                              },
                            ),
                ),
              ],
            ),
    );
  }
}

class _SendFeedbackInvite extends StatelessWidget {
  final String employeeName;
  const _SendFeedbackInvite({required this.employeeName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Feedbacks privados e anônimos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Use o botão + para enviar um feedback anônimo para ${employeeName.split(' ').first}.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final FeedbackModel feedback;
  final bool canDelete;
  final VoidCallback onDelete;

  const _FeedbackCard({
    required this.feedback,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(Icons.chat_bubble_outline,
              color: Colors.grey[600], size: 20),
        ),
        title: Text(feedback.message),
        subtitle: Text(
          'Anônimo · ${feedback.date}',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        trailing: canDelete
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
              )
            : null,
      ),
    );
  }
}
