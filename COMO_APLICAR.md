# Como aplicar no repositório app_financas

Na pasta do seu clone do `app_financas`:

```bash
# 1. Remove o código antigo (as pastas android/ios/web/... continuam)
git rm -r -q lib
git rm -r -q test 2>/dev/null || true

# 2. Copie o conteúdo deste zip por cima (lib/, test/, pubspec.yaml,
#    analysis_options.yaml, firestore.rules, README.md, .github/)

# 3. Gere o firebase_options.dart real e instale as dependências
flutterfire configure
flutter pub get

# 4. Formate, analise e teste
dart format lib test
flutter analyze
flutter test

# 5. Commit
git add -A
git commit -m "feat: app de finanças pessoais com transações, categorias, dashboard e orçamentos"
git push
```

Observações:

- O código antigo tinha `lib/core/config/env.dart` commitado. Se ali houver
  alguma chave ou token, ela continua no histórico do Git mesmo depois de
  apagar o arquivo: troque (revogue) essa chave.
- O `firebase_options.dart` gerado pelo FlutterFire pode ser commitado. As
  chaves do Firebase não são secretas, quem protege os dados são as regras
  em `firestore.rules`.
- Se o Android reclamar de `minSdk`, ajuste em `android/app/build.gradle(.kts)`
  para `minSdk = 23` (exigência do Firebase Auth).
- Tire 3 prints (Início, Transações, Orçamentos), salve em `docs/` e
  descomente o bloco de imagens no README. Isso faz muita diferença para
  quem visita o repositório.
