import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/employee_viewmodel.dart';
import '../viewmodels/recognition_viewmodel.dart';

class EmployeeProfileScreen extends StatelessWidget {
  const EmployeeProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final employee = ModalRoute.of(context)!.settings.arguments as Employee;
    final authVm = context.watch<AuthViewModel>();
    final isAdmin = authVm.isAdmin;
    final isOwnProfile = authVm.currentUser?.id == employee.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        actions: [
          if (isAdmin) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar',
              onPressed: () async {
                await Navigator.pushNamed(
                  context,
                  '/employee-form',
                  arguments: employee,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Excluir',
              onPressed: () => _confirmDelete(context, employee),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: const Color(0xFF1E88E5),
              child: Text(
                employee.name[0].toUpperCase(),
                style: const TextStyle(
                    fontSize: 48,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              employee.name,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              employee.role,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            if (isOwnProfile) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Este é o seu perfil',
                  style: TextStyle(
                      color: Color(0xFF43A047),
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
            const SizedBox(height: 24),
            _InfoCard(
              items: [
                _InfoItem(
                    icon: Icons.apartment,
                    label: 'Departamento',
                    value: employee.department),
                _InfoItem(
                    icon: Icons.email,
                    label: 'E-mail',
                    value: employee.email),
              ],
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ações',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.feedback,
                    label: 'Feedbacks',
                    color: const Color(0xFF1E88E5),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/feedbacks',
                      arguments: employee,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.emoji_events,
                    label: 'Reconhecimentos',
                    color: const Color(0xFFFB8C00),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/recognitions',
                      arguments: employee,
                    ),
                  ),
                ),
                if (!isOwnProfile) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.volunteer_activism,
                      label: 'Reconhecer',
                      color: const Color(0xFF43A047),
                      onTap: () =>
                          _showRecognitionDialog(context, employee),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRecognitionDialog(BuildContext context, Employee employee) {
    final currentUser = context.read<AuthViewModel>().currentUser;
    if (currentUser == null) return;

    final messageController = TextEditingController();
    String selectedCategory = recognitionCategories.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Reconhecer ${employee.name.split(' ').first}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Categoria',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: recognitionCategories.map((cat) {
                    final selected = selectedCategory == cat;
                    final emoji = categoryEmojis[cat] ?? '';
                    return ChoiceChip(
                      label: Text('$emoji $cat'),
                      selected: selected,
                      onSelected: (_) =>
                          setDialogState(() => selectedCategory = cat),
                      selectedColor: const Color(0xFF43A047),
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Mensagem',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Descreva por que está reconhecendo...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF43A047)),
              onPressed: () async {
                if (messageController.text.trim().isEmpty) return;
                await context.read<RecognitionViewModel>().sendRecognition(
                      senderId: currentUser.id,
                      senderName: currentUser.name,
                      receiverId: employee.id,
                      receiverName: employee.name,
                      category: selectedCategory,
                      message: messageController.text.trim(),
                    );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Reconhecimento enviado para ${employee.name.split(' ').first}!'),
                      backgroundColor: const Color(0xFF43A047),
                    ),
                  );
                }
              },
              child: const Text('Enviar',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir funcionário'),
        content: Text(
            'Deseja excluir ${employee.name}? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context
                  .read<EmployeeViewModel>()
                  .deleteEmployee(employee.id);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('Excluir',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          border: Border.all(color: color.withAlpha(80)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<_InfoItem> items;
  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: items
              .map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(item.icon, color: const Color(0xFF1E88E5)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.label,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600])),
                            Text(item.value,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  _InfoItem(
      {required this.icon, required this.label, required this.value});
}
