import 'package:flutter/material.dart';

// Cores usadas no app inteiro
const Color vermelho = Color(0xFFC62828);
const Color fundo = Color(0xFFF5F6F8);

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: vermelho,
          primary: vermelho,
          secondary: Colors.amber,
        ),
        scaffoldBackgroundColor: fundo,
      ),
      home: const TelaPrincipal(),
    );
  }
}

// ---------------------------------------------------------------------------
// MODELOS
// ---------------------------------------------------------------------------

class Produto {
  const Produto(this.nome, this.preco);

  final String nome;
  final double preco;
}

// Etapas pelas quais toda venda passa, na ordem
enum StatusVenda {
  aguardandoPagamento('Aguardando pagamento', Color(0xFFEF6C00)),
  pago('Pago', Color(0xFF388E3C)),
  entregue('Entregue', Colors.blueGrey);

  const StatusVenda(this.texto, this.cor);

  final String texto;
  final Color cor;
}

class Venda {
  Venda({
    required this.produto,
    required this.quantidade,
    required this.pagamento,
    required this.horario,
  });

  final Produto produto;
  final int quantidade;
  final String pagamento;
  final String horario;
  StatusVenda status = StatusVenda.aguardandoPagamento;

  double get total => produto.preco * quantidade;
  bool get foiPaga => status != StatusVenda.aguardandoPagamento;
}

// ---------------------------------------------------------------------------
// FUNÇÕES DE APOIO
// ---------------------------------------------------------------------------

// 5.5 -> "R$ 5,50"
String emReais(double valor) {
  return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}

// Hora atual no formato 09:05
String horaAtual() {
  final agora = DateTime.now();
  final hora = agora.hour.toString().padLeft(2, '0');
  final minuto = agora.minute.toString().padLeft(2, '0');
  return '$hora:$minuto';
}

void mostrarAviso(BuildContext context, String mensagem) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(mensagem), behavior: SnackBarBehavior.floating),
  );
}

