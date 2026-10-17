import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:opfan/features/nami_finances/bloc/chat/nami_chat_bloc.dart';
import 'package:opfan/features/nami_finances/bloc/chat/nami_chat_state.dart';
import 'package:opfan/features/nami_finances/presentation/widgets/nami_chat_sheet.dart';
import 'package:opfan/features/vegapunk_chat/data/models/chat_message.dart';

import '../../testable_widget.dart';

class _MockNamiChatBloc extends MockCubit<NamiChatState>
    implements NamiChatBloc {}

void main() {
  final getIt = GetIt.instance;
  late _MockNamiChatBloc bloc;
  late StreamController<NamiChatState> states;

  setUp(() {
    bloc = _MockNamiChatBloc();
    states = StreamController<NamiChatState>();
    whenListen(bloc, states.stream, initialState: const NamiChatReady());
    getIt.registerFactory<NamiChatBloc>(() => bloc);
  });

  tearDown(() async {
    await states.close();
    await getIt.reset();
  });

  group('NamiChatSheet behaviour', () {
    testWidgets('does not scroll after the sheet is dismissed in the same '
        'frame a generating state arrived', (tester) async {
      await tester.pumpWidget(
        getTestableWidget(
          const MediaQuery(
            data: MediaQueryData(size: Size(400, 800)),
            child: Scaffold(body: NamiChatSheet()),
          ),
        ),
      );

      states.add(
        NamiChatReady(
          messages: [
            ChatMessage(
              id: 'q',
              text: 'quanto sobrou?',
              role: MessageRole.user,
              timestamp: DateTime(2026),
            ),
          ],
          isGenerating: true,
        ),
      );
      await tester.idle();
      await tester.pumpWidget(getTestableWidget(const SizedBox()));

      expect(tester.takeException(), isNull);
    });
  });
}
