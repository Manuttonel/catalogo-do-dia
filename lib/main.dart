import 'package:flutter/material.dart';

// PASSO 1 • CÓDIGO INICIAL
void main() {
  runApp(const CantinaApp());
}

class CantinaApp extends StatelessWidget {
  const CantinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Administração Cantina',
      theme: ThemeData(
        colorSchemeSeed: Colors.red,
        scaffoldBackgroundColor: Colors.amber.shade50,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const TelaCantina(),
    );
  }
}

// PASSO 1 • ESTRUTURA DA TELA
class TelaCantina extends StatefulWidget {
  const TelaCantina({super.key});

  @override
  State<TelaCantina> createState() => _TelaCantinaState();
}

class _TelaCantinaState extends State<TelaCantina> {
  // PASSO 2 • DADOS
  final List<String> produtos = [
    'Pão de queijo',
    'Coxinha',
    'Pastel de carne',
    'Esfiha de frango',
    'Misto quente',
    'Enroladinho de salsicha',
    'Bolo de cenoura',
    'Suco natural',
    'Achocolatado',
    'Refrigerante lata',
  ];

  final List<double> precos = [
    5.00, 6.50, 7.00, 6.00, 8.00,
    5.50, 4.50, 6.00, 4.00, 5.00,
  ];

  final List<String> vendas = [];
  final List<double> valoresVendas = [];
  final List<int> etapas = [];

  final List<String> nomesEtapas = ['Aguardando pagamento', 'Pago', 'Entregue'];
  final List<Color> coresEtapas = [Colors.orange, Colors.green, Colors.blueGrey];
  final List<String> formasPagamento = ['Pix', 'Dinheiro', 'Cartão'];

  final TextEditingController campoNome = TextEditingController();
  final TextEditingController campoPreco = TextEditingController();

  int produtoEscolhido = 0;
  int quantidade = 1;
  String formaPagamento = 'Pix';

  // PASSO 3 • INTERAÇÃO
  void adicionarProduto() {
    final double? preco = double.tryParse(campoPreco.text.replaceAll(',', '.'));

    if (campoNome.text.trim().isEmpty || preco == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o nome e um preço válido')),
      );
      return;
    }

    setState(() {
      produtos.add(campoNome.text.trim());
      precos.add(preco);
    });
    campoNome.clear();
    campoPreco.clear();
  }

  void removerProduto(int indice) {
    setState(() {
      produtos.removeAt(indice);
      precos.removeAt(indice);
      produtoEscolhido = 0;
    });
  }

  void registrarVenda() {
    if (produtos.isEmpty) return;

    setState(() {
      vendas.insert(0, '${quantidade}x ${produtos[produtoEscolhido]} • $formaPagamento');
      valoresVendas.insert(0, precos[produtoEscolhido] * quantidade);
      etapas.insert(0, 0);
      quantidade = 1;
    });
  }

  void avancarEtapa(int indice) {
    setState(() {
      if (etapas[indice] < 2) {
        etapas[indice]++;
      }
    });
  }

  // PASSO 4 • CÁLCULO
  double get totalVendido {
    double soma = 0;
    for (final double valor in valoresVendas) {
      soma += valor;
    }
    return soma;
  }

  double get totalRecebido {
    double soma = 0;
    for (int i = 0; i < vendas.length; i++) {
      if (etapas[i] > 0) {
        soma += valoresVendas[i];
      }
    }
    return soma;
  }

  String emReais(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // PASSO 5 • RESUMO DO CAIXA
  Widget construirValor(String titulo, double valor, Color cor) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(titulo),
              Text(
                emReais(valor),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget construirResumo() {
    return Row(
      children: [
        construirValor('Vendido', totalVendido, Colors.green),
        construirValor('Recebido', totalRecebido, Colors.green),
        construirValor('A receber', totalVendido - totalRecebido, Colors.red),
      ],
    );
  }

  // PASSO 6 • LISTAS DINÂMICAS
  Widget construirListaProdutos() {
    return ListView.builder(
      itemCount: produtos.length,
      itemBuilder: (context, indice) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.fastfood, color: Colors.red),
            title: Text(produtos[indice]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  emReais(precos[indice]),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Excluir produto',
                  onPressed: () => removerProduto(indice),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget construirListaVendas() {
    return ListView.builder(
      itemCount: vendas.length,
      itemBuilder: (context, indice) {
        final int etapa = etapas[indice];

        return Card(
          child: ListTile(
            title: Text(vendas[indice]),
            subtitle: Text(
              nomesEtapas[etapa],
              style: TextStyle(color: coresEtapas[etapa], fontWeight: FontWeight.bold),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  emReais(valoresVendas[indice]),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
                if (etapa == 0)
                  IconButton(
                    icon: const Icon(Icons.payments_outlined),
                    tooltip: 'Confirmar pagamento',
                    onPressed: () => avancarEtapa(indice),
                  ),
                if (etapa == 1)
                  IconButton(
                    icon: const Icon(Icons.delivery_dining),
                    tooltip: 'Marcar entregue',
                    onPressed: () => avancarEtapa(indice),
                  ),
                if (etapa == 2)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.check_circle, color: Colors.blueGrey),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // PASSO 7 • ABAS DA TELA
  Widget construirAbaProdutos() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: campoNome,
            decoration: const InputDecoration(labelText: 'Nome do produto'),
          ),
          TextField(
            controller: campoPreco,
            decoration: const InputDecoration(labelText: 'Preço', prefixText: 'R\$ '),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: adicionarProduto,
            child: const Text('Cadastrar produto'),
          ),
          const SizedBox(height: 16),
          Text('${produtos.length} produtos cadastrados'),
          Expanded(child: construirListaProdutos()),
        ],
      ),
    );
  }

  Widget construirAbaVendas() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          construirResumo(),
          const SizedBox(height: 8),
          DropdownButton<int>(
            isExpanded: true,
            value: produtos.isEmpty ? null : produtoEscolhido,
            items: [
              for (int i = 0; i < produtos.length; i++)
                DropdownMenuItem(
                  value: i,
                  child: Text('${produtos[i]} • ${emReais(precos[i])}'),
                ),
            ],
            onChanged: (valor) => setState(() => produtoEscolhido = valor!),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                tooltip: 'Diminuir',
                onPressed: quantidade > 1 ? () => setState(() => quantidade--) : null,
              ),
              Text('$quantidade'),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Aumentar',
                onPressed: () => setState(() => quantidade++),
              ),
              const Spacer(),
              DropdownButton<String>(
                value: formaPagamento,
                items: [
                  for (final String forma in formasPagamento)
                    DropdownMenuItem(value: forma, child: Text(forma)),
                ],
                onChanged: (valor) => setState(() => formaPagamento = valor!),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: registrarVenda,
            child: const Text('Registrar venda'),
          ),
          const SizedBox(height: 16),
          Text('${vendas.length} vendas registradas'),
          Expanded(child: construirListaVendas()),
        ],
      ),
    );
  }

  // PASSO 8 • TELA COMPLETA
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administração Cantina'),
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amber,
            tabs: [
              Tab(icon: Icon(Icons.restaurant_menu), text: 'Produtos'),
              Tab(icon: Icon(Icons.point_of_sale), text: 'Vendas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            construirAbaProdutos(),
            construirAbaVendas(),
          ],
        ),
      ),
    );
  }
}
