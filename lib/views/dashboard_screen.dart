import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/employee_viewmodel.dart';
import '../viewmodels/recognition_viewmodel.dart';
import '../models/recognition.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<EmployeeViewModel>().loadEmployees();
        context.read<RecognitionViewModel>().loadFeed();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final employeeVm = context.watch<EmployeeViewModel>();
    final recognitionVm = context.watch<RecognitionViewModel>();
    final authVm = context.watch<AuthViewModel>();

    final firstName = authVm.currentUser != null
        ? authVm.currentUser!.name.split(' ').first
        : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await authVm.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              firstName.isEmpty
                  ? 'Bem-vindo ao RH App!'
                  : 'Bem-vindo, $firstName!',
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              authVm.isAdmin
                  ? 'Gerencie sua equipe com facilidade.'
                  : 'Reconheça seus colegas e acompanhe seus feedbacks.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.people,
                    label: 'Funcionários',
                    value: employeeVm.totalEmployees.toString(),
                    color: const Color(0xFF1E88E5),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.apartment,
                    label: 'Departamentos',
                    value: employeeVm.employeesByDepartment.length
                        .toString(),
                    color: const Color(0xFF43A047),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Ações rápidas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (authVm.isAdmin) ...[
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.person_add,
                      label: 'Novo Funcionário',
                      onTap: () =>
                          Navigator.pushNamed(context, '/employee-form'),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: _ActionCard(
                    icon: Icons.list_alt,
                    label: 'Funcionários',
                    onTap: () =>
                        Navigator.pushNamed(context, '/employees'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.apartment,
                    label: 'Departamentos',
                    onTap: () =>
                        Navigator.pushNamed(context, '/departments'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reconhecimentos recentes',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () =>
                      context.read<RecognitionViewModel>().loadFeed(),
                  child: const Text('Atualizar'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            recognitionVm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : recognitionVm.feed.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Nenhum reconhecimento ainda.\nReconheça um colega pelo perfil dele!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recognitionVm.feed.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return _RecognitionCard(
                              recognition: recognitionVm.feed[index]);
                        },
                      ),
          ],
        ),
      ),
    );
  }
}

class _RecognitionCard extends StatelessWidget {
  final Recognition recognition;
  const _RecognitionCard({required this.recognition});

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
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          color: Colors.black, fontSize: 14),
                      children: [
                        TextSpan(
                          text: recognition.senderName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' reconheceu '),
                        TextSpan(
                          text: recognition.receiverName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E88E5)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                recognition.category,
                style: const TextStyle(
                    color: Color(0xFF1E88E5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '"${recognition.message}"',
              style: TextStyle(
                  fontStyle: FontStyle.italic, color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Text(
              recognition.date,
              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.bold, color: color),
            ),
            Text(label,
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF1E88E5), size: 32),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
