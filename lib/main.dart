
import 'package:flutter/material.dart';


// 1. CONSTANTES E CONFIGURAÇÕES


const String nomeAplicativo = 'Administração Cantina';

const Color corPrincipal = Color(0xFFC62828);
const Color corFundo = Color(0xFFF5F6F8);

// 2. MODELOS

// Modelo de produto
class Produto {
  final String nome;
  final double preco;

  const Produto({
    required this.nome,
    required this.preco,
  });
}

// Estados possíveis de uma venda
enum StatusVenda {
  aguardandoPagamento,
  pago,
  entregue,
}

// Modelo de venda
class Venda {
  final Produto produto;
  final int quantidade;
  final String pagamento;
  final String horario;
  StatusVenda status;

  Venda({
    required this.produto,
    required this.quantidade,
    required this.pagamento,
    required this.horario,
    this.status = StatusVenda.aguardandoPagamento,
  });

  double get total => produto.preco * quantidade;
}

// 3. INICIALIZAÇÃO DO APLICATIVO

void main() {
  runApp(const CatalogoApp());
}

class CatalogoApp extends StatelessWidget {
  const CatalogoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: nomeAplicativo,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: corPrincipal,
          primary: corPrincipal,
          secondary: Colors.amber,
        ),
        scaffoldBackgroundColor: corFundo,
        useMaterial3: true,
      ),
      home: const TelaCatalogo(),
    );
  }
}

// 4. TELA PRINCIPAL

class TelaCatalogo extends StatefulWidget {
  const TelaCatalogo({super.key});

  @override
  State<TelaCatalogo> createState() => _TelaCatalogoState();
}

class _TelaCatalogoState extends State<TelaCatalogo> {

  
  // 4.1 DADOS DOS PRODUTOS

  final List<Produto> produtos = [
    Produto(nome: 'Pão de queijo', preco: 5.00),
    Produto(nome: 'Coxinha', preco: 6.50),
    Produto(nome: 'Pastel de carne', preco: 7.00),
    Produto(nome: 'Esfiha de frango', preco: 6.00),
    Produto(nome: 'Misto quente', preco: 8.00),
    Produto(nome: 'Enroladinho de salsicha', preco: 5.50),
    Produto(nome: 'Bolo de cenoura', preco: 4.50),
    Produto(nome: 'Suco natural', preco: 6.00),
    Produto(nome: 'Achocolatado', preco: 4.00),
    Produto(nome: 'Refrigerante lata', preco: 5.00),
  ];

  // 4.2 DADOS DAS VENDAS
  

  final List<Venda> vendas = [];

  // ----------------------------------------------------------
  // 4.3 FORMULÁRIOS E CONTROLES
  // ----------------------------------------------------------

  final TextEditingController campoNome = TextEditingController();
  final TextEditingController campoPreco = TextEditingController();

  final List<String> formasPagamento = [
    'Pix',
    'Dinheiro',
    'Cartão',
  ];

  int produtoSelecionado = 0;
  int quantidade = 1;

  String formaPagamento = 'Pix';

  int? produtoEmHover;

  // ----------------------------------------------------------
  // 4.4 CICLO DE VIDA
  // ----------------------------------------------------------

  @override
  void dispose() {
    campoNome.dispose();
    campoPreco.dispose();
    super.dispose();
  }

  // ==========================================================
  // 5. FUNÇÕES AUXILIARES
  // ==========================================================

