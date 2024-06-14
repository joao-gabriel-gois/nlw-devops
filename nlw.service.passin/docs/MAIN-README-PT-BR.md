# Sobre a NLW-Devops

Apesar de já possuir alguns conhecimentos relacionados principalmente ao Linux, Docker e Docker Compose e, em menor profundidade, do Github Actions, senti que seria interessante revisar e entender melhor a relação deles com ferramentas mais robustas de infraestrutura. Por isso, ao ver esse evento da Rocketseat, depois de anos sem participar, resolvi dar uma pausa no meu programa de estudos tradicional para concluir o evento semanal focado em DevOps e GitOps, para ver na prática o uso de ferramentas como Kubernetes, Terraform, Helm e Argo CD em conjunto com as anteriores.

Nesse evento, o foco foi a estruturação da automação de todo o processo de deploy da aplicação.

**Implementações:**

- [x] <s>Criação de um Dockerfile para preparar o container da aplicação</s>
- [x] <s>Adaptação do banco de dados da aplicação original (com SQLite) para o Postgres (provendo a versão de produção através do Terraform)</s>
- [x] <s>Criação de um docker-composer.yml para coordenar a subida dos containers da Aplicação e do Postgres, no ambiente local de desenvolvimento, já compartilhando uma rede e volume próprios.</s>
- [x] <s>Uso do kubernetes para orquestração de containers, passando por suas configurações mais básicas</s>
- [x] <s>Implementação de CI com Github Actions, que já builda a imagem no dockerhub e a atualiza a tag da imagem no Helm, para disparar o sync do Argo CD</s>
- [x] <s>Uso do terraform para provisão do banco de dados postgres de produçao, aplicando o básico dos conceitos de IaC (Infrastructure as Code). </s>

Os conceitos mais novos nesse projeto, no meu caso, são o uso do Kubernetes, Terraform, Helm e Argo CD (baseado em GitOps) e, por conta disso, segue uma sessão completa sobre o que aprendi de cada ferramenta, em termos gerais, abaixo.

### 1. Kubernetes

O Kubernetes é uma plataforma para a orquestração de containers, permitindo que se gerencie aplicações escaláveis e distribuídas de maneira otimizada. Com ele é possível escalar horizontal e verticalmente, controlar e automatizar o deploy e os rollbacks de uma aplicação composta por muitos microsserviços, distribuindo o tráfego e subindo ou matando dinamicamente os containers sob demanda. Os engenheiros que definem o estado desejado da distribuição da aplicação (por exemplo, quantos containers de cada serviço devem estar rodando), e o Kubernetes se encarrega de realizar esse estado, se ajustando automaticamente para lidar com erros ou falta de recursos. Além de cuidar do ciclo de vida, centraliza e gerencia configurações e os segredos. Resumindo, seus componentes são:

- **Control Plane** (Gerencia diversos nodes)
  - **API Server**: Ponto central de gerenciamento que expõe a API do Kubernetes.
  - **Scheduler**: Responsável por distribuir os containers entre os nós, decidindo em qual nó cada container deve ser executado, com base na disponibilidade de recursos e outros fatores.
  - **Controller Manager**: Executa controladores que regulam o estado do cluster, como o Replication Controller que mantém o número correto de cópias para cada pod.
  - **etcd**: Armazena a configuração do cluster e o estado.

- **Node**
  - **Kubelet**: Agente que executa em cada nó, garantindo que os containers estejam rodando em um Pod.
  - **Kube-proxy**: Gerencia o acesso à rede para os Pods, implementando regras de rede e permitindo a comunicação entre os Pods e ambientes externos.
  - **Container Runtime**: Software responsável por executar os containers, como Docker, containerd, etc.

- **Recursos**
  - **Pods**: Menor unidade que pode ser agendada, contém um ou mais containers que compartilham o mesmo contexto de rede e armazenamento.
  - **Deployments**: Gerencia o estado desejado para grupos de Pods, facilitando atualizações e rollbacks.
  - **Services**: Abstração que define um conjunto lógico de Pods e uma política de acesso a eles, fornecendo um IP fixo ou DNS.
  - **ConfigMaps** e **Secrets**: Utilizados para armazenar configurações e dados sensíveis, sem incluí-los diretamente nos arquivos de aplicação.

### 2. Terraform

