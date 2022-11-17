# CI/CD Pipelines to deploy AWS Infrastructure Using Terraform. 
## Github Actions-- Terraform Cloud - AWS

![Applaudo.png](https://i.postimg.cc/Kc5J8TGf/Applaudo.png)


The operative approach of 
    
The new objective is to understand all the processes associated to the serverless infrastructure creation in AWS using Terraform and Github actions to help us with the CI stage of software deployment. This will be achieved through the creation of a simple Serverless application that collects the data registries for a data base and delivers back the information using a simple postman query; this app makes use of some basic AWS resources:

![Diagram.png](https://i.postimg.cc/nz2pMhhZ/Diagram.png)

### *Logical Resources*

-API Gateway: This resource will be the front door to access the application, handling the incoming and outgoing information, and of course taking care of the functionality and business logic making use of typical API calls.

-Lambda Functions: this resource allows the user to deploy application with no provisioning or mantainig any permanent server, is is basically an on-demand server service which function or features are given in JavaScript in this case. This app will deploy two lambdas, one of them is in charge of writing basic registries in a data base and the other one will read and bring the information of each registry in JSON format.

-Dynamo DB: this service is basically a non-relational database which will store all the registries imported by the writing lambda and keep them permanently for its later consultation.

###  *Platforms and Services*

-Terraform: is the IaC software selected to generate the necessary code to create Resources, Roles, Permissions and Pipelines into AWS

-Terraform Cloud: it is a Hashicorp's service tool used to provision infrastructure into AWS from remote servers using terraform workflows.

-Github Actions: CI tool provided by Github to automate the revision, validation and exportation of source code to Terraform Cloud to be later deployed into AWS.


## Deployment Steps

- Create a directory in your GIT bash or Linux terminal where you can deploy and clone the repository:

```sh
https://github.com/renzzog777/Serverless.git
```

- Assuming you already have GIT installed on your machine, you have to initialize the Gitflow method on GIT with this comand:

```sh
git flow init
```
Follow the suggested configuration by default until the end.

- The following step is to create a new Feature branch, you'll use this branch apply all the necessary cahnge to the source code. To create it, enter this command of Git Flow:
```sh
git flow feature start feature_branch
```
Replace the text "feature_branch" for a custom name skipping the "feature" prefix.

- Check  out to the new created branch and perform all the necessary changes in the source code of the lambda functions hosted in the repo under the name of readterra.js and writeterra.js, or maybe if you want to apply enay change to the infra code you can modify the file main.tf 

- At this point it is necessary to create an accoutn in Terraform Cloud to send our terraform worflow to. These are the basic fields you have to configure:
 ```sh
 - API Token: Basic Terraform Cloud user token ("To be configured in Github as a secret also")
 - AWS Access Key ID: Provided when creating a user in AWS ("To be configured in Github as a secret also")(env sensitive variable)
 - AWS  secret access key: Provided when creating a user in AWS ("To be configured in Github as a secret also")(env sensitive variable)
 ```
- You should create an API-Based workspace and link the Version Control source to the workspace to set it up as the main source.

- After that, perform all the regular GIT command to commit and push the changes into the feature remote branch of the repository.

```sh
git add .
git commit -m "Message"
git push origin feature/"created branch"
```


- Github will request for the repository token, these are the credentials (Token is coded in base 64):

```sh
User: renzzog777
token: 'Z2hwX2Eyc3BxRkl6OXdOV1RUNk9heE14dXpNTDRaTXE4ZDMzSUdLQQ=='
```
You can decode the token with the following command:
```sh
echo 'given coded token' | base64 --decode
```

- The changes will be automatically upload into the remote 'develop' branch. Under the "actions" tab you must see a message like this: 

![automerge.png](https://i.postimg.cc/VLXxWg88/automerge.png)

This lets you know that feature branch  is merging into develop branch. 

- As in real production environments, the repository admin will receive a pull-request, if everything's ok, he/she will accept it and merge 'develop' branch and 'master' branch with a couple of clicks.

Once they are merged, all the cahanges will rest in the master branch which is our default branch for releases and deployment.

- Now another workflow comes into action to validate, plan and apply the terraform configuration inside the repo and later on this configuration will be uploaded into our Terraform Cloud workspace to be applied into AWS. you can find this workflow in .github/workflows/Apply.yml.


- Once it is done, we can go to our Terraform Cloud workspace to verify on the "runs" tab if the plan and apply processes were succesfull, the message must show something like this:

![TC_Process.png](https://i.postimg.cc/CxcLJBxn/TC-Process.png)

- After that, all th infrastructure and functions will be created into AWS and we'll be able to visualize all the information and graphic content inside the AWS console:

![functions.png](https://i.postimg.cc/P5VvJFZ7/Functions.png)
The reading and writing lambda functions were created

![dockerrun.png](https://i.postimg.cc/8P17HVm3/Lambda.png)
We can verify the graphic diagram in the Lambda resource dashboard

- Subsequently it is necessary to check th URL's of our API endpoints to perform connection and functionality tests using postman to write an read registries from the DynamoDB tables. You can click on the API Gateway icon in the Lmnbdas dashboard to coy and paste the URL's

![APIGateway.png](https://i.postimg.cc/pV9vMcXT/API-Gateway.png)

- This are the correspondant URL's associated to our API endpoints:

```sh
Read Function Lambda:
https://9j4f24eqmh.execute-api.us-west-2.amazonaws.com/Prod/readdb

Write Function Lambda: 
https://9j4f24eqmh.execute-api.us-west-2.amazonaws.com/Prod/writedb

```
- For performing the writing feature we must use the correct data format according to the structure given in the function file writeterra.js:

![APIGateway.png](https://i.postimg.cc/bvjrZcr3/data-structure-general.png)

The correct format to write a registry in the database using postman  would be:

```sh
{"id":"1","name":"Renzzo"}
```
![APIGateway.png](https://i.postimg.cc/26Y7CKnZ/write-postman.png)

And for reading (query the registry):

```sh
{"id":"1"}
```
![APIGateway.png](https://i.postimg.cc/XNk4NB6G/read-postman.png)

After getting this succesfull messages we can verify that the API gateway endpoints are routing the data correctly and also that the lambda functions are operating accordingly to what they are suposed to do. It is possible to prove that the terraform code is working properly as well. Of course there are a lot of fields and items that should be customized when cloning this repository but they have to be examined manually by the user.


## Workflows

| File  | Action |
| ------ | ------ |
| Auto_Merge.yml | Detects PR's in the feature branch and merges with the 'develop' branch|
| Master.yml | Sends the PR to the repo for authorization, and merges 'develop' and 'master' later |
| Apply.yml | Checks the Terraform code and performs a basic terraform workflow, after, sends it to Terraform cloud to be deployed |



## Author

Renzzo Gomez Reatiga
AWS DevOps- Trainnee.

Applaudo Studios

**rgomez@applaudostudios.dev**
