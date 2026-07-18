import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/notification_navigation_service.dart';

class FakeNotificationNavigator implements NotificationNavigator {
  final List<NotificationDestination> destinations = [];

  @override
  void go(String location, {Object? extra}) {
    destinations.add(NotificationDestination(location: location, extra: extra));
  }
}

void main() {
  test('new_message notification navigates to chat with contact id', () {
    final navigator = FakeNotificationNavigator();
    final service = NotificationNavigationService(navigator);

    final handled = service.handleData({
      'type': 'new_message',
      'chat_id': 'dm:1:7',
      'contact_id': '7',
      'message_id': '99',
    });

    expect(handled, isTrue);
    expect(navigator.destinations.single.location, '/chat');
    expect(navigator.destinations.single.extra, {
      'contactId': 7,
      'contactName': 'Chat',
      'chatId': 'dm:1:7',
      'messageId': '99',
    });
  });

  test('order_assigned notification navigates to mechanic order detail', () {
    final navigator = FakeNotificationNavigator();
    final service = NotificationNavigationService(navigator);

    final handled = service.handleData({
      'type': 'order_assigned',
      'order_id': '42',
    });

    expect(handled, isTrue);
    expect(navigator.destinations.single.location, '/mechanic/orders/42');
    expect(navigator.destinations.single.extra, {
      'orderId': 42,
      'type': 'order_assigned',
    });
  });

  test('order_ready notification navigates to client order detail', () {
    final navigator = FakeNotificationNavigator();
    final service = NotificationNavigationService(navigator);

    final handled = service.handleData({'type': 'order_ready', 'order_id': 84});

    expect(handled, isTrue);
    expect(navigator.destinations.single.location, '/client/orders/84');
    expect(navigator.destinations.single.extra, {
      'orderId': 84,
      'type': 'order_ready',
    });
  });

  test('unknown notification type uses controlled fallback', () {
    final navigator = FakeNotificationNavigator();
    final service = NotificationNavigationService(navigator);

    final handled = service.handleData({
      'type': 'future_type',
      'order_id': '1',
    });

    expect(handled, isFalse);
    expect(navigator.destinations, isEmpty);
  });
}
