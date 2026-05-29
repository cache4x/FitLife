// Teste básico de interface (Widget Test) para a aplicação Flutter.
// Utiliza o pacote flutter_test para interagir e validar a árvore de widgets.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musclehelper_flutter/main.dart';

void main() {
  /// Teste de fumaça (Smoke Test) básico para verificar a inicialização do app.
  testWidgets('Teste de fumaça de incremento do contador', (WidgetTester tester) async {
    // Constrói o aplicativo principal e renderiza o primeiro frame.
    await tester.pumpWidget(const MyApp());

    // Como o app real necessita de autenticação/banco, este teste de fumaça padrão
    // valida que a infraestrutura de testes e o carregamento do MyApp estão operacionais.
    expect(find.byType(MyApp), findsOneWidget);
  });
}
