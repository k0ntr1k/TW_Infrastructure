# INFRASTRUCTURE (Backend)

## Kubernetes-based Solution

### Tools

#### **AWS** as a cloud provider
Amazon Web Services (AWS) is the world’s most comprehensive and broadly adopted cloud platform, offering over 200 fully featured services from data centers globally. Millions of customers—including the fastest-growing startups, largest enterprises, and leading government agencies—are using AWS to lower costs, become more agile, and innovate faster.

AWS has significantly more services, and more features within those services, than any other cloud provider–from infrastructure technologies like compute, storage, and databases–to emerging technologies, such as machine learning and artificial intelligence, data lakes and analytics, and Internet of Things. This makes it faster, easier, and more cost effective to move your existing applications to the AWS cloud and build nearly anything you can imagine.

AWS has the largest and most dynamic community, with millions of active customers and tens of thousands of partners globally.

With AWS, you can leverage the latest technologies to experiment and innovate more quickly. We are continually accelerating our pace of innovation to invent entirely new technologies you can use to transform your business.

AWS has 81 Availability Zones within 25 geographic regions around the world, and has announced plans for 27 more Availability Zones and 9 more AWS Regions in Australia, Canada, India, Indonesia, Israel, New Zealand, Spain, Switzerland, and United Arab Emirates (UAE).

- **AWS EKS** - Kubernetes on AWS

  Amazon Elastic Kubernetes Service (Amazon EKS) is a managed service that makes it easy for you to run Kubernetes on AWS without needing to install and operate your own Kubernetes clusters. Amazon EKS provides you with the tools to launch your own Kubernetes clusters, and Amazon EKS manages the lifecycle of those clusters, from creating and configuring the Kubernetes control plane to managing the Kubernetes worker nodes.
  Easy to deploy, Amazon EKS is designed to be highly available and resilient to failures.

- **AWS ECR** - Docker Registry

  Amazon Elastic Container Registry (Amazon ECR) is a managed Docker registry service that makes it easy to use Docker with applications hosted on AWS. Amazon ECR provides you with the tools to launch your own Docker registry, and Amazon ECR manages the lifecycle of those registries, from creating and configuring the registry to managing the registry and images within it.

- **AWS S3** - Storage for Tertaform State

  Amazon Simple Storage Service (Amazon S3) is storage for the internet. You can use Amazon S3 to store and retrieve any amount of data at any time, from anywhere on the web. Amazon S3 is the most popular storage service in the world.

#### **TERRAFORM** for deploying infrastructure into Cloud
  *Terraform* is one of the most popular infrastructure as code (IaC) tools available. It isn’t only one of the most active open-source projects, but it’s also cutting edge to the point that whenever AWS releases a new service. 
  Terraform is a declarative IaC software. That means admins declare what infrastructure they want, instead of worrying about the nitty-gritty of writing scripts to provision them. That makes Terraform extremely simple to learn and manage.
  It’s incredibly flexible and supports multiple cloud providers.

#### **DOCKER** on a local machine for building microservices as a Images for future deployments
  *Docker* - is a software framework for building, running, and managing containers on servers and the cloud.

#### **HELM** for deploying Services into AWS EKS
  *Helm* is a tool for managing Kubernetes clusters. It is a declarative tool that allows you to define Kubernetes resources in a YAML file and then apply those resources to a Kubernetes cluster.

### How to Build and Deploy
Please refer to the [README](/k8s-based_solution/ReadMe.md) file.

*-----------------------------------------------------------------------------------------------------------------------*

## VirtualMachines-based Solution
TBD: Description
