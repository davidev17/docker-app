CI/CD Pipeline com GitHub Actions e Terraform

Este repositório contém a configuração necessária para automatizar a construção, publicação e implantação de uma aplicação Node.js Dockerizada utilizando GitHub Actions e Terraform.

Índice

Visão Geral

Workflow do GitHub Actions

Explicação do Dockerfile

Iniciando a Aplicação Localmente

Implantação com Terraform

Explicação do Código da Aplicação

Como Usar

Visão Geral

Este projeto demonstra o uso de pipelines CI/CD para automatizar o processo de construção, publicação de imagens Docker e implantação de contêineres em uma infraestrutura em nuvem. O workflow garante uma experiência de desenvolvimento e implantação simplificada.

Workflow do GitHub Actions

O workflow do GitHub Actions é dividido em dois jobs:

CI (Continuous Integration)

Constrói a imagem Docker e a publica no Docker Hub.

ame: CI-CD

on:
  push:
    branches: ["main"]

jobs:
  CI:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4.2.2

      - name: Autenticação no Docker Hub
        uses: docker/login-action@v3.3.0
        with:
          username: ${{secrets.DOCKERHUB_USER}}
          password: ${{secrets.DOCKERHUB_PWD}}

      - name: Construir e Publicar Imagem Docker
        uses: docker/build-push-action@v6.12.0
        with:
          context: .
          file: ./Dockerfile
          push: true
          tags: |
            inter171991/app:${{github.run_number}}
            inter171991/app:latest

  CD:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4.2.2

Explicação do Dockerfile

O Dockerfile define os passos para criar um contêiner leve e pronto para produção da aplicação Node.js:

FROM node:18-alpine
WORKDIR /app
COPY . .
RUN apk add --no-cache python3 g++ make
RUN yarn install --production
CMD ["node", "src/index.js"]
EXPOSE 3000

Principais Etapas:

Imagem Base: Utiliza a imagem oficial do Node.js 18 otimizada para Alpine Linux.

Diretório de Trabalho: Define /app como o diretório de trabalho dentro do contêiner.

Copiar Arquivos: Copia todos os arquivos do host para o contêiner.

Instalação de Dependências: Instala as dependências necessárias para a aplicação.

Comando de Inicialização: Especifica node src/index.js como o comando para iniciar a aplicação.

Exposição de Porta: Expõe a porta 3000 para comunicação externa.

Iniciando a Aplicação Localmente

Para testar a aplicação localmente, siga os passos abaixo:

Construir a Imagem Docker:

docker build -t my-node-app .

Executar o Contêiner Docker:

docker run -d -p 3000:3000 my-node-app

Acessar a Aplicação:

Abra um navegador ou use uma ferramenta como curl para acessar:

http://localhost:3000

Implantação com Terraform

A configuração do Terraform é projetada para implantar o contêiner Docker em uma infraestrutura em nuvem. A variável principal image_tag seleciona dinamicamente a imagem mais recente do Docker Hub:

variable "image_tag" {
  description = "Tag da imagem Docker a ser usada"
  type        = string
  default     = "latest"
}

Certifique-se de que o Terraform está configurado corretamente, definindo o backend e o provider para o seu ambiente em nuvem. Implante a infraestrutura usando:

terraform init
terraform apply -var="image_tag=latest"

Explicação do Código da Aplicação

O arquivo src/index.js define a aplicação backend utilizando Express.js:

const express = require('express');
const app = express();
const db = require('./persistence');
const getItems = require('./routes/getItems');
const addItem = require('./routes/addItem');
const updateItem = require('./routes/updateItem');
const deleteItem = require('./routes/deleteItem');

app.use(express.json());
app.use(express.static(__dirname + '/static'));

app.get('/items', getItems);
app.post('/items', addItem);
app.put('/items/:id', updateItem);
app.delete('/items/:id', deleteItem);

db.init().then(() => {
    app.listen(3000, () => console.log('Listening on port 3000'));
}).catch((err) => {
    console.error(err);
    process.exit(1);
});

const gracefulShutdown = () => {
    db.teardown()
        .catch(() => {})
        .then(() => process.exit());
};

process.on('SIGINT', gracefulShutdown);
process.on('SIGTERM', gracefulShutdown);
process.on('SIGUSR2', gracefulShutdown); // Enviado pelo nodemon

Como Usar

Clone este repositório.

Configure os Segredos do GitHub para credenciais do Docker Hub.

Atualize as variáveis do Terraform conforme necessário.

Dispare um Action no GitHub para construir e publicar a imagem Docker.

Implante a aplicação usando Terraform.

Para testar localmente, construa e rode a imagem Docker conforme descrito acima.

Para dúvidas ou contribuições, sinta-se à vontade para criar uma issue ou um pull request!

