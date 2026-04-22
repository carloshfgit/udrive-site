# Plano de Configuração de Domínio: udriver.com.br

Este plano descreve os passos necessários para mapear seu novo domínio da Hostinger para o serviço `udrive-site` rodando no Google Cloud Run (na região `us-central1`).

## 1. Verificação de Propriedade do Domínio
Para que o Google permita que você use o domínio, você precisa provar que é o dono dele.

1. Acesse o [Google Search Console](https://search.google.com/search-console/welcome).
2. Adicione a propriedade `udriver.com.br`.
3. Escolha o método de verificação por **Registro TXT de DNS**.
4. Copie o valor do registro TXT fornecido.
5. No painel da **Hostinger**:
   - Vá em **DNS / Nameservers**.
   - Adicione um novo registro:
     - **Tipo**: `TXT`
     - **Nome**: `@` (ou deixe vazio)
     - **Valor**: (Cole o valor que você copiou do Google)
     - **TTL**: `3600`
6. Volte ao Google Search Console e clique em **Verificar**.

## 2. Mapeamento no Cloud Run
Após verificar o domínio, precisamos dizer ao GCP para direcionar o tráfego para seu site.

1. No Console do GCP, vá para **Cloud Run**.
2. Clique no serviço `udrive-site`.
3. Clique em **Gerenciar Domínios Personalizados** (ou vá em Mapeamentos de Domínio).
4. Clique em **Adicionar Mapeamento**.
5. Selecione o serviço `udrive-site`.
6. Digite `udriver.com.br`.
7. O Google fornecerá uma lista de registros DNS (geralmente 4 registros **A** e 4 registros **AAAA**).

## 3. Configuração final na Hostinger
Agora, você deve inserir os endereços IP do Google no seu domínio.

1. No painel da **Hostinger** (DNS / Nameservers):
2. Remova os registros `A` existentes que apontam para a Hostinger (se houver).
3. Adicione os novos registros fornecidos pelo Cloud Run:
   - **Registros A**: Crie 4 registros com o nome `@` apontando para os 4 IPs fornecidos.
   - **Registros AAAA**: Crie 4 registros com o nome `@` apontando para os 4 endereços IPv6 fornecidos.
4. (Opcional) Repita o processo para `www.udriver.com.br` se desejar.

> [!IMPORTANT]
> A região do serviço deve ser `us-central1` (ou outra suportada) para que a opção de Mapeamento de Domínio apareça no console.
>
> A propagação do DNS pode levar de alguns minutos até 24 horas. O certificado SSL (HTTPS) será gerado automaticamente pelo Google assim que o DNS estiver apontando corretamente.
