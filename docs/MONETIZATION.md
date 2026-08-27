# Publicação mundial, anúncios e versão PRO

O app usa **um único cadastro gratuito** na Google Play e na App Store. A
versão PRO é uma compra interna única e não consumível, com o identificador:

`chess_chalenges_pro_lifetime`

Essa estrutura mantém o mesmo link da loja, avaliações, progresso local e
base de usuários. A compra fica associada à conta Google/Apple do jogador; não
é necessário criar login próprio para a primeira versão.

## O que já está implementado

- FREE por padrão e PRO após compra ou restauração.
- Tela PRO ao tocar no selo FREE/PRO.
- Preço localizado carregado diretamente da loja.
- Botão **Restaurar compra**.
- Intersticial somente após fases novas: primeiro na 3ª conclusão e depois a
  cada 3 conclusões, com intervalo mínimo de 90 segundos.
- Nenhum anúncio ao revisar uma fase, na abertura do app ou durante uma jogada.
- Consentimento de anúncios pelo Google UMP e acesso às opções de privacidade
  quando exigido para o usuário.
- Falha aberta: sem internet, loja ou anúncio disponível, o jogo segue offline.

## 1. Identidade definitiva do aplicativo

Antes de criar o app nas lojas, trocar os identificadores `com.example` por um
ID definitivo que seja seu, por exemplo `com.suaempresa.chesschalenges`:

- Android: `android/app/build.gradle.kts`, campo `applicationId` e `namespace`.
- iOS: `ios/Runner.xcodeproj/project.pbxproj`, campo
  `PRODUCT_BUNDLE_IDENTIFIER`.

Depois de publicar, não se deve mudar esse identificador.

## 2. Google Play Console

1. Criar o app como gratuito e selecionar todos os países desejados em
   **Produção > Países/regiões**.
2. Em **Monetizar > Produtos > Produtos únicos**, criar
   `chess_chalenges_pro_lifetime` como produto não consumível/permanente.
3. Definir o preço-base. A Play converte para moedas locais; revise os preços
   sugeridos por país.
4. Ativar o produto.
5. Criar uma versão de teste interno e adicionar contas de teste de licença.
   Compras não funcionam corretamente em um APK instalado diretamente; teste
   pelo link da faixa interna da Play.
6. Em **Relatórios financeiros**, criar/vincular o perfil de pagamentos,
   informar conta bancária e concluir verificação fiscal/identidade.

## 3. App Store Connect

1. Aceitar o **Paid Apps Agreement** em Business e preencher dados bancários e
   fiscais.
2. Em **Monetization > In-App Purchases**, criar um produto
   **Non-Consumable** com ID `chess_chalenges_pro_lifetime`.
3. Adicionar nome, descrição, preço, disponibilidade mundial e screenshot para
   revisão.
4. Na primeira vez, enviar a compra junto com uma nova versão do app.
5. Testar com Sandbox/TestFlight e o botão **Restaurar compra**.

## 4. AdMob

1. Criar os apps Android e iOS no AdMob usando os mesmos IDs das lojas.
2. Criar uma unidade **Interstitial** para cada plataforma.
3. Em **Privacidade e mensagens**, publicar as mensagens necessárias para
   EEE/Reino Unido, estados dos EUA e demais regiões aplicáveis.
4. Guardar os IDs reais:
   - `ADMOB_APP_ID_ANDROID`: App ID Android, formato `ca-app-pub-...~...`.
   - `ADMOB_APP_ID_IOS`: App ID iOS, formato `ca-app-pub-...~...`.
   - `ADMOB_INTERSTITIAL_ANDROID`: unidade intersticial Android, formato
     `ca-app-pub-.../...`.
   - `ADMOB_INTERSTITIAL_IOS`: unidade intersticial iOS, formato
     `ca-app-pub-.../...`.
5. Gerar o build Android de produção com os IDs reais. O App ID Android já está
   configurado no projeto, mas também pode ser sobrescrito via `--dart-define`:

```sh
flutter build appbundle \
  --dart-define=ENABLE_ADS=true \
  --dart-define=USE_TEST_ADS=false \
  --dart-define=ADMOB_APP_ID_ANDROID=ca-app-pub-1922989446248337~2737556548 \
  --dart-define=ADMOB_INTERSTITIAL_ANDROID=ca-app-pub-1922989446248337/8307658981 \
  --dart-define=PREMIUM_PRODUCT_ID=chess_chalenges_pro_lifetime
```

6. Gerar o IPA com a unidade real. O App ID iOS já está configurado em
   `ios/Flutter/AdMob.xcconfig`:

```sh
flutter build ipa \
  --dart-define=ENABLE_ADS=true \
  --dart-define=USE_TEST_ADS=false \
  --dart-define=ADMOB_INTERSTITIAL_IOS=ca-app-pub-1922989446248337/9849759806 \
  --dart-define=PREMIUM_PRODUCT_ID=chess_chalenges_pro_lifetime
```

Enquanto `USE_TEST_ADS` não for `false`, o app usa unidades oficiais de teste
do Google e não gera receita. Isso evita tráfego inválido durante o
desenvolvimento. Em builds debug, anúncios ficam desligados por padrão; para
testá-los, execute com `--dart-define=ENABLE_ADS=true`.

## 5. Como o usuário vira PRO

1. O app consulta o produto na loja e mostra o preço na moeda do usuário.
2. O jogador toca em **Liberar PRO** e conclui o pagamento na interface oficial
   da Google Play ou Apple.
3. O fluxo de compra entrega o direito PRO, grava um cache local para uso
   offline e finaliza a transação na loja.
4. Em outro aparelho ou após reinstalar, o jogador toca em **Restaurar compra**
   usando a mesma conta da loja.

Para o lançamento inicial, o app reage ao evento de compra fornecido pelo SDK
da loja e mantém o direito em cache. Antes de vender conteúdo de alto valor,
implementar validação de recibos em backend e notificações de reembolso é a
evolução recomendada.

## 6. Checklist antes do envio

- Conferir que Android e iOS usam os IDs definitivos:
  `com.henriquemarinhoteixeira.chesschalenges`.
- Conferir os App IDs reais do AdMob:
  `ADMOB_APP_ID_ANDROID=ca-app-pub-1922989446248337~2737556548` e
  `ADMOB_APP_ID_IOS=ca-app-pub-1922989446248337~8830403163`.
- Informar as unidades de anúncio reais no build e desativar test ads.
- Criar e ativar exatamente o mesmo Product ID nas duas lojas.
- Configurar política de privacidade pública e o formulário UMP.
- Preencher a seção de segurança de dados da Play e privacidade da App Store.
- Testar compra, cancelamento, compra pendente e restauração nas faixas de teste.
- Configurar assinatura release do Android; o projeto ainda usa chave debug no
  bloco `release`.
