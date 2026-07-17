import 'package:json_annotation/json_annotation.dart';
import 'message_status.dart';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel {
  final int id;
  @JsonKey(name: 'sender_id')
  final int senderId;
  @JsonKey(name: 'receiver_id')
  final int receiverId;
  final String content;
  final String? timestamp;
  @JsonKey(name: 'is_read')
  final bool? isRead;
  @JsonKey(name: 'delivered_at')
  final String? deliveredAt;
  @JsonKey(name: 'read_at')
  final String? readAt;
  @JsonKey(name: 'status')
  final String? apiStatus;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.timestamp,
    this.isRead,
    this.deliveredAt,
    this.readAt,
    this.apiStatus,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);
  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  MessageStatus get status {
    final parsedStatus = MessageStatus.tryParse(apiStatus);
    if (parsedStatus != null) return parsedStatus;
    if (readAt != null || isRead == true) return MessageStatus.read;
    if (deliveredAt != null) return MessageStatus.delivered;
    return MessageStatus.sent;
  }

  MessageModel copyWith({
    int? id,
    int? senderId,
    int? receiverId,
    String? content,
    String? timestamp,
    bool? isRead,
    String? deliveredAt,
    String? readAt,
    String? apiStatus,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      apiStatus: apiStatus ?? this.apiStatus,
    );
  }
}
