# Generate .zip file to be uploaded to the lambda function 
data "archive_file" "zip_python_code" {
  type          = "zip"
  source_dir    = "${path.module}/python"
  output_path   = "${path.module}/python/hello_world.zip"
}


resource "aws_lambda_function" "lambda_function" {
  filename            = "${path.module}/python/hello_world.zip"
  function_name       = "lambda_flask"
  role                = var.lambda_role
  handler             = "hello_world.lambda_handler"
  runtime             = "python3.10"
  architectures       = ["x86_64"]
  source_code_hash    = "${data.archive_file.zip_python_code.output_base64sha256}"
  timeout             = 60

  # https://github.com/keithrozario/Klayers/tree/master/deployments/python3.10
  layers = [
    "arn:aws:lambda:eu-central-1:770693421928:layer:Klayers-p310-Pillow:3"
  ]
}
