import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'Login.dart';
import 'WorkerLogin.dart' hide kTextColor, kHintTextColor, kBackgroundColor;

class WorkerSignupScreen extends StatefulWidget {
  const WorkerSignupScreen({super.key});

  @override
  State<WorkerSignupScreen> createState() => _WorkerSignupScreenState();
}

class _WorkerSignupScreenState extends State<WorkerSignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedDepartment;
  bool _loading = false;
  bool _obscurePassword = true;

  final _departments = const [
    {'_id': '1', 'name': 'Electricity Department'},
    {'_id': '2', 'name': 'Water Supply Department'},
    {'_id': '3', 'name': 'Road Maintenance Department'},
    {'_id': '4', 'name': 'Sanitation Department'},
  ];

  void _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registered successfully (UI only demo)')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Worker Registration'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kHintTextColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildForm(),
              ],
            ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(Icons.person_add_outlined, size: 64, color: kWorkerPrimaryColor),
        const SizedBox(height: 16),
        Text(
          'Join Our Team',
          style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.bold, color: kTextColor),
        ),
        const SizedBox(height: 8),
        Text(
          'Fill in your details to register as a worker.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: kHintTextColor),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField(_nameController, 'Full Name', Icons.person_outline),
            const SizedBox(height: 20),
            _buildTextField(_emailController, 'Email Address', Icons.email_outlined,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 20),
            _buildTextField(_phoneController, 'Phone Number', Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            _buildPasswordField(),
            const SizedBox(height: 20),
            _buildDepartmentDropdown(),
            const SizedBox(height: 20),
            _buildTextField(_specializationController, 'Specialization', Icons.work_outline),
            const SizedBox(height: 20),
            _buildTextField(_experienceController, 'Years of Experience',
                Icons.timeline_outlined,
                keyboardType: TextInputType.number),
            const SizedBox(height: 30),
            _buildSignUpButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label, icon),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Please enter $label.';
        if (label == 'Email Address' && !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
          return 'Enter a valid email address.';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: _inputDecoration('Password', Icons.lock_outline).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: kHintTextColor,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (value) {
        if (value == null || value.length < 6) {
          return 'Password must be at least 6 characters.';
        }
        return null;
      },
    );
  }

  Widget _buildDepartmentDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDepartment,
      decoration: _inputDecoration('Department', Icons.business_outlined),
      items: _departments
          .map((dept) => DropdownMenuItem(
        value: dept['_id'],
        child: Text(dept['name']!),
      ))
          .toList(),
      onChanged: (value) => setState(() => _selectedDepartment = value),
      validator: (value) => value == null ? 'Select a department.' : null,
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: 500,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: kWorkerPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _loading ? null : _signUp,
        child: _loading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          'Register',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: kHintTextColor),
      prefixIcon: Icon(icon, color: kHintTextColor),
      filled: true,
      fillColor: kBackgroundColor,
      contentPadding:
      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kWorkerPrimaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
    );
  }
}
