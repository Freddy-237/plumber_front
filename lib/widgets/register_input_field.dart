import 'package:flutter/material.dart';

class RegisterInputField extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  const RegisterInputField({
    super.key,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.controller,
    this.keyboardType,
  });

  @override
  State<RegisterInputField> createState() => _RegisterInputFieldState();
}

class _RegisterInputFieldState extends State<RegisterInputField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: _isObscured,
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: Icon(widget.icon, size: 20, color: Colors.blueAccent),
          suffixIcon: widget.obscure
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          isDense: true,
        ),
      ),
    );
  }
}

/// Widget pour choisir une photo de profil (placeholder UI)
class RegisterPhotoPicker extends StatelessWidget {
  final VoidCallback? onTap;

  const RegisterPhotoPicker({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.grey.shade200,
              child: Icon(Icons.person, size: 32, color: Colors.grey.shade700),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget pour ajouter une petite image (ex: photo CNI)
class RegisterImagePicker extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const RegisterImagePicker({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.blueAccent.shade100,
              ),
              child: const Icon(Icons.attach_file_rounded,
                  size: 18, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