Provisiona a infraestrutura através do código. Garante que todo o processo e configuração do provisionamento de um serviço em nuvem (aplicação, banco de dados, etc) seja formatado e protocolarizado. Desta maneira, não se depende de processos manuais na UI das plataformas e se mantém um padrão para todos os membros que se relacionam com a infraestrutura da aplicação para os serviços das quais ela depende. Neste caso, só usamos para subir um banco de dados Postgres remotamente, mas já dá pra entender o formato e o propósito da ferramenta, independente do provedor (apenas consultando os diferentes casos, configurações e provedores na documentação oficial a medida que novos casos de uso se impõem). 

### 3. Helm

O Helm permite gerenciarmos as configurações e valores especificados para nossos cluster kubernetes de maneira centralizada e "templatizada". Com ele podemos usar variáveis para manter uma mesma estrutura Kubernetes reusável mas com valores diferentes, tanto para casos de uso parecidos com cargas diferentes, como para novas decisões futuras da mesma aplicação uma vez que exija mais réplicas ou recursos. Imaginando, por exemplo, um caso onde dois clusters diferentes usam o mesmo formato de configuração mas que demandam valores, réplicas, specs e etc diferentes, poderíamos claramente reaproveitar templates e mudar apenas os valores e gerenciar as configurações do Kubernetes de uma maneira mais centralizada, dinâmica e controlada. Apesar disso, isso não automatiza a entrega do nosso Cluster e, portanto, precisamos de ferramentas como o Argo CD para poder distribuir e automatizar a entrega a partir das mudanças que ocorrem nos valores consumidos pelos templates fornecidos e facilitados pelo Helm.

### 4. Argo CD

Argo CD é um tipo de entrega contínua declarativa que segue o padrão GitOps. Mas...

  - **O que é Git Ops?**
  
    GitOps é uma metodologia para gerenciamento de infra e configurações de apps usando o Git. Em resumo, é uma prática de DevOps que usa Git como fonte única da verdade para infraestrutura declarativa e aplicações. O objetivo é atualizar e manter infraestruturas e aplicações de forma automatizada e replicável, tendo como gatilho novas versões commitadas no Git. Isso permite que equipes implementem práticas como revisão de código, controle de versão e integração contínua para gerenciamento de infraestrutura e deploy de aplicações.

  - **O que é Entrega Contínua?**

    Entrega Contínua (CD) é uma prática para realizar o deploy de aplicações em ciclos curtos, garantindo que as releases de um software possam ser lançadas a qualquer momento. O objetivo é construir, testar e lançar software com maior velocidade e frequência. A entrega contínua (CD) é uma extensão da integração contínua (CI), assegurando que se possa integrar e entregar novas mudanças aos usuários finais rapidamente e de maneira sustentável.

  - **Como o Argo CD nos ajuda a implementar ambos?**

    O Argo CD é uma ferramenta declarativa de CD para aplicações Kubernetes. Ele segue a filosofia do GitOps. Aqui estão algumas de suas características:

    - **Sincronização Automatizada**: O Argo CD monitora repositórios Git para mudanças nas configurações e automaticamente aplica essas mudanças no cluster Kubernetes. Isso garante que o estado do cluster sempre corresponda ao estado definido no Git.
    
    - **Gerenciamento Declarativo**: Utiliza arquivos YAML para definir o estado desejado de aplicações e infraestruturas, que o Argo CD usa para garantir que o ambiente de produção reflita exatamente o que está no repositório Git.
    
    - **Visualização e Controle**: Oferece uma interface de usuário e uma API que fornecem visibilidade em tempo real do estado de aplicações e serviços, facilitando o diagnóstico e o debugging.

    - **Integração com Ferramentas de CI**: Pode-se integrar facilmente com sistemas de Integração Contínua (CI) para automatizar o teste e a build antes de serem deployados por ele.

    - **Políticas e Segurança**: Implementa controles de acesso baseados em função (RBAC) e políticas para gerenciar quem pode fazer o quê, oferecendo um ambiente seguro e controlado.

  Ao integrar o Argo CD em seu workflow, se facilita a automação completa do processo de entrega de software, desde a build até o deployment, mantendo tudo sob controle de versão e revisão. 

___
## Pontos de atenção

Neste projeto, utilizamos um único repositório para fins de centralizar o código usado nesse  estudo, embora idealmente a aplicação deveria ter um repositório separado. Adaptamos a CI para detectar alterações e containerizar apenas o diretório específico da aplicação, porém, esse não é o cenário ideal, especialmente por complicar a referência ao repositório da aplicação nas configurações do Argo CD (`nlw.deploy.cross/apps/passin/*.yaml`). 

