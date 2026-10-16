import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/connectivity/connectivity_cubit.dart';
import 'package:opfan/core/connectivity/connectivity_state.dart';
import 'package:opfan/core/services/connectivity/i_connectivity_service.dart';

class _MockConnectivityService extends Mock implements IConnectivityService {}

void main() {
  late _MockConnectivityService service;
  late StreamController<bool> changes;

  const debounce = Duration(milliseconds: 1600);

  setUp(() {
    service = _MockConnectivityService();
    changes = StreamController<bool>.broadcast();
    when(() => service.onStatusChanged).thenAnswer((_) => changes.stream);
    when(() => service.isOnline()).thenAnswer((_) async => true);
  });

  tearDown(() => changes.close());

  ConnectivityCubit build() => ConnectivityCubit(connectivityService: service);

  group('ConnectivityCubit behaviour', () {
    blocTest<ConnectivityCubit, ConnectivityState>(
      'goes offline at once when the app starts without network',
      setUp: () =>
          when(() => service.isOnline()).thenAnswer((_) async => false),
      build: build,
      expect: () => [const ConnectivityOffline()],
    );

    blocTest<ConnectivityCubit, ConnectivityState>(
      'reports a change only after the debounce',
      build: build,
      act: (_) => changes.add(false),
      wait: debounce,
      expect: () => [const ConnectivityOffline()],
    );

    blocTest<ConnectivityCubit, ConnectivityState>(
      'keeps only the last of several quick changes',
      build: build,
      act: (_) => changes
        ..add(false)
        ..add(true)
        ..add(false),
      wait: debounce,
      expect: () => [const ConnectivityOffline()],
    );
  });
}
