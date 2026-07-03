import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/employee_viewmodel.dart';
import '../models/employee.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<EmployeeViewModel>().loadEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmployeeViewModel>();
    final departments = vm.employeesByDepartment;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Departamentos'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : departments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.apartment,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum departamento encontrado.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cadastre funcionários para ver os departamentos.',
                        style: TextStyle(
                            color: Colors.grey[400], fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: departments.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final department = departments.keys.elementAt(index);
                    final employees = departments[department]!;
                    return _DepartmentCard(
                      department: department,
                      employees: employees,
                    );
                  },
                ),
    );
  }
}

class _DepartmentCard extends StatefulWidget {
  final String department;
  final List<Employee> employees;

  const _DepartmentCard({
    required this.department,
    required this.employees,
  });

  @override
  State<_DepartmentCard> createState() => _DepartmentCardState();
}

class _DepartmentCardState extends State<_DepartmentCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5).withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.apartment,
                        color: Color(0xFF1E88E5), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.department,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${widget.employees.length} funcionário${widget.employees.length != 1 ? 's' : ''}',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[500],
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            ...widget.employees.map(
              (employee) => ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF1E88E5),
                  radius: 18,
                  child: Text(
                    employee.name[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ),
                title: Text(employee.name,
                    style:
                        const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(employee.role,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[600])),
                trailing:
                    const Icon(Icons.chevron_right, size: 20),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/employee-profile',
                  arguments: employee,
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}
