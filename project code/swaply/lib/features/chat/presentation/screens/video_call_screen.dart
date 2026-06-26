import 'package:flutter/material.dart';

class VideoCallScreen extends StatelessWidget {
  const VideoCallScreen({super.key, required this.callerName});

  final String callerName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF11141B),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 24),
            Column(
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Color(0xFF2C2F38),
                  child: Icon(Icons.videocam, size: 56, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text(
                  callerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Video call connected',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              child: Column(
                children: [
                  const Text(
                    'Your camera and audio are live. End the call anytime.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 42),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CallActionButton(
                        icon: Icons.videocam_off,
                        label: 'Video Off',
                        onTap: () {},
                      ),
                      _CallActionButton(
                        icon: Icons.call_end,
                        label: 'End',
                        bgColor: const Color(0xFFED5B5B),
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      _CallActionButton(
                        icon: Icons.volume_up,
                        label: 'Speaker',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallActionButton extends StatelessWidget {
  const _CallActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.bgColor = Colors.white24,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
