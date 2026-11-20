# Catálogo do dia

Catálogo de cantina feito só com Flutter (Dart), em uma página, nas cores vermelho e amarelo.
Mostra 10 comidas com preço e permite adicionar novas (nome + valor, ex: `Pão de queijo` / `5,00`).

O código fica todo em [`lib/main.dart`](lib/main.dart).

## Rodar no computador

```
flutter pub get
flutter run -d chrome
```

## Publicar no Vercel

O Vercel não tem Flutter instalado, então a versão web é gerada no computador e enviada pronta na pasta `build/web`:

```
flutter build web --release
git add .
git commit -m "atualiza catalogo"
git push
```

O `vercel.json` diz ao Vercel para publicar a pasta `build/web` sem rodar nenhum build.
