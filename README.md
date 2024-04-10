# Sobre a NLW-Devops

Apesar de já possuir alguns conhecimentos relacionados ao Linux, Docker, Docker Compose e Github Actions, senti que seria interessante revisar e entender melhor a relação deles com ferramentas mais robustas de infraestrutura. Por isso, ao ver esse evento da Rocketseat, resolvi dar uma pausa no meu programa de estudos tradicional para concluir o evento semanal e poder ver na prática o uso de ferramentas como Kubernetes e Terraform em conjunto com as anteriores.

Nesse evento, o foco foi a estruturação da automação de todo o processo de deploy da aplicação.

**Implementações:**

- [x] Criação de um Dockerfile para preparar o container da aplicação
- [x] Adaptação do banco de dados da aplicação original (com SQLite) para o Postgres
- [x] Criação de um docker-composer.yml para coordenar a subida dos containers da Aplicação e do Postgres, no ambiente local de desenvolvimento, já compartilhando uma rede e volume próprios.
- [ ] Implementação de CI com Github Actions
  - [ ] Desafio adicional: Implementar testes no app e incluir no CI, atualizar a doc do pass-in de acordo.
- [ ] Uso do kubernetes para orquestração de containers em Prod
- [ ] Uso do terraform para provisão da infra automatizada, ou seja, aplicação dos conceitos de IaC (Infrastructure as Code). 

### Pontos de atenção
1. Docker Compose só é utilizado pro ambiente de desenvolvimento. Por isso, para o CD, precisamos configurar um serviço na nuvem para o DB, o que é melhor para aplicações stateful.

### Descoberta importante:

Ao se renomear o diretório raiz de um projeto com docker-compose e persistência dos dados do Postgres em um volume docker, as migrations tendem a quebrar caso se rode o `--build` novamente, já com novo nome de diretório. Nesse caso, caso possa perder dados deste volume na máquina de desenvolvimento, é necessário remover o volume do docker com o comando `docker volume rm <nome-do-volume>`, antes de subir os containers com o comando `docker-compose up --build -d`. Ou remover todos os volumes, caso possa, com `docker volume rm $(docker volume ls -q)`.

A descoberta foi de que a referência aos volumes do docker mantém uma relação com o nome da pasta raíz, para o estado do Postgres. Isso faz com que a reexecução das migrations do Prisma rodando por cima de um estado anterior, após renomear a pasta do projeto (nlw-devops), gerem o erro: `P3009` / `UTC Failed`, caso o volume tenha sido criado antes e já se tenha executado migrations após sua criação. 

---

## Aplicação usada
Utilizamos uma aplicação node já pré-criada para o estudo das ferramentas de infraestrutura. Mudamos apenas alguns pontos no arquivo de migration para adaptar ao Postgres (doc atualizada de acordo) e scripts do package.json para garantir tanto que se execute as migrations antes de iniciar a aplicação. O README dessa aplicação pode ser encontrado **[aqui](nlw.service.passin/README.md)**.