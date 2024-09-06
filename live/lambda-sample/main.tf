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
