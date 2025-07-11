import 'package:cloud_firestore/cloud_firestore.dart';
class Message {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  final Timestamp timestamp;
  final bool? encrypted;
  final String? type;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.timestamp,
    this.encrypted,
    this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp,
      'encrypted': encrypted ?? false,
      'type': type ?? 'text',
      "senderProfilePic": "https://scontent.fmnl13-4.fna.fbcdn.net/v/t39.30808-6/461936413_1091563265667901_6592324197866706840_n.jpg?_nc_cat=1&ccb=1-7&_nc_sid=6ee11a&_nc_eui2=AeH-6vumtNLakD82NajdszEEHcILYkVSvFYdwgtiRVK8VtP5Mmdmp7IjOTH686ASfrYSAMjDQBjagxakV6-MHs6D&_nc_ohc=Fgko8ClHU7EQ7kNvwHzX2SM&_nc_oc=AdnFl-8MCMqegsfGYQz1hUgGyifD0BTWTdgA1bUC3nriwILWqHzjhgdYOHjYTdbW-C0&_nc_zt=23&_nc_ht=scontent.fmnl13-4.fna&_nc_gid=O4AqV4tJc7uEa-kNEAOsfw&oh=00_AfG4tWWdJ_DoNSuYk8h201NTPjhA1Pc9FgBemSIlkYBEBg&oe=6806DF65"

    };
  }

    factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderID: map['senderID'] ?? '',
      senderEmail: map['senderEmail'] ?? '',
      receiverID: map['receiverID'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
      encrypted: map['encrypted'] ?? false,
      type: map['type'] ?? 'text',
    );
  }
}
