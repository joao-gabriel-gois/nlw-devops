# About NLW-Devops

<sup style="font-family:Calibri Ubuntu Arial;color=#666">You can find the brazilian portuguese version of this very same doc <u><b style="font-size:9.5pt">[here](nlw.service.passin/docs/MAIN-README-PT-BR.md)</b></u></sup>

Although I already have some knowledge related mainly to Linux, Docker, and Docker Compose, and to a lesser extent, Github Actions, I felt it would be interesting to review and better understand their relationship with more robust infrastructure tools. Therefore, upon seeing this Rocketseat event, after years without participating, I decided to take a break from my traditional study program to complete the weekly event focused on DevOps and GitOps, to see the practical use of tools like Kubernetes, Terraform, Helm, and Argo CD in conjunction with the previous ones.

In this event, the focus was on structuring the automation of the entire application deployment process.

**Implementations:**

- [x] <s>Creation of a Dockerfile to prepare the application container</s>
- [x] <s>Adaptation of the original application database (using SQLite) to Postgres (providing the production version through Terraform)</s>
- [x] <s>Creation of a docker-compose.yml to coordinate the launch of the Application and Postgres containers in the local development environment, already sharing a network and own volume</s>
- [x] <s>Use of Kubernetes for container orchestration, going through its basic configurations</s>
- [x] <s>Implementation of CI with Github Actions, which builds the image in Dockerhub and updates the image tag in Helm to trigger the sync of Argo CD</s>
- [x] <s>Use of Terraform to provision the production Postgres database, applying the basic concepts of IaC (Infrastructure as Code).</s>

The newest concepts in this project, for me, are the use of Kubernetes, Terraform, Helm, and Argo CD (based on GitOps) and, therefore, a complete session on what I learned about each tool, in general terms, follows below.

### 1. Kubernetes

Kubernetes is a platform for container orchestration, allowing the management of scalable and distributed applications in an optimized way. It enables horizontal and vertical scaling, controlling and automating the deployment and rollbacks of an application composed of many microservices, distributing traffic, and dynamically launching or killing containers on demand. Engineers define the desired state of the application distribution (e.g., how many containers of each service should be running), and Kubernetes takes care of realizing this state, automatically adjusting to handle errors or resource shortages. Besides managing the lifecycle, it centralizes and manages configurations and secrets. In summary, its components are:

- **Control Plane** (Manages multiple nodes)
  - **API Server**: Central management point that exposes the Kubernetes API.
  - **Scheduler**: Responsible for distributing containers among nodes, deciding on which node each container should run based on resource availability and other factors.
  - **Controller Manager**: Runs controllers that regulate the state of the cluster, such as the Replication Controller that maintains the correct number of copies for each pod.
  - **etcd**: Stores the cluster configuration and state.

- **Node**
  - **Kubelet**: Agent that runs on each node, ensuring that containers are running in a Pod.
  - **Kube-proxy**: Manages network access for Pods, implementing network rules and enabling communication between Pods and external environments.
  - **Container Runtime**: Software responsible for running the containers, such as Docker, containerd, etc.

- **Resources**
  - **Pods**: The smallest unit that can be scheduled, containing one or more containers that share the same network and storage context.
  - **Deployments**: Manages the desired state for groups of Pods, facilitating updates and rollbacks.
  - **Services**: Abstraction that defines a logical set of Pods and a policy for accessing them, providing a fixed IP or DNS.
  - **ConfigMaps** and **Secrets**: Used to store configurations and sensitive data, without including them directly in the application files.

### 2. Terraform

Provisions infrastructure through code. It ensures that the entire process and configuration of provisioning a cloud service (application, database, etc.) is formatted and protocolized. This way, it does not depend on manual processes in the platform UI and maintains a standard for all members related to the application infrastructure and the services it depends on. In this case, we only used it to launch a remote Postgres database, but it is enough to understand the format and purpose of the tool, regardless of the provider (just consulting the different cases, configurations, and providers in the official documentation as new use cases arise).

### 3. Helm

Helm allows us to manage the configurations and specified values for our Kubernetes cluster in a centralized and templated manner. With it, we can use variables to maintain the same reusable Kubernetes structure but with different values, both for similar use cases with different loads and for new future decisions of the same application once it requires more replicas or resources. For example, if two different clusters use the same configuration format but demand different values, replicas, specs, etc., we could clearly reuse templates and change only the values, managing the Kubernetes configurations in a more centralized, dynamic, and controlled way. However, this does not automate the delivery of our Cluster, and therefore, we need tools like Argo CD to distribute and automate the delivery based on the changes that occur in the values consumed by the templates provided and facilitated by Helm.

### 4. Argo CD

