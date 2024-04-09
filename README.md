# Sobre a NLW-Devops

Apesar de já possuir alguns conhecimentos relacionados ao Linux, Docker, Docker Compose e Github Actions, senti que seria interessante revisar e entender melhor a relação deles com ferramentas mais robustas de infraestrutura. Por isso, ao ver esse evento da Rocketseat, resolvi dar uma pausa no meu programa de estudos tradicional para concluir o evento semanal e poder ver na prática o uso de ferramentas como Kubernetes e Terraform em conjunto com as anteriores.

Nesse evento, o foco foi a estruturação da automação de todo o processo de deploy da aplicação. Até agora, foram feitas as seguintes atividades:

- [x] Criação de um Dockerfile para preparar o container da aplicação
- [x] Adaptação do banco de dados da aplicação original (com SQLite) para o Postgres
- [x] Criação de um docker-composer.yml para coordenar a subida dos containers da Aplicação e do Postgres, no ambiente local de desenvolvimento, já compartilhando uma rede e volume próprios.
- [ ] Implementação de CI/CD com Github Actions
- [ ] Uso do kubernetes para orquestração de containers em Prod
- [ ] Uso do terraform para provisão da infra automatizada, ou seja, aplicação dos conceitos de IaC (Infrastructure as Code). 

## Descoberta importante:

Ao se renomear o diretório raiz de um projeto com docker-compose e persistência dos dados do Postgres em um volume docker, as migrations tendem a quebrar caso se rode o `--build` novamente, já com novo nome de diretório. Nesse caso, caso possa perder dados deste volume na máquina de desenvolvimento, é necessário remover o volume do docker com o comando `docker volume rm <nome-do-volume>`, antes de subir os containers com o comando `docker-compose up --build -d`. Ou remover todos os volumes, caso possa, com `docker volume rm $(docker volume ls -q)`.

A descoberta foi de que a referência aos volumes do docker mantém uma relação com o nome da pasta raíz, para o estado do Postgres. Isso faz com que a reexecução das migrations do Prisma rodando por cima de um estado anterior, após renomear a pasta do projeto (nlw-devops), gerem o erro: `P3009` / `UTC Failed`, caso o volume tenha sido criado antes e já se tenha executado migrations após sua criação. 

---

## Sobre a Aplicação Usada (pass.in)
_(já pronta para o evento)_

O pass.in é uma aplicação de **gestão de participantes em eventos presenciais**. 

A ferramenta permite que o organizador cadastre um evento e abra uma página pública de inscrição.

Os participantes inscritos podem emitir uma credencial para check-in no dia do evento.

O sistema fará um scan da credencial do participante para permitir a entrada no evento.

## Requisitos

### Requisitos funcionais

- [x] O organizador deve poder cadastrar um novo evento;
- [x] O organizador deve poder visualizar dados de um evento;
- [x] O organizador deve poser visualizar a lista de participantes; 
- [x] O participante deve poder se inscrever em um evento;
- [x] O participante deve poder visualizar seu crachá de inscrição;
- [x] O participante deve poder realizar check-in no evento;

### Regras de negócio

- [x] O participante só pode se inscrever em um evento uma única vez;
- [x] O participante só pode se inscrever em eventos com vagas disponíveis;
- [x] O participante só pode realizar check-in em um evento uma única vez;

### Requisitos não-funcionais

- [x] O check-in no evento será realizado através de um QRCode;

## Documentação da API (Swagger)

Para documentação da API, acesse o link: https://nlw-unite-nodejs.onrender.com/docs

## Banco de dados

Nessa aplicação vamos utilizar banco de dados relacional (SQL). Para ambiente de desenvolvimento seguiremos com o SQLite pela facilidade do ambiente.

### Diagrama ERD

<img src=".github/erd.svg" width="600" alt="Diagrama ERD do banco de dados" />

### Estrutura do banco (SQL)

```sql
CREATE TABLE "events" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "title" TEXT NOT NULL,
    "details" TEXT,
    "slug" TEXT NOT NULL,
    "maximum_attendees" INTEGER
);

CREATE TABLE "attendees" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "event_id" TEXT NOT NULL,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "attendees_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "events" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE "check_ins" (
    "id" serial NOT NULL PRIMARY KEY,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "attendeeId" TEXT NOT NULL,
    CONSTRAINT "check_ins_attendeeId_fkey" FOREIGN KEY ("attendeeId") REFERENCES "attendees" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE UNIQUE INDEX "events_slug_key" ON "events"("slug");
CREATE UNIQUE INDEX "attendees_event_id_email_key" ON "attendees"("event_id", "email");
CREATE UNIQUE INDEX "check_ins_attendeeId_key" ON "check_ins"("attendeeId");
```