import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../viewmodels/employee_viewmodel.dart';

class EmployeeFormScreen extends StatefulWidget {
  const EmployeeFormScreen({super.key});

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _departmentController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSaving = false;

  Employee? _editingEmployee;
  bool _isEditing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Employee && !_isEditing) {
      _editingEmployee = args;
      _isEditing = true;
      _nameController.text = args.name;
      _roleController.text = args.role;
      _departmentController.text = args.department;
      _emailController.text = args.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _departmentController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final vm = context.read<EmployeeViewModel>();
    final password = _passwordController.text.trim();
    bool success;

    if (_editingEmployee != null) {
      _editingEmployee!.name = _nameController.text.trim();
      _editingEmployee!.role = _roleController.text.trim();
      _editingEmployee!.department = _departmentController.text.trim();
      _editingEmployee!.email = _emailController.text.trim();
      if (password.isNotEmpty) {
        _editingEmployee!.password = password;
      }
      success = await vm.updateEmployee(_editingEmployee!);
    } else {
      success = await vm.addEmployee(
        name: _nameController.text.trim(),
        role: _roleController.text.trim(),
        department: _departmentController.text.trim(),
        email: _emailController.text.trim(),
        password: password,
      );
    }

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Já existe um funcionário com este e-mail.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingEmployee != null
            ? 'Editar Funcionário'
            : 'Novo Funcionário'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(
                controller: _nameController,
                label: 'Nome completo',
                icon: Icons.person,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _roleController,
                label: 'Cargo',
                icon: Icons.work,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe o cargo' : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _departmentController,
                label: 'Departamento',
                icon: Icons.apartment,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Informe o departamento'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _emailController,
                label: 'E-mail (usado para login)',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Informe o e-mail';
                  }
                  if (!v.contains('@')) return 'E-mail inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: _isEditing
                      ? 'Nova senha (opcional)'
                      : 'Senha de acesso',
                  helperText: _isEditing
                      ? 'Deixe em branco para manter a senha atual'
                      : 'O funcionário usará o e-mail e esta senha para entrar',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (v) {
                  final text = v?.trim() ?? '';
                  if (!_isEditing && text.isEmpty) {
                    return 'Informe a senha de acesso';
                  }
                  if (text.isNotEmpty && text.length < 4) {
                    return 'A senha deve ter pelo menos 4 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _editingEmployee != null
                              ? 'Salvar Alterações'
                              : 'Cadastrar',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
    );
  }
}
