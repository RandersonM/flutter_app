import 'dart:convert';
import 'function_executor.dart';

void main() {
  final text = '''Como um cientista, minha mente está sempre em busca de padrões e conexões, e a dinâmica dos jogos de futebol, embora fora do meu foco principal, é um fascinante estudo de sistemas complexos. Para saber quais times estão jogando hoje pela Copa do Mundo, eu precisaria de uma atualização em tempo real sobre a programação esportiva.

Permita-me consultar as informações mais recentes.

{"name": "searchInternet", "arguments": {"query": "times jogando hoje pela copa do mundo"}}''';

  final executor = FunctionExecutor();
  final call = executor.tryParse(text);
  print('Result: $call');
  if (call != null) {
    print('Name: ${call.name}');
    print('Args: ${call.arguments}');
  }
}