// ---------------------------------------------------------------------------
// TELA PRINCIPAL
// Guarda os produtos e as vendas e repassa para as duas abas.
// ---------------------------------------------------------------------------

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  // Os dados ficam só na memória (não há banco de dados).
  // Ao recarregar a página, tudo volta a este estado inicial.
  final List<Produto> produtos = [
    const Produto('Pão de queijo', 5.00),
    const Produto('Coxinha', 6.50),
    const Produto('Pastel de carne', 7.00),
    const Produto('Esfiha de frango', 6.00),
    const Produto('Misto quente', 8.00),
    const Produto('Enroladinho de salsicha', 5.50),
    const Produto('Bolo de cenoura', 4.50),
    const Produto('Suco natural', 6.00),
    const Produto('Achocolatado', 4.00),
    const Produto('Refrigerante lata', 5.00),
  ];

  final List<Venda> vendas = [];

  void adicionarProduto(Produto produto) {
    setState(() => produtos.add(produto));
    mostrarAviso(context, '${produto.nome} cadastrado!');
  }

  void removerProduto(Produto produto) {
    setState(() => produtos.remove(produto));
    mostrarAviso(context, '${produto.nome} removido do catálogo.');
  }

  void registrarVenda(Venda venda) {
    setState(() => vendas.insert(0, venda));
    mostrarAviso(
      context,
      'Venda registrada: ${venda.quantidade}x ${venda.produto.nome}',
    );
  }

  // Aguardando pagamento -> Pago -> Entregue
  void avancarStatus(Venda venda) {
    setState(() {
      venda.status = switch (venda.status) {
        StatusVenda.aguardandoPagamento => StatusVenda.pago,
        StatusVenda.pago => StatusVenda.entregue,
        StatusVenda.entregue => StatusVenda.entregue,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: vermelho,
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
            AbaProdutos(
              produtos: produtos,
              aoAdicionar: adicionarProduto,
              aoRemover: removerProduto,
            ),
            AbaVendas(
              produtos: produtos,
              vendas: vendas,
              aoRegistrar: registrarVenda,
              aoAvancarStatus: avancarStatus,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ABA 1: PRODUTOS
// ---------------------------------------------------------------------------

class AbaProdutos extends StatefulWidget {
  const AbaProdutos({
    super.key,
    required this.produtos,
    required this.aoAdicionar,
    required this.aoRemover,
  });

  final List<Produto> produtos;
  final void Function(Produto) aoAdicionar;
  final void Function(Produto) aoRemover;

  @override
  State<AbaProdutos> createState() => _AbaProdutosState();
}

class _AbaProdutosState extends State<AbaProdutos> {
  final campoNome = TextEditingController();
  final campoPreco = TextEditingController();

  @override
  void dispose() {
    campoNome.dispose();
    campoPreco.dispose();
    super.dispose();
  }

  void cadastrar() {
    final nome = campoNome.text.trim();
    final preco = double.tryParse(campoPreco.text.replaceAll(',', '.').trim());

    if (nome.isEmpty || preco == null || preco <= 0) {
      mostrarAviso(context, 'Informe um nome e um preço válido.');
      return;
    }

    widget.aoAdicionar(Produto(nome, preco));
    campoNome.clear();
    campoPreco.clear();
  }

  @override
  Widget build(BuildContext context) {
    final produtos = widget.produtos;
    final quantidadeTexto = produtos.length == 1
        ? '1 item'
        : '${produtos.length} itens';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Titulo(
            'Gerenciamento de produtos',
            subtitulo: 'Cadastre e remova os produtos da cantina.',
          ),
          const SizedBox(height: 16),
          formulario(),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Produtos cadastrados',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              Etiqueta(quantidadeTexto, cor: vermelho),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: produtos.isEmpty
                ? const Center(child: Text('Nenhum produto cadastrado.'))
                : ListView(
                    children: [
                      for (final produto in produtos)
                        CartaoProduto(
                          produto: produto,
                          aoRemover: () => widget.aoRemover(produto),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget formulario() {
    return Card(
      color: Colors.white,
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
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
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
              onPressed: cadastrar,
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar produto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: vermelho,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ABA 2: GESTÃO DE VENDAS
// ---------------------------------------------------------------------------

class AbaVendas extends StatefulWidget {
  const AbaVendas({
    super.key,
    required this.produtos,
    required this.vendas,
    required this.aoRegistrar,
    required this.aoAvancarStatus,
  });

  final List<Produto> produtos;
  final List<Venda> vendas;
  final void Function(Venda) aoRegistrar;
  final void Function(Venda) aoAvancarStatus;

  @override
  State<AbaVendas> createState() => _AbaVendasState();
}

class _AbaVendasState extends State<AbaVendas> {
  static const formasDePagamento = ['Pix', 'Dinheiro', 'Cartão'];

  int produtoEscolhido = 0;
  int quantidade = 1;
  String pagamento = 'Pix';

  // Se o produto escolhido for removido do catálogo, volta para o primeiro
  int get indiceProduto =>
      produtoEscolhido < widget.produtos.length ? produtoEscolhido : 0;

  double get totalVendido =>
      widget.vendas.fold(0.0, (soma, venda) => soma + venda.total);

  double get totalRecebido => widget.vendas
      .where((venda) => venda.foiPaga)
      .fold(0.0, (soma, venda) => soma + venda.total);

  double get totalAReceber => totalVendido - totalRecebido;

  void registrar() {
    if (widget.produtos.isEmpty) {
      mostrarAviso(context, 'Cadastre um produto antes de vender.');
      return;
    }

    widget.aoRegistrar(
      Venda(
        produto: widget.produtos[indiceProduto],
        quantidade: quantidade,
        pagamento: pagamento,
        horario: horaAtual(),
      ),
    );
    setState(() => quantidade = 1);
  }

  @override
  Widget build(BuildContext context) {
    final vendas = widget.vendas;
    final quantidadeTexto = vendas.length == 1
        ? '1 venda registrada'
        : '${vendas.length} vendas registradas';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Titulo(
          'Controle de vendas do dia',
          subtitulo: 'Registre as vendas e acompanhe o pagamento.',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            CartaoResumo('Vendido', totalVendido, Colors.green.shade700),
            CartaoResumo('Recebido', totalRecebido, Colors.green.shade700),
            CartaoResumo('A receber', totalAReceber, vermelho),
          ],
        ),
        const SizedBox(height: 8),
        formulario(),
        const SizedBox(height: 16),
        Text(quantidadeTexto),
        const SizedBox(height: 8),
        for (final venda in vendas)
          CartaoVenda(
            venda: venda,
            aoAvancar: () => widget.aoAvancarStatus(venda),
          ),
      ],
    );
  }

  Widget formulario() {
    final produtos = widget.produtos;

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
            DropdownButton<int>(
              isExpanded: true,
              value: produtos.isEmpty ? null : indiceProduto,
              hint: const Text('Nenhum produto no catálogo'),
              items: [
                for (int i = 0; i < produtos.length; i++)
                  DropdownMenuItem(
                    value: i,
                    child: Text(
                      '${produtos[i].nome} • ${emReais(produtos[i].preco)}',
                    ),
                  ),
              ],
              onChanged: (indice) =>
                  setState(() => produtoEscolhido = indice ?? 0),
            ),
            Row(
              children: [
                const Text('Qtd:'),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  tooltip: 'Diminuir',
                  onPressed: quantidade > 1
                      ? () => setState(() => quantidade--)
                      : null,
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
                  value: pagamento,
                  items: [
                    for (final forma in formasDePagamento)
                      DropdownMenuItem(value: forma, child: Text(forma)),
                  ],
                  onChanged: (forma) =>
                      setState(() => pagamento = forma ?? 'Pix'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: registrar,
              icon: const Icon(Icons.point_of_sale),
              label: const Text('Registrar venda'),
              style: ElevatedButton.styleFrom(
                backgroundColor: vermelho,
                foregroundColor: Colors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// COMPONENTES REUTILIZADOS
// ---------------------------------------------------------------------------

class Titulo extends StatelessWidget {
  const Titulo(this.texto, {super.key, required this.subtitulo});

  final String texto;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          texto,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: vermelho,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitulo, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
}

class Etiqueta extends StatelessWidget {
  const Etiqueta(this.texto, {super.key, required this.cor});

  final String texto;
  final Color cor;

  @override
  Widget build(BuildContext context) {
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
}

class CartaoProduto extends StatelessWidget {
  const CartaoProduto({
    super.key,
    required this.produto,
    required this.aoRemover,
  });

  final Produto produto;
  final VoidCallback aoRemover;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.amber.shade100,
          foregroundColor: vermelho,
          child: const Icon(Icons.fastfood_outlined),
        ),
        title: Text(
          produto.nome,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emReais(produto.preco),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: vermelho,
              tooltip: 'Excluir produto',
              onPressed: aoRemover,
            ),
          ],
        ),
      ),
    );
  }
}

class CartaoResumo extends StatelessWidget {
  const CartaoResumo(this.titulo, this.valor, this.cor, {super.key});

  final String titulo;
  final double valor;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: Colors.white,
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
}

class CartaoVenda extends StatelessWidget {
  const CartaoVenda({super.key, required this.venda, required this.aoAvancar});

  final Venda venda;
  final VoidCallback aoAvancar;

  @override
  Widget build(BuildContext context) {
    // O botão muda conforme a etapa em que a venda está
    final Widget acao = switch (venda.status) {
      StatusVenda.aguardandoPagamento => TextButton(
        onPressed: aoAvancar,
        child: const Text('Confirmar pagamento'),
      ),
      StatusVenda.pago => TextButton(
        onPressed: aoAvancar,
        child: const Text('Marcar entregue'),
      ),
      StatusVenda.entregue => const Icon(
        Icons.check_circle,
        color: Colors.blueGrey,
      ),
    };

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
                  emReais(venda.total),
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
                Etiqueta(venda.status.texto, cor: venda.status.cor),
                const Spacer(),
                acao,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
