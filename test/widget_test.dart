import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catalogo_do_dia/main.dart';

void main() {
  testWidgets('Cadastra e remove produtos', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const CatalogoApp());

    expect(find.text('Administração Cantina'), findsOneWidget);
    expect(find.text('Pão de queijo'), findsOneWidget);
    expect(find.text('10 itens'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'Tapioca');
    await tester.enterText(find.byType(TextField).at(1), '7,50');
    await tester.tap(find.text('Cadastrar produto'));
    await tester.pump();

    expect(find.text('11 itens'), findsOneWidget);
    expect(find.text('R\$ 7,50'), findsOneWidget);

    await tester.tap(find.byTooltip('Excluir produto').first);
    await tester.pump();

    expect(find.text('Pão de queijo'), findsNothing);
    expect(find.text('10 itens'), findsOneWidget);
  });

  testWidgets('Registra uma venda e avança o fluxo de pagamento',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const CatalogoApp());
    await tester.tap(find.text('Gestão de vendas'));
    await tester.pumpAndSettle();

    expect(find.text('0 vendas registradas'), findsOneWidget);

    // Nova venda: 2x Pão de queijo (primeiro produto) = R$ 10,00
    await tester.tap(find.byTooltip('Aumentar'));
    await tester.pump();
    await tester.tap(find.text('Registrar venda'));
    await tester.pump();

    expect(find.text('1 vendas registradas'), findsOneWidget);
    expect(find.text('Aguardando pagamento'), findsOneWidget);

    await tester.tap(find.text('Confirmar pagamento'));
    await tester.pump();
    expect(find.text('Pago'), findsOneWidget);

    await tester.tap(find.text('Marcar entregue'));
    await tester.pump();
    expect(find.text('Entregue'), findsOneWidget);
  });
}
