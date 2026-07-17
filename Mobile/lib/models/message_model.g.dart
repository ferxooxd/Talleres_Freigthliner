// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
  id: (json['id'] as num).toInt(),
  senderId: (json['sender_id'] as num).toInt(),
  receiverId: (json['receiver_id'] as num).toInt(),
  content: json['content'] as String,
  timestamp: json['timestamp'] as String?,
  isRead: json['is_read'] as bool?,
  deliveredAt: json['delivered_at'] as String?,
  readAt: json['read_at'] as String?,
  apiStatus: json['status'] as String?,
);

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender_id': instance.senderId,
      'receiver_id': instance.receiverId,
      'content': instance.content,
      'timestamp': instance.timestamp,
      'is_read': instance.isRead,
      'delivered_at': instance.deliveredAt,
      'read_at': instance.readAt,
      'status': instance.apiStatus,
    };
