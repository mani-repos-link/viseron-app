import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dpad/dpad.dart';
import '../providers/app_state.dart';

class LoginScreenTV extends StatefulWidget {
  const LoginScreenTV({super.key});

  @override
  State<LoginScreenTV> createState() => _LoginScreenTVState();
}

class _LoginScreenTVState extends State<LoginScreenTV> {
  String _host = '';
  String _port = '';
  String _user = '';
  String _pass = '';

  void _connect() async {
    final host = _host.trim();
    final portStr = _port.trim();
    final port = portStr.isEmpty ? null : int.tryParse(portStr);
    final user = _user.trim();
    final pass = _pass.trim();

    if (host.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Host is required')),
      );
      return;
    }

    final success = await context.read<AppState>().connect(host, port, user, pass);
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<AppState>().error ?? 'Connection failed')),
        );
      }
    }
  }

  Future<void> _editField(String label, String currentValue, bool obscureText) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _EditDialog(
        label: label,
        initialValue: currentValue,
        obscureText: obscureText,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        if (label == 'Host IP / Domain') {
          _host = result;
        } else if (label == 'Port') {
          _port = result;
        } else if (label == 'Username') {
          _user = result;
        } else if (label == 'Password') {
          _pass = result;
        }
      });
    }
  }

  Widget _buildEditableField({
    required String label,
    required String value,
    required VoidCallback onEdit,
    bool obscureText = false,
    bool autofocus = false,
  }) {
    return DpadFocusable(
      autofocus: autofocus,
      onSelect: onEdit,
      builder: (context, isFocused, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
            border: isFocused
                ? Border.all(color: Colors.white, width: 3)
                : Border.all(color: Colors.grey[700]!, width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      obscureText && value.isNotEmpty ? '•' * value.length : value,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit,
                color: isFocused ? Colors.white : Colors.grey[600],
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AppState, bool>((s) => s.isLoading);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Connect to Viseron',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                _buildEditableField(
                  label: 'Host IP / Domain',
                  value: _host,
                  onEdit: () => _editField('Host IP / Domain', _host, false),
                  autofocus: true,
                ),
                const SizedBox(height: 16),

                _buildEditableField(
                  label: 'Username',
                  value: _user,
                  onEdit: () => _editField('Username', _user, false),
                ),
                const SizedBox(height: 16),

                _buildEditableField(
                  label: 'Password',
                  value: _pass,
                  onEdit: () => _editField('Password', _pass, true),
                  obscureText: true,
                ),
                const SizedBox(height: 32),

                if (isLoading)
                  const CircularProgressIndicator()
                else
                  DpadFocusable(
                    onSelect: _connect,
                    builder: (context, isFocused, child) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                          border: isFocused
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Connect',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 16),
                const Text(
                  'D-pad to navigate, OK to edit/connect',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditDialog extends StatefulWidget {
  final String label;
  final String initialValue;
  final bool obscureText;

  const _EditDialog({
    required this.label,
    required this.initialValue,
    required this.obscureText,
  });

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.label}'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        obscureText: widget.obscureText,
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (value) {
          Navigator.of(context).pop(value);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
