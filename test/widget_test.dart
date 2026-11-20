import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catalogo_do_dia/main.dart';

void main() {
  testWidgets('Mostra o catálogo e adiciona uma comida', (tester) async {
    await tester.pumpWidget(const CatalogoApp());

    expect(find.text('Catálogo do dia'), findsOneWidget);
    expect(find.text('Pão de queijo'), findsOneWidget);
    expect(find.text('R\$ 5,00'), findsWidgets);
    expect(find.text('10 opções no catálogo'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'Tapioca');
    await tester.enterText(find.byType(TextField).at(1), '7,50');
    await tester.tap(find.text('Adicionar ao catálogo'));
    await tester.pump();

    expect(find.text('11 opções no catálogo'), findsOneWidget);
  });
}