Para uma integração efetiva, o Argo CD deveria apontar para um repositório remoto da aplicação ou encontrar uma forma de referenciar o diretório da aplicação no mesmo repositório - o que não consegui fazer neste caso. Se houvesse um repositório isolado para a aplicação, os workflows do GitHub Actions (CI) estariam no diretório / repositório da aplicação Node.js. Ao adicionar o job 'Update Image tag' no arquivo `.github/workflows/ci.yml`, qualquer push na branch `main` da aplicação alteraria automaticamente a tag do último commit no Helm (`nlw.service.passin/deploy/values.yaml`), permitindo que o Argo CD detectasse a mudança e disparasse um novo ciclo de deploy.

Tendo isso em vista, o ciclo automatizado funciona da seguinte maneira: commits no repositório da aplicação acionam o CI, que constrói a nova imagem no Docker Hub. Em seguida, atualiza a tag da release no Helm e commita automaticamente no repositório remoto da aplicação. Observando essa mudança, o Argo CD iniciaria automaticamente o deploy da nova versão assim que sincronizasse.

Este experimento foi apenas testado localmente. Porém, durante o evento, também foi mencionado o uso do Eks da AWS para conexão à nuvem e deploy em produção, usando ferramentas como New Relic para observabilidade, mas esses pontos não foram aprofundados. Para realizar essa etapa, mudamos a configuração do Kubernetes de Cluster IP para Load Balancer para o exemplo de deploy em produção, embora o ideal seria usar o Ingress Kubernetes do AWS ALB para gerenciamento de carga e exposição à rede pública. Como não é o ideal e provisionamento do Cluster na Cloud não foi coberto aqui, mantive a configuração como Cluster IP.

___
## Notas:
### Descobertas importantes:

1. Em um projeto que utiliza o docker-compose e persiste dados do Postgres em um volume docker (stateful) para o ambiente de desenvolvimento, as migrations tendem a quebrar caso se renomeie o diretório raíz do projeto e se rode o `--build` novamente, já com novo nome de diretório. Nesse caso, sendo possível perder dados deste volume na máquina de desenvolvimento, é necessário remover o volume do docker com o comando `docker volume rm <nome-do-volume>`, antes de subir os containers com o comando `docker-compose up --build -d`. Ou remover todos os volumes, caso possa, com `docker volume rm $(docker volume ls -q)`. A descoberta foi de que a referência aos volumes do docker mantém uma relação com o nome da pasta raíz, para o estado do Postgres. Isso faz com que a reexecução das migrations do Prisma rodando por cima de um volume já criado com o estado anterior (antes de renomear a pasta raíz) gerem o erro: `P3009` / `UTC Failed`.

2. Ao seguir o modelo do curso e criar uma pasta anterior para separar a aplicação do código terraform voltado ao provisionamento, os workflows do Github Actions pararam de ser trigados. Para resolver, movi a pasta .github inteira para a raíz do projeto e mudei a config da pipeline da seguinte maneira:

    a. Inserindo um path para só disparar o workflow no caso de mudanças ocorrerem no diretório da aplicação Node:

    ```zsh
    $ git diff 21e8a664ec9ac112636c0fd8c6d9d6d4548701fa 1c0eb31309da69ea8f2b766afababcbb3ca265ba  

    @@ -4,6 +4,8 @@
    push:
      branches:
        - main
    + paths:
    +   - 'nlw.service.passin/**'

    ```

    b. Mudando a referência pro Dockerfile e diretório de contexto do comando `docker build`
  
    ```zsh
    $ git diff de9d8982cdf6b0a0ae4d9861fed9a17cf8a9c1a7 552a658a5915b9e757175b5c8aff5797b1e9c15f

    @@ -23,7 +23,7 @@
    -      run: docker build -t ${{ secrets.DOCKERHUB_USERNAME }}/nlw.service.passin:${{ steps.generate_sha.outputs.>sha }} .
    +      run: docker build -t ${{ secrets.DOCKERHUB_USERNAME }}/nlw.service.passin:${{ steps.generate_sha.outputs.>sha }} -f nlw.service.passin/Dockerfile nlw.service.passin
    ```

   OBS: Apesar disso, tudo indica que toda nossa config de IAC e CD não deveria conviver no mesmo repositório da aplicação, como informado anteriormente. Isso ocorre porque as configurações do Argo CD precisam referenciar a repo da aplicação diretamente para observar as mudanças e aplicar a sincronização.

## Aplicação usada
Utilizamos uma aplicação node já pré-criada para o estudo das ferramentas de infraestrutura. Mudamos apenas alguns pontos no arquivo de migration para adaptar ao Postgres (doc atualizada de acordo) e scripts do package.json para garantir que se execute as migrations antes de iniciar a aplicação. O README dessa aplicação pode ser encontrado **[aqui](PASSIN-README-PT-BR.md)**.