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

// PASSO 1 • ESTRUTURA DA TELA
class TelaCatalogo extends StatefulWidget {
  const TelaCatalogo({super.key});

  @override
  State<TelaCatalogo> createState() => _TelaCatalogoState();
}

class _TelaCatalogoState extends State<TelaCatalogo> {
  // PASSO 2 • DADOS
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

  // PASSO 3 • INTERAÇÃO
  void adicionarComida() {
    final String nome = campoNome.text.trim();
    final String textoPreco = campoPreco.text
        .replaceAll('R\$', '')
        .replaceAll(',', '.')
        .trim();
    final double? preco = double.tryParse(textoPreco);

    if (nome.isEmpty || preco == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha o nome e um valor válido (ex: 5,00)'),
        ),
      );
      return;
    }

    setState(() {
      comidas.add(nome);
      precos.add(preco);
    });

    campoNome.clear();
    campoPreco.clear();
  }

  // PASSO 4 • FORMATAÇÃO DO VALOR
  String formatarPreco(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // PASSO 5 • FORMULÁRIO DE CADASTRO
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

  // PASSO 6 • LISTA DINÂMICA
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
            trailing: Text(
              formatarPreco(precos[indice]),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
          ),
        );
      },
    );
  }

  // PASSO 7 • TELA COMPLETA  +  PASSO 8 • ACABAMENTO
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo do dia'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.amber,
      ),
      body: Padding(
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
      ),
    );
  }
}
