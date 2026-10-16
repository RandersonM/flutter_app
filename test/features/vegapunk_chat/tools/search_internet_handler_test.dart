import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/services/connectivity/i_connectivity_service.dart';
import 'package:opfan/core/services/web_search/i_web_search_service.dart';
import 'package:opfan/features/vegapunk_chat/tools/handlers/search_internet_handler.dart';
import 'package:opfan/features/vegapunk_chat/tools/models/tool_call.dart';

class _MockWebSearchService extends Mock implements IWebSearchService {}

class _MockConnectivityService extends Mock implements IConnectivityService {}

void main() {
  group('SearchInternetHandler behaviour', () {
    test(
      'returns an error result instead of searching while offline',
      () async {
        final webSearch = _MockWebSearchService();
        final connectivity = _MockConnectivityService();
        when(() => connectivity.isOnline()).thenAnswer((_) async => false);
        final handler = SearchInternetHandler(
          webSearch: webSearch,
          connectivityService: connectivity,
        );

        final result = await handler.execute(
          const ToolCall(
            name: 'searchInternet',
            arguments: {'query': 'One Piece chapter release'},
          ),
        );

        expect(result.isError, isTrue);
        verifyZeroInteractions(webSearch);
      },
    );
  });
}
