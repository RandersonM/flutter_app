import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/features/vegapunk_chat/tools/function_executor.dart';

/// The on-device Gemma model sometimes emits its tool call as plain-text JSON
/// (chat-completion style) that the SDK's native parser misses — this is the
/// bug where the raw JSON leaked into Nami's chat bubble. The text-fallback
/// parser must still recover the call so NamiChatBloc can run the right tool.
void main() {
  final executor = FunctionExecutor();

  test('parses the leaked chat-completion tool_calls wrapper', () {
    const leaked =
        'Para calcular a parcela, usarei a ferramenta affordableInstallment.\n'
        '{"role":"assistant","tool_calls":[{"type":"function","function":'
        '{"name":"affordableInstallment","arguments":{"price":"80000"}}}]}';

    final call = executor.tryParse(leaked);

    expect(call, isNotNull);
    expect(call!.name, 'affordableInstallment');
    expect(call.arguments['price'], '80000');
  });

  test('parses a plain {"name","arguments"} tool call', () {
    final call = executor.tryParse(
      '{"name":"getFinances","arguments":{"month":"2026-07"}}',
    );
    expect(call?.name, 'getFinances');
    expect(call?.arguments['month'], '2026-07');
  });

  test('returns null for prose with no tool call', () {
    expect(executor.tryParse('Sua renda média é de R\$ 10.000,00.'), isNull);
  });
}
