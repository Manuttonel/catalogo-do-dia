import 'package:flutter/material.dart';

// PASSO 1 • CÓDIGO INICIAL
void main() {
  runApp(const CatalogoApp());
}

class CatalogoApp extends StatelessWidget {
  const CatalogoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catálogo do dia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          primary: Colors.red.shade700,
          secondary: Colors.amber,
        ),
        scaffoldBackgroundColor: Colors.amber.shade100,
      ),
      home: const TelaCatalogo(),
    );
  }
}

// PASSO 2 • MODELO DA VENDA
// Cada venda guarda o que foi vendido, quanto, como foi pago
// e em que etapa do fluxo de pagamento ela está.
const String aguardando = 'Aguardando pagamento';
const String pago = 'Pago';
const String entregue = 'Entregue';

class Venda {
  Venda({
    required this.comida,
    required this.precoUnitario,
    required this.quantidade,
    required this.pagamento,
    required this.horario,
    this.status = aguardando,
  });

  final String comida;
  final double precoUnitario;
  final int quantidade;
  final String pagamento;
  final String horario;
  String status;

  double get total => precoUnitario * quantidade;
}

// PASSO 1 • ESTRUTURA DA TELA
class TelaCatalogo extends StatefulWidget {
  const TelaCatalogo({super.key});

  @override
  State<TelaCatalogo> createState() => _TelaCatalogoState();
}

