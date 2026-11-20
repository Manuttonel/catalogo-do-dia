import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catalogo_do_dia/main.dart';

void main() {
  testWidgets('Mostra o catálogo, adiciona e remove uma comida',
      (tester) async {
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

    await tester.tap(find.byTooltip('Remover').first);
    await tester.pump();

    expect(find.text('Pão de queijo'), findsNothing);
    expect(find.text('10 opções no catálogo'), findsOneWidget);
  });

  testWidgets('Registra uma venda e avança o fluxo de pagamento',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const CatalogoApp());
    await tester.tap(find.text('Vendas'));
    await tester.pumpAndSettle();

    // Dados fictícios: 6 vendas, R$ 60,50 vendido, R$ 42,50 recebido
    expect(find.text('6 vendas registradas'), findsOneWidget);
    expect(find.text('R\$ 60,50'), findsOneWidget);
    expect(find.text('R\$ 42,50'), findsOneWidget);
    expect(find.text('R\$ 18,00'), findsWidgets);

    // Nova venda: 2x Pão de queijo (primeira opção) = R$ 10,00
    await tester.tap(find.byTooltip('Aumentar'));
    await tester.pump();
    await tester.tap(find.text('Registrar venda'));
    await tester.pump();

    expect(find.text('7 vendas registradas'), findsOneWidget);
    expect(find.text('2x Pão de queijo'), findsNWidgets(2));
    expect(find.text('R\$ 70,50'), findsOneWidget); // vendido
    expect(find.text('R\$ 28,00'), findsOneWidget); // a receber

    // Confirma o pagamento da venda nova
    await tester.tap(find.text('Confirmar pagamento').first);
    await tester.pump();

    expect(find.text('R\$ 52,50'), findsOneWidget); // recebido
    expect(find.text('R\$ 18,00'), findsWidgets); // a receber
  });
}
