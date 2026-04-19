import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  static final _messages = <_Msg>[
    _Msg('Hi Jane, your glucose looks great this week 👏', false, '10:24 AM'),
    _Msg('Thanks Dr. Morgan! The new diet really helps.', true, '10:26 AM'),
    _Msg('Glad to hear. Keep logging daily readings.', false, '10:27 AM'),
    _Msg('Will do. See you at the appointment.', true, '10:28 AM'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
              ),
              title: const Text('Dr. Alex Morgan',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Psychology Specialist',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              trailing: Container(
                width: 10, height: 10,
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _Bubble(msg: _messages[i]),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message…',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppTheme.primaryBlue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool mine;
  final String time;
  _Msg(this.text, this.mine, this.time);
}

class _Bubble extends StatelessWidget {
  final _Msg msg;
  const _Bubble({required this.msg});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: msg.mine ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.mine ? 16 : 4),
            bottomRight: Radius.circular(msg.mine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(msg.text,
                style: TextStyle(color: msg.mine ? Colors.white : AppTheme.textDark)),
            const SizedBox(height: 4),
            Text(msg.time,
                style: TextStyle(
                  fontSize: 10,
                  color: msg.mine ? Colors.white70 : AppTheme.textMuted,
                )),
          ],
        ),
      ),
    );
  }
}
