// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../data/models/session_model.dart';
// import '../../../../core/constants/app_colors.dart';

// /// Renders the correct CTA button(s) for a session card
// /// depending on role and current status.
// class SessionActionButtons extends StatelessWidget {
//   final SessionItem session;
//   final bool isIncoming;
//   final VoidCallback onAccept;
//   final VoidCallback onDecline;

//   const SessionActionButtons({
//     super.key,
//     required this.session,
//     required this.isIncoming,
//     required this.onAccept,
//     required this.onDecline,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (isIncoming) return _incomingActions(context);
//     return _studentActions(context);
//   }

//   // ── Teacher / Incoming ───────────────────────

//   Widget _incomingActions(BuildContext context) {
//     switch (session.status) {
//       case SessionStatus.pending:
//         return Row(children: [
//           _OutlinedBtn(label: 'Decline', icon: Icons.close,  onTap: onDecline),
//           const SizedBox(width: 8),
//           _FilledBtn(label: 'Accept',  icon: Icons.check,  onTap: onAccept),
//         ]);

//       case SessionStatus.accepted:
//       case SessionStatus.ongoing:
//         return _FilledBtn(
//           label: 'Start',
//           icon:  Icons.videocam_outlined,
//           onTap: () => Get.toNamed('/call/${session.id}'),
//         );

//       case SessionStatus.completed:
//         return _AmberBtn(
//           label: 'Rate Student',
//           icon:  Icons.star_border,
//           onTap: () => Get.toNamed('/rate/${session.id}?role=teacher'),
//         );

//       default:
//         return _GreyChip(label: session.status.label);
//     }
//   }

//   // ── Student / My Requests ────────────────────

//   Widget _studentActions(BuildContext context) {
//     switch (session.status) {
//       case SessionStatus.accepted:
//       case SessionStatus.ongoing:
//         return _FilledBtn(
//           label: 'Join Session',
//           icon:  Icons.videocam_outlined,
//           onTap: () => Get.toNamed('/call/${session.id}'),
//         );

//       case SessionStatus.pending:
//         return const _GreyChip(label: 'Waiting');

//       case SessionStatus.completed:
//         return _AmberBtn(
//           label: 'Rate Teacher',
//           icon:  Icons.star_border,
//           onTap: () => Get.toNamed('/rate/${session.id}?role=student'),
//         );

//       default:
//         return _GreyChip(label: session.status.label);
//     }
//   }
// }

// // ── Button atoms ─────────────────────────────────

// class _FilledBtn extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final VoidCallback onTap;

//   const _FilledBtn({required this.label, required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) => GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//           decoration: BoxDecoration(
//             color:        Theme.of(context).extension<AppColorTheme>()!.primary,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Row(mainAxisSize: MainAxisSize.min, children: [
//             Icon(icon, size: 13, color: Colors.white),
//             const SizedBox(width: 5),
//             Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
//           ]),
//         ),
//       );
// }

// class _OutlinedBtn extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final VoidCallback onTap;

//   const _OutlinedBtn({required this.label, required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) => GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           decoration: BoxDecoration(
//             color:        Theme.of(context).extension<AppColorTheme>()!.card,
//             borderRadius: BorderRadius.circular(20),
//             border:       Border.all(color: Theme.of(context).extension<AppColorTheme>()!.border),
//           ),
//           child: Row(mainAxisSize: MainAxisSize.min, children: [
//             Icon(icon, size: 13, color: Theme.of(context).extension<AppColorTheme>()!.text),
//             SizedBox(width: 5),
//             Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).extension<AppColorTheme>()!.text)),
//           ]),
//         ),
//       );
// }

// class _AmberBtn extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final VoidCallback onTap;

//   const _AmberBtn({required this.label, required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) => GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//           decoration: BoxDecoration(
//             color:        Theme.of(context).extension<AppColorTheme>()!.amberBg,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Row(mainAxisSize: MainAxisSize.min, children: [
//             Icon(icon, size: 13, color: Theme.of(context).extension<AppColorTheme>()!.amber),
//             SizedBox(width: 5),
//             Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).extension<AppColorTheme>()!.amber)),
//           ]),
//         ),
//       );
// }

// class _GreyChip extends StatelessWidget {
//   final String label;
//   const _GreyChip({required this.label});

//   @override
//   Widget build(BuildContext context) => Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//         decoration: BoxDecoration(
//           color:        Theme.of(context).extension<AppColorTheme>()!.background,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).extension<AppColorTheme>()!.muted)),
//       );
// }
