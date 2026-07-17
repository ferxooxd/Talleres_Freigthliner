import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/providers/chat_provider.dart';

Dio buildDio({List<String>? patchPaths}) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.method == 'GET' && options.path == '/chat/unread-counts') {
          return handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'total': 5,
                'counts': [
                  {'contact_id': 7, 'unread_count': 2},
                  {'contact_id': 9, 'unread_count': 3},
                ],
              },
            ),
          );
        }

        if (options.method == 'PATCH') {
          patchPaths?.add(options.path);
          return handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'updated_count': 1},
            ),
          );
        }

        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(requestOptions: options, statusCode: 404),
          ),
        );
      },
    ),
  );
  return dio;
}

void main() {
  test('loadUnreadCounts hydrates grouped backend counts', () async {
    final provider = ChatProvider(httpClient: buildDio());

    await provider.loadUnreadCounts();

    expect(provider.totalUnread, 5);
    expect(provider.unreadFor(7), 2);
    expect(provider.unreadFor(9), 3);
  });

  test('new websocket message increments only the closed chat badge', () {
    final provider = ChatProvider(httpClient: buildDio());

    provider.handleSocketData(
      jsonEncode({
        'id': 101,
        'sender_id': 7,
        'receiver_id': 1,
        'content': 'Nuevo mensaje',
        'timestamp': '2026-07-17T15:10:00Z',
        'is_read': false,
        'status': 'sent',
      }),
    );

    expect(provider.unreadFor(7), 1);
    expect(provider.unreadFor(9), 0);
    expect(provider.totalUnread, 1);
  });

  test(
    'opening a chat clears its badge and calls bulk read endpoint',
    () async {
      final patchPaths = <String>[];
      final provider = ChatProvider(
        httpClient: buildDio(patchPaths: patchPaths),
      );

      provider.handleSocketData(
        jsonEncode({
          'id': 101,
          'sender_id': 7,
          'receiver_id': 1,
          'content': 'Nuevo mensaje',
          'timestamp': '2026-07-17T15:10:00Z',
          'is_read': false,
          'status': 'sent',
        }),
      );

      await provider.setActiveContact(7);

      expect(provider.unreadFor(7), 0);
      expect(provider.totalUnread, 0);
      expect(patchPaths, ['/chat/conversations/7/read']);
    },
  );
}