class _TelaCatalogoState extends State<TelaCatalogo> {
  // PASSO 2 • DADOS DO CATÁLOGO
  final List<String> comidas = [
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

  // Campos de texto para adicionar uma nova comida
  final TextEditingController campoNome = TextEditingController();
  final TextEditingController campoPreco = TextEditingController();

  // PASSO 2 • DADOS DAS VENDAS (fictícios, a mais nova primeiro)
  final List<Venda> vendas = [
    Venda(
      comida: 'Achocolatado',
      precoUnitario: 4.00,
      quantidade: 1,
      pagamento: 'Cartão',
      horario: '10:45',
    ),
    Venda(
      comida: 'Pastel de carne',
      precoUnitario: 7.00,
      quantidade: 2,
      pagamento: 'Dinheiro',
      horario: '10:32',
    ),
    Venda(
      comida: 'Misto quente',
      precoUnitario: 8.00,
      quantidade: 1,
      pagamento: 'Pix',
      horario: '10:20',
      status: pago,
    ),
    Venda(
      comida: 'Suco natural',
      precoUnitario: 6.00,
      quantidade: 3,
      pagamento: 'Cartão',
      horario: '10:05',
      status: pago,
    ),
    Venda(
      comida: 'Coxinha',
      precoUnitario: 6.50,
      quantidade: 1,
      pagamento: 'Dinheiro',
      horario: '09:40',
      status: entregue,
    ),
    Venda(
      comida: 'Pão de queijo',
      precoUnitario: 5.00,
      quantidade: 2,
      pagamento: 'Pix',
      horario: '08:15',
      status: entregue,
    ),
  ];

  // Escolhas do formulário de nova venda
  final List<String> formasPagamento = ['Pix', 'Dinheiro', 'Cartão'];
  int comidaSelecionada = 0;
  int quantidade = 1;
  String formaPagamento = 'Pix';

  @override
  void dispose() {
    campoNome.dispose();
    campoPreco.dispose();
    super.dispose();
  }

  void mostrarAviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  // PASSO 3 • INTERAÇÃO DO CATÁLOGO
  void adicionarComida() {
    final String nome = campoNome.text.trim();
    final String textoPreco = campoPreco.text
        .replaceAll('R\$', '')
        .replaceAll(',', '.')
        .trim();
    final double? preco = double.tryParse(textoPreco);

    if (nome.isEmpty || preco == null) {
      mostrarAviso('Preencha o nome e um valor válido (ex: 5,00)');
      return;
    }

    setState(() {
      comidas.add(nome);
      precos.add(preco);
    });

    campoNome.clear();
    campoPreco.clear();
  }

  // Remove a comida escolhida (e o preço dela) do catálogo
  void removerComida(int indice) {
    final String nome = comidas[indice];

    setState(() {
      comidas.removeAt(indice);
      precos.removeAt(indice);
      if (comidaSelecionada >= comidas.length) {
        comidaSelecionada = 0;
      }
    });

    mostrarAviso('$nome removido do catálogo');
  }

  // PASSO 3 • INTERAÇÃO DAS VENDAS
  void registrarVenda() {
    if (comidas.isEmpty) {
      mostrarAviso('Adicione uma comida no catálogo primeiro');
      return;
    }

    final DateTime agora = DateTime.now();
    final String horario = '${agora.hour.toString().padLeft(2, '0')}:'
        '${agora.minute.toString().padLeft(2, '0')}';

    final Venda novaVenda = Venda(
      comida: comidas[comidaSelecionada],
      precoUnitario: precos[comidaSelecionada],
      quantidade: quantidade,
      pagamento: formaPagamento,
      horario: horario,
    );

    setState(() {
      vendas.insert(0, novaVenda);
      quantidade = 1;
    });

    mostrarAviso(
      'Venda registrada: ${novaVenda.quantidade}x ${novaVenda.comida}',
    );
  }

  // Fluxo: Aguardando pagamento → Pago → Entregue
  void avancarStatus(Venda venda) {
    setState(() {
      if (venda.status == aguardando) {
        venda.status = pago;
      } else if (venda.status == pago) {
        venda.status = entregue;
      }
    });
  }

  // PASSO 4 • CÁLCULOS E FORMATAÇÃO
  String formatarPreco(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  double get totalVendido {
    double soma = 0;
    for (final Venda venda in vendas) {
      soma += venda.total;
    }
    return soma;
  }

  double get totalRecebido {
    double soma = 0;
    for (final Venda venda in vendas) {
      if (venda.status != aguardando) {
        soma += venda.total;
      }
    }
    return soma;
  }

  double get totalAReceber => totalVendido - totalRecebido;

  // PASSO 5 • FORMULÁRIO DE CADASTRO DE COMIDA
  Widget construirFormulario() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: campoNome,
              decoration: const InputDecoration(
                labelText: 'Nome da comida',
                hintText: 'Ex: Pão de queijo',
                prefixIcon: Icon(Icons.fastfood),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: campoPreco,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Valor',
                hintText: 'Ex: 5,00',
                prefixText: 'R\$ ',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: adicionarComida,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar ao catálogo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PASSO 6 • LISTA DINÂMICA DO CATÁLOGO
  Widget construirCatalogo() {
    return ListView.builder(
      itemCount: comidas.length,
      itemBuilder: (context, indice) {
        return Card(
          color: Colors.white,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.red.shade700,
              child: const Icon(Icons.restaurant),
            ),
            title: Text(comidas[indice]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatarPreco(precos[indice]),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    removerComida(indice);
                  },
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red.shade700,
                  tooltip: 'Remover',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // PASSO 7 • ABA 1: CATÁLOGO
  Widget construirAbaCatalogo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Confira o que tem na cantina hoje!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 12),
          construirFormulario(),
          const SizedBox(height: 12),
          Text('${comidas.length} opções no catálogo'),
          const SizedBox(height: 8),
          Expanded(
            child: construirCatalogo(),
          ),
        ],
      ),
    );
  }

  // PASSO 5 • RESUMO DO CAIXA
  Widget construirCartaoResumo(String titulo, double valor, Color cor) {
    return Expanded(
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(titulo, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                formatarPreco(valor),
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

  Widget construirResumo() {
    return Row(
      children: [
        construirCartaoResumo(
          'Vendido',
          totalVendido,
          Colors.green.shade700,
        ),
        construirCartaoResumo(
          'Recebido',
          totalRecebido,
          Colors.green.shade700,
        ),
        construirCartaoResumo(
          'A receber',
          totalAReceber,
          Colors.red.shade700,
        ),
      ],
    );
  }

  // PASSO 5 • FORMULÁRIO DE NOVA VENDA
  Widget construirFormularioVenda() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nova venda',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Escolha da comida (vem do catálogo)
            DropdownButton<int>(
              isExpanded: true,
              value: comidas.isEmpty ? null : comidaSelecionada,
              hint: const Text('Catálogo vazio'),
              items: [
                for (int i = 0; i < comidas.length; i++)
                  DropdownMenuItem(
                    value: i,
                    child: Text(
                      '${comidas[i]} • ${formatarPreco(precos[i])}',
                    ),
                  ),
              ],
              onChanged: (valor) {
                setState(() {
                  comidaSelecionada = valor ?? 0;
                });
              },
            ),
            const SizedBox(height: 8),

            // Quantidade e forma de pagamento
            Row(
              children: [
                const Text('Qtd:'),
                IconButton(
                  onPressed: quantidade > 1
                      ? () => setState(() => quantidade--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  tooltip: 'Diminuir',
                ),
                Text(
                  '$quantidade',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => quantidade++),
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Aumentar',
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: formaPagamento,
                  items: [
                    for (final String forma in formasPagamento)
                      DropdownMenuItem(value: forma, child: Text(forma)),
                  ],
                  onChanged: (valor) {
                    setState(() {
                      formaPagamento = valor ?? 'Pix';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: registrarVenda,
              icon: const Icon(Icons.point_of_sale),
              label: const Text('Registrar venda'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PASSO 6 • CARTÃO DE CADA VENDA
  Color corDoStatus(String status) {
    if (status == aguardando) return Colors.orange.shade800;
    if (status == pago) return Colors.green.shade700;
    return Colors.blueGrey;
  }

  Widget construirCartaoVenda(Venda venda) {
    Widget acao;
    if (venda.status == aguardando) {
      acao = TextButton(
        onPressed: () => avancarStatus(venda),
        child: const Text('Confirmar pagamento'),
      );
    } else if (venda.status == pago) {
      acao = TextButton(
        onPressed: () => avancarStatus(venda),
        child: const Text('Marcar entregue'),
      );
    } else {
      acao = const Icon(Icons.check_circle, color: Colors.blueGrey);
    }

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${venda.quantidade}x ${venda.comida}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  formatarPreco(venda.total),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${venda.pagamento} • ${venda.horario}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: corDoStatus(venda.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    venda.status,
                    style: TextStyle(
                      color: corDoStatus(venda.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                acao,
              ],
            ),
          ],
        ),
      ),
    );
  }

  // PASSO 7 • ABA 2: VENDAS
  Widget construirAbaVendas() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Controle de vendas do dia',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade700,
          ),
        ),
        const SizedBox(height: 12),
        construirResumo(),
        const SizedBox(height: 8),
        construirFormularioVenda(),
        const SizedBox(height: 12),
        Text('${vendas.length} vendas registradas'),
        const SizedBox(height: 8),
        for (final Venda venda in vendas) construirCartaoVenda(venda),
      ],
    );
  }

  // PASSO 8 • TELA COMPLETA COM AS DUAS ABAS
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Catálogo do dia'),
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.amber,
          bottom: const TabBar(
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amber,
            tabs: [
              Tab(icon: Icon(Icons.restaurant_menu), text: 'Catálogo'),
              Tab(icon: Icon(Icons.point_of_sale), text: 'Vendas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            construirAbaCatalogo(),
            construirAbaVendas(),
          ],
        ),
      ),
    );
  }
}
