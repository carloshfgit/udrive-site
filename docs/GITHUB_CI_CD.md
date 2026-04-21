# Configuração de CI/CD - GitHub Actions & Google Cloud

Este documento detalha a infraestrutura de Integração e Entrega Contínua (CI/CD) para o projeto **udrive-site**, utilizando Google Cloud Run e autenticação via Workload Identity Federation.

## 🚀 Visão Geral
O workflow automatiza o processo de:
1.  **Build**: Instala dependências e gera os arquivos estáticos (`npm run build`).
2.  **Autenticação**: Conecta com o Google Cloud de forma segura sem chaves JSON.
3.  **Deploy**: Faz o deploy automático para o Google Cloud Run no South America East 1 (São Paulo).

## 🔐 Autenticação: Workload Identity Federation (WIF)
Em vez de utilizar chaves JSON fixas (que são menos seguras), este projeto utiliza o **WIF**. Isso permite que o GitHub Actions troque um token de identidade de curta duração por credenciais do Google Cloud.

### Detalhes da Configuração no GCP:
- **Project ID**: `project-ef671036-8080-43e8-bd9`
- **Project Number**: `833430646448`
- **Workload Identity Pool**: `github-actions-pool`
- **Workload Identity Provider**: `github-actions-provider`
- **Service Account**: `github-actions-deploy@project-ef671036-8080-43e8-bd9.iam.gserviceaccount.com`

### Comandos de Configuração (gcloud):
Caso precise recriar a infraestrutura:

```bash
# 1. Criar o Pool
gcloud iam workload-identity-pools create "github-actions-pool" \
  --project="project-ef671036-8080-43e8-bd9" \
  --location="global" \
  --display-name="GitHub Actions Pool"

# 2. Criar o Provider OIDC
gcloud iam workload-identity-pools providers create-oidc "github-actions-provider" \
  --project="project-ef671036-8080-43e8-bd9" \
  --location="global" \
  --workload-identity-pool="github-actions-pool" \
  --display-name="GitHub Actions Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
  --attribute-condition="attribute.repository == 'carloshfgit/udrive-site'" \
  --issuer-uri="https://token.actions.githubusercontent.com"

# 3. Vincular a Conta de Serviço ao Pool
gcloud iam service-accounts add-iam-policy-binding "github-actions-deploy@project-ef671036-8080-43e8-bd9.iam.gserviceaccount.com" \
  --project="project-ef671036-8080-43e8-bd9" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/833430646448/locations/global/workloadIdentityPools/github-actions-pool/attribute.repository/carloshfgit/udrive-site"
```

## 🛠️ Configuração do Workflow
O arquivo de configuração está localizado em [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml).

### Requisitos no YAML:
Para que a autenticação funcione, o workflow **precisa** destas permissões:
```yaml
permissions:
  contents: read
  id-token: write
```

O passo de autenticação no workflow utiliza:
```yaml
- name: Google Auth
  uses: 'google-github-actions/auth@v2'
  with:
    workload_identity_provider: 'projects/833430646448/locations/global/workloadIdentityPools/github-actions-pool/providers/github-actions-provider'
    service_account: 'github-actions-deploy@project-ef671036-8080-43e8-bd9.iam.gserviceaccount.com'
```

## 📋 Como gerenciar permissões
A conta de serviço `github-actions-deploy` possui as seguintes permissões mínimas necessárias:
- `roles/run.admin`: Para gerenciar o serviço no Cloud Run.
- `roles/iam.serviceAccountUser`: Para usar a conta de serviço no deploy.
- `roles/cloudbuild.builds.editor`: Para realizar o build no servidor.
- `roles/storage.admin`: Para gerenciar artefatos de build no Cloud Storage.
- `roles/artifactregistry.admin`: Para gerenciar imagens no Artifact Registry.

## 🛡️ Segurança
- **Sem Segredos Expostos**: Não há arquivos `.json` de credenciais no repositório ou no ambiente local.
- **Acesso Restrito**: O Google Cloud só aceita conexões vindas especificamente do repositório `carloshfgit/udrive-site`.

---
*Atualizado em: 21 de Abril de 2026*
