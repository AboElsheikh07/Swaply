import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Online extends StatefulWidget {
  final Widget child;
  const Online({super.key, required this.child});

  @override
  State<Online> createState() => _OnlineState();
}

class _OnlineState extends State<Online> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    setStatus(false);
    super.dispose();
  }

  Future<void> setStatus(bool status) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return; // not signed in yet, nothing to update

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'online': status});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setStatus(true);
    } else {
      setStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}