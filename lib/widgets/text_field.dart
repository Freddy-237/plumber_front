import 'package:flutter/material.dart';

/// Réutilisable: champ de texte stylé pour l'application
class AppTextField extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  const AppTextField({
    super.key,
    required this.label,
    this.icon,
    this.obscure = false,
    this.controller,
    this.keyboardType,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: _isObscured,
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: widget.icon != null
              ? Icon(widget.icon, color: Colors.blueAccent.shade700)
              : null,
          suffixIcon: widget.obscure
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    color: Colors.blueAccent.shade700,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        ),
      ),
    );
  }
}
