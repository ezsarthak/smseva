import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../Model/Worker.dart';
import '../Services/api_service.dart';
import '../Widgets/Auth_FormCard.dart';
import '../Widgets/Auth_Header.dart';
import '../Widgets/primary button.dart';
import '../constants/AppColors.dart';



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
  List<Map<String, dynamic>> _departments = [];
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _loadDepartments() async {
    try {
      final departments = await ApiService.getDepartments();
      setState(() {
        _departments = departments.map((dept) {
          // Assuming your Department model has 'id' and 'name' properties.
          // The keys '_id' and 'name' must match what the DropdownButtonFormField expects.
          return {'_id': dept.id, 'name': dept.name};
        }).toList();
      });
    }catch (e) {
      // Handle error, maybe show a snackbar
      setState(() {
        _departments = [
          {'_id': '1', 'name': 'Electricity Department'},
          {'_id': '2', 'name': 'Water Supply Department'},
          {'_id': '3', 'name': 'Road Maintenance Department'},
          {'_id': '4', 'name': 'Sanitation Department'},
        ];
      });
      print('Failed to load departments: $e');
    }
  }

  Future<void> _signUp() async {
    if (_selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a department.'),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    // ✅ Generate a unique employee ID here
    var uuid = Uuid();
    String employeeId = 'EMP-${DateTime.now().millisecondsSinceEpoch}-${uuid.v4().substring(0, 8)}';

    final workerData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'password': _passwordController.text.trim(),
      'department_id': _selectedDepartment, // Ensure this is not null
      'skills': [_specializationController.text.trim()],
      'employee_id': employeeId, // ✅ Add the generated ID to the map
    };
    print('--- VERIFYING DATA BEFORE SENDING ---');
    print(workerData);
    print('------------------------------------');

    try {
      final success = await ApiService.registerWorker(workerData);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please wait for admin approval.'),
            backgroundColor: Color(0xFF059669), // kWorkerPrimaryColor
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        // This handles the case where the API returns a failure (e.g., 400 status)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Registration failed. Please check the details and try again.'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // This handles network errors or specific errors thrown from the API service
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Worker Registration', style: TextStyle(color: kTextColor)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kHintTextColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(
                    icon: Icons.person_add_alt_1_outlined,
                    title: 'Join Our Team',
                    subtitle: 'Fill in your details to register as a worker.',
                  ),
                  const SizedBox(height: 32),
                  AuthFormCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTextField(_nameController, 'Full Name', Icons.person_outline),
                          const SizedBox(height: 20),
                          _buildTextField(_emailController, 'Email Address', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 20),
                          _buildTextField(_phoneController, 'Phone Number', Icons.phone_outlined, keyboardType: TextInputType.phone),
                          const SizedBox(height: 20),
                          _buildPasswordField(),
                          const SizedBox(height: 20),
                          _buildDepartmentDropdown(),
                          const SizedBox(height: 20),
                          _buildTextField(_specializationController, 'Specialization (e.g., Plumbing)', Icons.work_outline),
                          const SizedBox(height: 20),
                          _buildTextField(_experienceController, 'Years of Experience', Icons.timeline_outlined, keyboardType: TextInputType.number),
                          const SizedBox(height: 30),
                          PrimaryButton(
                            text: 'Register',
                            isLoading: _loading,
                            onPressed: _signUp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label, icon),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your $label.';
        }
        if (label == 'Email Address' && !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
          return 'Please enter a valid email address.';
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
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
      initialValue: _selectedDepartment,
      decoration: _inputDecoration('Department', Icons.business_outlined),
      items: _departments.map((dept) {
        return DropdownMenuItem<String>(
          value: dept['_id'],
          child: Text(dept['name']),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedDepartment = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a department.';
        }
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: kHintTextColor),
      prefixIcon: Icon(icon, color: kHintTextColor),
      filled: true,
      fillColor: kBackgroundColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
    );
  }
}