  // Exibe mensagens na parte inferior da tela
  void mostrarAviso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Formata valores 
  String formatarPreco(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // Retorna a descrição do status
  String descricaoStatus(StatusVenda status) {
    switch (status) {
      case StatusVenda.aguardandoPagamento:
        return 'Aguardando pagamento';
      case StatusVenda.pago:
        return 'Pago';
      case StatusVenda.entregue:
        return 'Entregue';
    }
  }

  // Define a cor de cada status
  Color corDoStatus(StatusVenda status) {
    switch (status) {
      case StatusVenda.aguardandoPagamento:
        return Colors.orange.shade800;
      case StatusVenda.pago:
        return Colors.green.shade700;
      case StatusVenda.entregue:
        return Colors.blueGrey;
    }
  }

  // ==========================================================
  // 6. GERENCIAMENTO DE PRODUTOS
  // ==========================================================

  // Cadastra um novo produto
  void adicionarProduto() {
    final String nome = campoNome.text.trim();

    final String textoPreco = campoPreco.text
        .replaceAll('R\$', '')
        .replaceAll(',', '.')
        .trim();

    final double? preco = double.tryParse(textoPreco);

    if (nome.isEmpty || preco == null || !preco.isFinite || preco <= 0) {
      mostrarAviso('Informe um nome e um preço válido.');
      return;
    }

    setState(() {
      produtos.add(
        Produto(
          nome: nome,
          preco: preco,
        ),
      );
    });

    campoNome.clear();
    campoPreco.clear();

    mostrarAviso('Produto cadastrado com sucesso!');
  }

  // Remove um produto do catálogo
  void removerProduto(int indice) {
    if (indice < 0 || indice >= produtos.length) return;

    final String nome = produtos[indice].nome;

    setState(() {
      produtos.removeAt(indice);

      if (produtos.isEmpty || produtoSelecionado >= produtos.length) {
        produtoSelecionado = 0;
      }

      produtoEmHover = null;
    });

    mostrarAviso('$nome removido do catálogo.');
  }

  
  // 7. GERENCIAMENTO DE VENDAS
  

  // Registra uma nova venda
  void registrarVenda() {
    if (produtos.isEmpty) {
      mostrarAviso('Cadastre um produto antes de registrar uma venda.');
      return;
    }

    final DateTime agora = DateTime.now();

    final String horario =
        '${agora.hour.toString().padLeft(2, '0')}:'
        '${agora.minute.toString().padLeft(2, '0')}';

    final Venda novaVenda = Venda(
      produto: produtos[produtoSelecionado],
      quantidade: quantidade,
      pagamento: formaPagamento,
      horario: horario,
    );

    setState(() {
      vendas.insert(0, novaVenda);
      quantidade = 1;
    });

    mostrarAviso(
      'Venda registrada: ${novaVenda.quantidade}x ${novaVenda.produto.nome}',
    );
  }

  // Avança o status da venda
  void avancarStatus(Venda venda) {
    setState(() {
      switch (venda.status) {
        case StatusVenda.aguardandoPagamento:
          venda.status = StatusVenda.pago;
          break;

        case StatusVenda.pago:
          venda.status = StatusVenda.entregue;
          break;

        case StatusVenda.entregue:
          break;
      }
    });
  }

  // 8. CÁLCULOS FINANCEIROS

  // Soma todas as vendas
  double get totalVendido {
    return vendas.fold(0, (soma, venda) => soma + venda.total);
  }

  // Soma somente as vendas pagas ou entregues
  double get totalRecebido {
    return vendas
        .where((venda) => venda.status != StatusVenda.aguardandoPagamento)
        .fold(0, (soma, venda) => soma + venda.total);
  }

  // Calcula o valor pendente de pagamento
  double get totalAReceber {
    return totalVendido - totalRecebido;
  }

  // 9. COMPONENTES VISUAIS - PRODUTOS

  // Formulário de cadastro de produtos
  Widget construirFormularioProduto() {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.add_box_outlined,
                  color: corPrincipal,
                  size: 20,
                ),
                const SizedBox(width: 7),
                const Text(
                  'Adicionar produto',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: campoNome,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Nome do produto',
                      hintText: 'Ex.: Pão de queijo',
                      prefixIcon: const Icon(
                        Icons.fastfood_outlined,
                        size: 18,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 11,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: campoPreco,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Preço',
                      hintText: '5,00',
                      prefixText: 'R\$ ',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 11,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            SizedBox(
              height: 38,
              child: ElevatedButton.icon(
                onPressed: adicionarProduto,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Cadastrar produto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: corPrincipal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card individual de produto
  Widget construirCardProduto(int indice) {
    final Produto produto = produtos[indice];
    final bool mouseSobreItem = produtoEmHover == indice;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          produtoEmHover = indice;
        });
      },
      onExit: (_) {
        setState(() {
          if (produtoEmHover == indice) {
            produtoEmHover = null;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          mouseSobreItem ? 1.008 : 1.0,
          mouseSobreItem ? 1.008 : 1.0,
          1.0,
        ),
        decoration: BoxDecoration(
          color: mouseSobreItem
              ? const Color(0xFFFFFCF4)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: mouseSobreItem
                ? Colors.amber.shade300
                : Colors.grey.shade200,
          ),
          boxShadow: mouseSobreItem
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.fastfood_outlined,
                  color: corPrincipal,
                  size: 19,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produto.nome,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Produto cadastrado',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  formatarPreco(produto.preco),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ),

              const SizedBox(width: 4),

              IconButton(
                constraints: const BoxConstraints.tightFor(
                  width: 34,
                  height: 34,
                ),
                padding: EdgeInsets.zero,
                onPressed: () => removerProduto(indice),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 19,
                ),
                color: corPrincipal,
                tooltip: 'Excluir produto',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Lista de produtos cadastrados
  Widget construirCatalogo() {
    if (produtos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 42,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            const Text(
              'Nenhum produto cadastrado',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 3),
            const Text(
              'Use o formulário acima para adicionar o primeiro produto.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: produtos.length,
      separatorBuilder: (context, indice) => const SizedBox(height: 6),
      itemBuilder: (context, indice) {
        return construirCardProduto(indice);
      },
    );
  }

  // Aba de gerenciamento de produtos
  Widget construirAbaProdutos() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Gerenciamento de produtos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: corPrincipal,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Cadastre, organize e remova os produtos da cantina.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 16),

          construirFormularioProduto(),

          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 18,
              ),
              const SizedBox(width: 7),

              const Expanded(
                child: Text(
                  'Produtos cadastrados',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${produtos.length} ${produtos.length == 1 ? 'item' : 'itens'}',
                  style: TextStyle(
                    color: corPrincipal,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Expanded(
            child: construirCatalogo(),
          ),
        ],
      ),
    );
  }

  // 10. COMPONENTES VISUAIS - RESUMO FINANCEIRO

  // Cartão de indicador financeiro
  Widget construirCartaoResumo(
    String titulo,
    double valor,
    Color cor,
  ) {
    return Expanded(
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                titulo,
                style: const TextStyle(fontSize: 13),
              ),
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

  // Agrupa os indicadores financeiros
  Widget construirResumoFinanceiro() {
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
          corPrincipal,
        ),
      ],
    );
  }

  // 11. COMPONENTES VISUAIS - VENDAS

  // Formulário para registrar uma nova venda
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButton<int>(
              isExpanded: true,
              value: produtos.isEmpty ? null : produtoSelecionado,
              hint: const Text('Catálogo vazio'),
              items: [
                for (int i = 0; i < produtos.length; i++)
                  DropdownMenuItem(
                    value: i,
                    child: Text(
                      '${produtos[i].nome} • ${formatarPreco(produtos[i].preco)}',
                    ),
                  ),
              ],
              onChanged: produtos.isEmpty
                  ? null
                  : (valor) {
                      if (valor == null) return;

                      setState(() {
                        produtoSelecionado = valor;
                      });
                    },
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Text('Qtd:'),

                IconButton(
                  onPressed: quantidade > 1
                      ? () {
                          setState(() {
                            quantidade--;
                          });
                        }
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
                  onPressed: () {
                    setState(() {
                      quantidade++;
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Aumentar',
                ),

                const Spacer(),

                DropdownButton<String>(
                  value: formaPagamento,
                  items: [
                    for (final forma in formasPagamento)
                      DropdownMenuItem(
                        value: forma,
                        child: Text(forma),
                      ),
                  ],
                  onChanged: (valor) {
                    if (valor == null) return;

                    setState(() {
                      formaPagamento = valor;
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
                backgroundColor: corPrincipal,
                foregroundColor: Colors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card individual de venda
  Widget construirCardVenda(Venda venda) {
    Widget acao;

    switch (venda.status) {
      case StatusVenda.aguardandoPagamento:
        acao = TextButton(
          onPressed: () => avancarStatus(venda),
          child: const Text('Confirmar pagamento'),
        );
        break;

      case StatusVenda.pago:
        acao = TextButton(
          onPressed: () => avancarStatus(venda),
          child: const Text('Marcar entregue'),
        );
        break;

      case StatusVenda.entregue:
        acao = const Icon(
          Icons.check_circle,
          color: Colors.blueGrey,
        );
        break;
    }

    final Color corStatus = corDoStatus(venda.status);

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
                    '${venda.quantidade}x ${venda.produto.nome}',
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
                    color: corStatus.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    descricaoStatus(venda.status),
                    style: TextStyle(
                      color: corStatus,
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

  // Aba de gerenciamento de vendas
  Widget construirAbaVendas() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Controle de vendas do dia',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: corPrincipal,
          ),
        ),

        const SizedBox(height: 12),

        construirResumoFinanceiro(),

        const SizedBox(height: 8),

        construirFormularioVenda(),

        const SizedBox(height: 12),

        Text('${vendas.length} vendas registradas'),

        const SizedBox(height: 8),

        for (final venda in vendas)
          construirCardVenda(venda),
      ],
    );
  }

  // 12. CONSTRUÇÃO DA INTERFACE PRINCIPAL

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                size: 27,
              ),
              SizedBox(width: 10),
              Text(
                nomeAplicativo,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          backgroundColor: corPrincipal,
          foregroundColor: Colors.white,
          elevation: 2,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amber,
            indicatorWeight: 3,
            tabs: [
              Tab(
                icon: Icon(Icons.inventory_2_outlined),
                text: 'Produtos',
              ),
              Tab(
                icon: Icon(Icons.point_of_sale),
                text: 'Gestão de vendas',
              ),
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