Argo CD is a type of declarative continuous delivery that follows the GitOps pattern. But...

  - **What is GitOps?**
  
    GitOps is a methodology for managing infrastructure and app configurations using Git. In summary, it is a DevOps practice that uses Git as the single source of truth for declarative infrastructure and applications. The goal is to update and maintain infrastructures and applications in an automated and replicable way, with new versions committed to Git as the trigger. This allows teams to implement practices such as code review, version control, and continuous integration for infrastructure management and application deployment.

  - **What is Continuous Delivery?**

    Continuous Delivery (CD) is a practice for deploying applications in short cycles, ensuring that software releases can be launched at any time. The goal is to build, test, and release software faster and more frequently. Continuous Delivery (CD) is an extension of Continuous Integration (CI), ensuring that new changes can be integrated and delivered to end-users quickly and sustainably.

  - **How does Argo CD help us implement both?**

    Argo CD is a declarative CD tool for Kubernetes applications. It follows the GitOps philosophy. Here are some of its features:

    - **Automated Synchronization**: Argo CD monitors Git repositories for changes in configurations and automatically applies those changes to the Kubernetes cluster. This ensures that the cluster state always matches the state defined in Git.
    
    - **Declarative Management**: Uses YAML files to define the desired state of applications and infrastructures, which Argo CD uses to ensure that the production environment reflects exactly what is in the Git repository.
    
    - **Visualization and Control**: Offers a user interface and an API that provide real-time visibility into the state of applications and services, making diagnosis and debugging easier.

    - **Integration with CI Tools**: Can easily integrate with Continuous Integration (CI) systems to automate testing and building before they are deployed by it.

    - **Policies and Security**: Implements role-based access controls (RBAC) and policies to manage who can do what, offering a secure and controlled environment.

  By integrating Argo CD into your workflow, you facilitate the complete automation of the software delivery process, from build to deployment, keeping everything under version control and review.

___
## Points of Attention

In this project, we used a single repository to centralize the code used in this study, although ideally, the application should have a separate repository. We adapted the CI to detect changes and containerize only the specific application directory, but this is not the ideal scenario, especially as it complicates the reference to the application repository in the Argo CD configurations (`nlw.deploy.cross/apps/passin/*.yaml`).

For effective integration, Argo CD should point to a remote application repository or find a way to reference the application directory in the same repository - which I could not do in this case. If there were a separate repository for the application, the GitHub Actions (CI) workflows would be in the application directory/repository. By adding the 'Update Image tag' job in the `.github/workflows/ci.yml` file, any push to the `main` branch of the application would automatically change the last commit tag in Helm (`nlw.service.passin/deploy/values.yaml`), allowing Argo CD to detect the change and trigger a new deployment cycle.

With this in mind, the automated cycle works as follows: commits to the application repository trigger the CI, which builds the new image on Docker Hub. It then updates the release tag in Helm and automatically commits to the remote application repository. Observing this change, Argo CD would automatically initiate the deployment of the new version as soon as it synchronizes.

This experiment was only tested locally. However, during the event, the use of AWS Eks for cloud connection and production deployment was also mentioned, using tools like New Relic for observability, but these points were not deepened. To accomplish this step, we changed the Kubernetes configuration from Cluster IP to Load Balancer for the production deployment example, although the ideal would be to use the AWS ALB Kubernetes Ingress for load management and public network exposure. Since this is not ideal and the provision of the Cluster in the Cloud was not covered here, I kept the configuration as Cluster IP.

___
## Notes:
### Important Discoveries:

1. In a project that uses docker-compose and persists Postgres data in a docker volume (stateful) for the development environment, migrations tend to break if the root directory of the project is renamed. To fix this, since it is possible to lose data from this volume on the development machine, it is necessary to remove the docker volume with the command `docker volume rm <volume-name>` before launching the containers with the command `docker-compose up --build -d`. Or remove all volumes if possible with `docker volume rm $(docker volume ls -q)`. The discovery was that the reference to docker volumes maintains a relationship with the root folder name for the Postgres state. This causes re-running Prisma migrations over an already created volume with the previous state (before renaming the root folder) to generate the error: `P3009` / `UTC Failed`.

2. Following the course model and creating a previous folder to separate the application from the terraform code aimed at provisioning, the Github Actions workflows stopped being triggered. To resolve this, I moved the .github folder to the project root and changed the pipeline configuration as follows:

    a. Inserting a path to only trigger the workflow in case of changes in the Node application directory:

    ```zsh
    $ git diff 21e8a664ec9ac112636c0fd8c6d9d6d4548701fa 1c0eb31309da69ea8f2b766afababcbb3ca265ba  

    @@ -4,6 +4,8 @@
    push:
      branches:
        - main
    + paths:
    +   - 'nlw.service.passin/**'

    ```

    b. Changing the reference to the Dockerfile and the context directory of the `docker build` command
  
    ```zsh
    $ git diff de9d8982cdf6b0a0ae4d9861fed9a17cf8a9c1a7 552a658a5915b9e757175b5c8aff5797b1e9c15f

    @@ -23,7 +23,7 @@
    -      run: docker build -t ${{ secrets.DOCKERHUB_USERNAME }}/nlw.service.passin:${{ steps.generate_sha.outputs.sha }} .
    +      run: docker build -t ${{ secrets.DOCKERHUB_USERNAME }}/nlw.service.passin:${{ steps.generate_sha.outputs.sha }} -f nlw.service.passin/Dockerfile nlw.service.passin
    ```

   NOTE: Despite this, everything indicates that our entire IAC and CD config should not coexist in the same application repository, as mentioned earlier. This occurs because Argo CD configurations need to reference the application repo directly to observe changes and apply synchronization.

## Application Used
We used a pre-created Node application for the study of infrastructure tools. We only changed a few points in the migration file to adapt to Postgres (documentation updated accordingly) and scripts in the package.json to ensure that migrations are executed before starting the application. The README of this application can be found **[here](nlw.service.passin/README-EN.md)**.
