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
        scaffoldBackgroundColor: Colors.white,
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade800,
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
  final List<String> detalhesVendas = [];
  final List<double> valoresVendas = [];
  final List<int> etapas = [];

  final List<String> nomesEtapas = ['Aguardando pagamento', 'Pago', 'Entregue'];
  final List<String> acoesEtapas = ['Confirmar pagamento', 'Marcar entregue'];
  final List<Color> coresEtapas = [
    Colors.orange.shade800,
    Colors.green.shade700,
    Colors.blueGrey,
  ];
  final List<String> formasPagamento = ['Pix', 'Dinheiro', 'Cartão'];

  final TextEditingController campoNome = TextEditingController();
  final TextEditingController campoPreco = TextEditingController();

  int produtoEscolhido = 0;
  int quantidade = 1;
  String formaPagamento = 'Pix';

  // PASSO 3 • INTERAÇÃO
  void mostrarAviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), behavior: SnackBarBehavior.floating),
    );
  }

  void adicionarProduto() {
    final String nome = campoNome.text.trim();
    final double? preco = double.tryParse(campoPreco.text.replaceAll(',', '.'));

    if (nome.isEmpty || preco == null || preco <= 0) {
      mostrarAviso('Informe um nome e um preço válido.');
      return;
    }

    setState(() {
      produtos.add(nome);
      precos.add(preco);
    });
    campoNome.clear();
    campoPreco.clear();
    mostrarAviso('$nome cadastrado!');
  }

  void removerProduto(int indice) {
    final String nome = produtos[indice];

    setState(() {
      produtos.removeAt(indice);
      precos.removeAt(indice);
      produtoEscolhido = 0;
    });
    mostrarAviso('$nome removido do catálogo.');
  }

  void registrarVenda() {
    if (produtos.isEmpty) {
      mostrarAviso('Cadastre um produto antes de vender.');
      return;
    }

    final TimeOfDay agora = TimeOfDay.now();
    final String hora = '${agora.hour.toString().padLeft(2, '0')}:'
        '${agora.minute.toString().padLeft(2, '0')}';

    setState(() {
      vendas.insert(0, '${quantidade}x ${produtos[produtoEscolhido]}');
      detalhesVendas.insert(0, '$formaPagamento • $hora');
      valoresVendas.insert(0, precos[produtoEscolhido] * quantidade);
      etapas.insert(0, 0);
      quantidade = 1;
    });
    mostrarAviso('Venda registrada: ${vendas.first}');
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

  // PASSO 5 • PARTES DA TELA
  Widget construirTitulo(String titulo, String subtitulo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitulo, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget construirEtiqueta(String texto, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        texto,
        style: TextStyle(color: cor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget construirValor(String titulo, double valor, Color cor) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(titulo),
              const SizedBox(height: 4),
              Text(
                emReais(valor),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget construirFormularioProduto() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: campoNome,
                    decoration: const InputDecoration(
                      labelText: 'Nome do produto',
                      hintText: 'Ex.: Pão de queijo',
                      prefixIcon: Icon(Icons.fastfood_outlined),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: campoPreco,
                    decoration: const InputDecoration(
                      labelText: 'Preço',
                      hintText: '5,00',
                      prefixText: 'R\$ ',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: adicionarProduto,
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar produto'),
            ),
          ],
        ),
      ),
    );
  }

  Widget construirFormularioVenda() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nova venda',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<int>(
              isExpanded: true,
              value: produtos.isEmpty ? null : produtoEscolhido,
              hint: const Text('Nenhum produto no catálogo'),
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
                const Text('Qtd:'),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  tooltip: 'Diminuir',
                  onPressed:
                      quantidade > 1 ? () => setState(() => quantidade--) : null,
                ),
                Text(
                  '$quantidade',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
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
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: registrarVenda,
              icon: const Icon(Icons.point_of_sale),
              label: const Text('Registrar venda'),
            ),
          ],
        ),
      ),
    );
  }

  // PASSO 6 • LISTAS DINÂMICAS
  Widget construirListaProdutos() {
    if (produtos.isEmpty) {
      return const Center(child: Text('Nenhum produto cadastrado.'));
    }

    return ListView.builder(
      itemCount: produtos.length,
      itemBuilder: (context, indice) {
        return Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.amber.shade100,
              foregroundColor: Colors.red.shade800,
              child: const Icon(Icons.fastfood_outlined),
            ),
            title: Text(
              produtos[indice],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  emReais(precos[indice]),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red.shade800,
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

  Widget construirCardVenda(int indice) {
    final int etapa = etapas[indice];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    vendas[indice],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  emReais(valoresVendas[indice]),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(detalhesVendas[indice]),
            const SizedBox(height: 4),
            Row(
              children: [
                construirEtiqueta(nomesEtapas[etapa], coresEtapas[etapa]),
                const Spacer(),
                if (etapa < 2)
                  TextButton(
                    onPressed: () => avancarEtapa(indice),
                    child: Text(acoesEtapas[etapa]),
                  )
                else
                  const Icon(Icons.check_circle, color: Colors.blueGrey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // PASSO 7 • ABAS DA TELA
  Widget construirAbaProdutos() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          construirTitulo(
            'Gerenciamento de produtos',
            'Cadastre e remova os produtos da cantina.',
          ),
          construirFormularioProduto(),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Produtos cadastrados',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              construirEtiqueta('${produtos.length} itens', Colors.red.shade800),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(child: construirListaProdutos()),
        ],
      ),
    );
  }

  Widget construirAbaVendas() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        construirTitulo(
          'Controle de vendas do dia',
          'Registre as vendas e acompanhe o pagamento.',
        ),
        Row(
          children: [
            construirValor('Vendido', totalVendido, Colors.green.shade700),
            construirValor('Recebido', totalRecebido, Colors.green.shade700),
            construirValor(
              'A receber',
              totalVendido - totalRecebido,
              Colors.red.shade800,
            ),
          ],
        ),
        const SizedBox(height: 8),
        construirFormularioVenda(),
        const SizedBox(height: 16),
        Text('${vendas.length} vendas registradas'),
        const SizedBox(height: 8),
        for (int i = 0; i < vendas.length; i++) construirCardVenda(i),
      ],
    );
  }

  // PASSO 8 • TELA COMPLETA
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red.shade800,
          foregroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(Icons.storefront),
              SizedBox(width: 10),
              Text(
                'Administração Cantina',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amber,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Produtos'),
              Tab(icon: Icon(Icons.point_of_sale), text: 'Gestão de vendas'),
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
