enum MessageStatus {
  sent('sent'),
  delivered('delivered'),
  read('read');

  const MessageStatus(this.apiValue);

  final String apiValue;

  static MessageStatus? tryParse(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      default:
        return null;
    }
  }

  String get semanticsLabel {
    switch (this) {
      case MessageStatus.sent:
        return 'Mensaje enviado';
      case MessageStatus.delivered:
        return 'Mensaje entregado';
      case MessageStatus.read:
        return 'Mensaje leido';
    }
  }
}
