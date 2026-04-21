# Resumo do Deploy - UDrive Site

Este documento contém as informações essenciais sobre a configuração e o deploy do site UDrive no Google Cloud Platform.

## Informações do Projeto
- **ID do Projeto GCP:** `project-ef671036-8080-43e8-bd9`
- **Região:** `southamerica-east1` (São Paulo)
- **Serviço:** Cloud Run (`udrive-site`)
- **URL do Serviço:** [https://udrive-site-833430646448.southamerica-east1.run.app](https://udrive-site-833430646448.southamerica-east1.run.app)

## Infraestrutura e Configuração
O site é servido como um container estático usando **Nginx** no **Google Cloud Run**.

### Arquivos Principais:
- `Dockerfile`: Configura a imagem base `nginx:alpine` e copia a pasta `dist/`.
- `nginx.conf`: Configuração personalizada para o Nginx ouvir na porta `8080` (padrão do Cloud Run).
- `.gcloudignore`: Garante que a pasta `dist/` seja enviada para o Cloud Build (ignorando as restrições do `.gitignore`).

## Comandos de Deploy
Para realizar um novo deploy manual:

1. **Gerar o build local:**
   ```bash
   npm run build
   ```

2. **Fazer o deploy para o Cloud Run:**
   ```bash
   gcloud run deploy udrive-site --source . --region southamerica-east1 --allow-unauthenticated
   ```

## Ajustes Realizados (Troubleshooting)
Durante a configuração inicial, foram aplicadas as seguintes correções:

1. **Permissões IAM:** Foi concedido o papel de `roles/storage.admin` e `roles/artifactregistry.admin` para a conta de serviço `833430646448-compute@developer.gserviceaccount.com` para permitir que o Cloud Build processe o código-fonte.
2. **Correção do .gcloudignore:** Criado para evitar que a pasta `dist/` fosse ignorada durante o upload do código-fonte para o GCP.

## Próximos Passos Sugeridos
- Configurar o domínio customizado (`udriver.com.br`) no console do Cloud Run ou via Firebase Hosting.
- Configurar uma Pipeline de CI/CD (GitHub Actions) para automação do deploy.
