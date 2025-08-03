import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:wheres_my_bus/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType { passenger, driver }

class AppState extends ChangeNotifier {
  AppState() {
    init();
  }

  UserType _userType = UserType.passenger; // Default to passenger
  UserType get userType => _userType;

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  void setUserType(UserType type) {
    _userType = type;
    notifyListeners();
  }

  Future<void> refreshUserType() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    print("Refreshing user type for UID: $uid");
    if (uid == null) return null;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    final type = data?['type'] as String?;
    setUserType(
      type == "driver" ? UserType.driver : UserType.passenger,
    ); // Default to passenger
    print("User type of $type set to $_userType");
  }

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseUIAuth.configureProviders([EmailAuthProvider()]);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        refreshUserType();
        print("Signed in as ${user.uid}");
      } else {
        _loggedIn = false;
      }
      notifyListeners();
    });
  }

  Future<void> addUser(User user, UserType type) async {
    final firestore = FirebaseFirestore.instance;

    // Save extra data
    await firestore.collection('users').doc(user.uid).set({
      'type': _userType.name,
      'createdAt': Timestamp.now(),
    });

    await firestore.collection('${type.name}s').doc(user.uid).set({
      'name': user.displayName ?? user.email?.split('@')[0] ?? 'Unknown',
    });
  }

  /// Deletes the user's entry in Firestore and, optionally,
  /// removes any subcollections they may have.
  Future<void> removeUser(User user) async {
    print("Removing user ${user.uid} from Firestore");
    try {
      final firestore = FirebaseFirestore.instance;
      final userDoc = await firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final userType = userDoc.data()!['type'] as String;
      final batch = firestore.batch();

      // Delete from users collection and driver/passenger collection
      batch.delete(firestore.collection('users').doc(user.uid));
      batch.delete(firestore.collection('${userType}s').doc(user.uid));
      await batch.commit();
      print('Deleted Firestore record for uid=${user.uid}');
    } catch (err, stackTrace) {
      print('Error deleting uid=${user.uid}: $err\n$stackTrace');
      rethrow; // or convert to custom error
    }
  }
}
