# Creating a Rest API with Infrastructure as Code (Tofu) and Lambda + Typescript

## Deploying an API with Typescript in minutes instead of days

Deploying to production is becoming easier every day. Best practices and tools are available to us to create software that eventually contributes to automating tedious tasks, creating new businesses and startups, and ultimately generating value for society 🌎.

## Deployment Anti-Patterns 🙅🏻‍♂️

- Manually created infrastructure
- Deploying at specific times due to lack of technical capacity (production errors, unstable software, service unavailability) rather than business decisions
- Having to send emails to another team for deployment
- Branches like "development" that differ from what exists in "main" and sometimes generate conflicts during merging
- Manual testing
- Tickets for deployment

All the points mentioned above, along with excessive bureaucracy, committees, and meetings, are still the norm in many organizations, and it was my reality for many years. But there is an alternative, a way of seeing the software development process where **simplicity is key**, both in deployments with pipelines and automation, and in the creation of software, where the focus should be on reducing accidental complexity, building modular, testable applications that are easy to understand for the team.

## A Brighter Future 💻

- Unit and Integration testing
- Trunk-based development
- AI, ChatGPT, Copilot
- DevOps as a mindset, not just a role
- Infrastructure as code
- Serverless and containers
- REST, SOAP, GraphQL, gRPC

The purpose of this post is to showcase an essential how to create an API with Typescript and Tofu (or Terraform).

## Let's talk about the code!

**Code on GitHub:** [tofu-typescript](https://github.com/jorgetovar/tofu-typescript)

### Project Structure 🏭


![Project structure](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/zjl4to5af9q6n694h3wp.png)


The following files are typical in a Tofu project, and this is the convention we are using in this project.

- *main.tf* - Entry point for Terraform
- *variables.tf* - Input variables
- *terraform.tfvars* - Variable definition file
- *providers.tf* - Provider declarations
- *outputs.tf* - Output values
- *versions.tf* - Provider version locking

### Why Tofu ☁️

- Open source
- Multi-cloud
- Immutable infrastructure
- Declarative paradigm
- Domain-specific language (DSL)
- Does not require agents or master nodes
- Free
- Large community
- Mature software

### Why Serverless and Typescript 

- Automatic scalability
- Pay-per-use
- High availability
- Easy development and deployment
- Type Safety
- Better documentation
- Enhanced developer experience 
- Integration with managed services

### Code

**Lambda:** The code for a Lambda function should generally be simple and adhere to the single responsibility principle or reason to change. The name of the method should correspond to the entry point defined in the Tofu code.

**Types** help document the code and provide better IDE support.

```Typescript
import {APIGatewayProxyEvent, APIGatewayProxyResult} from 'aws-lambda';

export const lambdaHandler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
    console.log(event.body);
    try {
        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                message: 'Hello World from Typescript + Tofu!',
            }),
        };
    } catch (err) {
        console.log(err);
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                message: 'Error processing request',
            }),
        };
    }
};

```

**.gitignore:** Definition of files that we do not want to add to the repository. It is crucial not to publish AWS credential information.

```terraform
# Terraform-specific files
.terraform/
terraform.tfstate
terraform.tfstate.backup
*.tfvars

hello_world.zip
response.json
.layer
layer.zip

# AWS credentials file
.aws/credentials
```

**Lambda Resources:** Configures the Lambda module to retrieve the source code from a bucket also created by Tofu, and we define `lambdaHandler` as the method that will receive and process the API event.

**Modules** are the key ingredient for writing reusable, maintainable code. When planning to deploy AWS infrastructure, it's better to leverage this functionality and be aware of the common gotchas to avoid conflicts with other Terraform configurations.

****

```terraform
provider "aws" {
  region = "us-east-1"
}

module "function" {
  source = "../../modules/lambda"

  name = "lambda-sample"

  # Point to the dist directory with transpiled JS
  src_dir = "${path.module}/dist"
  runtime = "nodejs20.x"
  handler = "index.lambdaHandler" # index.js, lambdaHandler

  memory_size = 128
  timeout     = 5

  environment_variables = {
    NODE_ENV = "production"
  }
}

module "gateway" {
  source = "../../modules/api-gateway"

  name         = "lambda-sample"
  function_arn = module.function.function_arn
  api_gateway_routes = ["GET /"]
}

```

**Permissions:** Defines the required permissions to execute the Lambda and access AWS services.

```terraform
data "aws_iam_policy_document" "policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
```


### Tofu Deployment

Deploying the API should be as simple as cloning the code and running a couple of Terraform commands.

The `terraform init` command is used to initialize a project in a working directory. This command downloads provider code and configures the backend, where state and other key data are stored.

```sh
terraform init
```

The `terraform apply` command is used to apply the changes defined in your infrastructure configuration and create or modify the corresponding resources in your infrastructure provider.

**You can use the Node.js runtime to run TypeScript code in AWS Lambda. Because Node.js doesn't run TypeScript code natively, you must first transpile your TypeScript code into JavaScript.**

```sh
./tf.sh
```

Finally, you can retrieve the information from the *Outputs* and make the API call.

```sh
http "$(terraform output -raw api_endpoint)"
```

## Conclusion 🤔

In this article, we have explored the combination of Tofu and Serverless to create an API in minutes.

By leveraging IaC, and automated testing, we can achieve faster and more reliable deployments while maintaining high-quality code.

We should organize our modules in a way that we can easily interact with a part of the infrastructure without having to
understand the whole system.

Not too long ago, deploying an API in production was a tedious task that involved multiple actors. Nowadays, we have a wealth of open-source software and developer-focused tools that emphasize immutability, automation, productivity-enhancing AI, and powerful IDEs. In summary, there has never been a better time to be an engineer and create value in society through software.

- [LinkedIn](https://www.linkedin.com/in/%F0%9F%91%A8%E2%80%8D%F0%9F%8F%AB-jorge-tovar-71847669/)
- [Twitter](https://twitter.com/jorgetovar621)
- [GitHub](https://github.com/jorgetovar)

If you enjoyed the articles, visit my blog at [jorgetovar.dev](https://jorgetovar.dev).
