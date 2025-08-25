terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.0.0-beta3"
    }
  }
}

provider "aws" {
  region     = var.bucket_region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_s3_bucket" "bucket" {
  bucket = "e-commerce-sales-bucket"

  tags = {
    Name        = "main_bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "staging_bucket" {
  bucket = "e-commerce-sales-staging"

  tags = {
    Name        = "staging"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "object_shopee_dev" {
  for_each = fileset("../../data/shopee/clean/dev/", "*.csv")
  bucket = aws_s3_bucket.bucket.bucket
  key    = "/data/shopee/clean/dev/${each.value}"
  source = "../../data/shopee/clean/dev/${each.value}"
  depends_on = [ aws_s3_bucket.bucket ]
}

resource "aws_s3_object" "object_shopee_prod" {
  for_each = fileset("../../data/shopee/clean/prod/", "*.csv")
  bucket = aws_s3_bucket.bucket.bucket
  key    = "/data/shopee/clean/prod/${each.value}"
  source = "../../data/shopee/clean/prod/${each.value}"
  depends_on = [ aws_s3_bucket.bucket ]
}

resource "aws_s3_object" "kit_components_dev" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = "/data/supplies/clean/spectrum_kit_dev/dev_kit_components.csv"
  source = "../../data/supplies/clean/dev_kit_components.csv"
  depends_on = [ aws_s3_bucket.bucket ]
}

resource "aws_s3_object" "kit_components_prod" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = "/data/supplies/clean/spectrum_kit_prod/kit_components.csv"
  source = "../../data/supplies/clean/kit_components.csv"
  depends_on = [ aws_s3_bucket.bucket ]
}

resource "aws_s3_object" "costs_dev" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = "/data/supplies/clean/spectrum_costs_dev/dev_clean_cost.csv"
  source = "../../data/supplies/clean/dev_clean_cost.csv"
  depends_on = [ aws_s3_bucket.bucket ]
}

resource "aws_s3_object" "costs_prod" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = "/data/supplies/clean/spectrum_costs_prod/clean_cost_data.csv"
  source = "../../data/supplies/clean/clean_cost_data.csv"
  depends_on = [ aws_s3_bucket.bucket ]
}

resource "aws_s3_object" "pyspark_script" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = "/jobs/cluster.py"
  source = "../../scripts/pyspark/cluster.py"
  depends_on = [ aws_s3_bucket.bucket ]
}

data "aws_vpc" "default_vpc" {
  id = var.aws_vpc
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-instance-sg"
  description = "Allow SSH and HTTP access"
  vpc_id      = data.aws_vpc.default_vpc.id 

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "this" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name        
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  
  tags = {
    Name = "test"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum install python3-pip -y
              pip3 install boto3 pandas pyarrow dbt-core dbt-redshift redshift_connector
              EOF
  
  iam_instance_profile = "EC2-SSM-Redshift-Access"
}

resource "null_resource" "copy_folder" {
  depends_on = [aws_instance.this]
  
  connection {
    type        = "ssh"
    host        = aws_instance.this.public_ip
    user        = "ec2-user"
    private_key = file("~/.ssh/ec2-instance.pem")
  }

  provisioner "file" {
    source      = var.scripts_path
    destination = "/home/ec2-user/"
  }

  provisioner "file" {
    source      = var.dbt_path
    destination = "/home/ec2-user/"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod -R +x /home/ec2-user/scripts/" 
    ]
  }
}

output "instance_public_ip" {
  description = "EC2 instance public IP"
  value = aws_instance.this.public_ip
}

output "ec2_security_group_id" {
  description = "EC2 instance security group ID"
  value       = aws_instance.this.vpc_security_group_ids
}

resource "aws_redshiftserverless_namespace" "e_commerce_namespace" {
  namespace_name = var.namespace_name
  region = var.redshift_region
  admin_username = var.admin_username
  admin_user_password = var.admin_user_password
  default_iam_role_arn = var.default_iam_role_arn
  db_name = var.initial_db
  iam_roles = [var.default_iam_role_arn]
  depends_on = [ aws_instance.this ]
}

resource "aws_redshiftserverless_workgroup" "sales_workgroup" {
  namespace_name = var.namespace_name
  workgroup_name = var.workgroup_name
  region = var.redshift_region
  base_capacity = var.base_capacity
  port = var.redshift_port
  depends_on = [ aws_redshiftserverless_namespace.e_commerce_namespace]
}

resource "aws_security_group_rule" "ec2_to_redshift" {
  region            = var.ec2_region
  from_port         = var.ec2_port
  protocol          = var.protocol
  security_group_id = var.default_sg
  to_port           = var.redshift_port
  type              = "ingress"
  source_security_group_id = aws_security_group.ec2_sg.id
  depends_on = [ aws_redshiftserverless_workgroup.sales_workgroup ]
}

#AWS Lambda begin
data "archive_file" "check_extension_zip" {
  type        = "zip"
  source_dir  = "../../scripts/lambda_functions/check_extension"
  output_path = "../../scripts/lambda_functions/check_extension.zip"
}

data "archive_file" "start_step_function_zip" {
  type        = "zip"
  source_dir  = "../../scripts/lambda_functions/step_function"
  output_path = "../../scripts/lambda_functions/step_function.zip"
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.file_extension.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
  depends_on = [ aws_s3_bucket.bucket, aws_lambda_function.file_extension  ]
}

resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = aws_s3_bucket.bucket.bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.file_extension.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "data/shopee/clean/dev/"
  }
  depends_on = [ aws_s3_bucket.bucket, aws_lambda_function.file_extension, aws_lambda_permission.allow_bucket ]
}

resource "aws_lambda_function" "file_extension" {
  function_name    = "checkFileExtension"
  role             = var.file_extension_iam
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  filename         = data.archive_file.check_extension_zip.output_path
  source_code_hash = data.archive_file.check_extension_zip.output_base64sha256

  environment {
    variables = {
      ENVIRONMENT = "dev"
    }
  }

  timeout     = 30
  memory_size = 128

  tags = {
    Name        = "checkFileExtension"
    Environment = "dev"
  }
}

resource "aws_lambda_function" "start_step_function" {
  function_name    = "startStepFunction"
  role             = var.step_function_iam
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  filename         = data.archive_file.start_step_function_zip.output_path
  source_code_hash = data.archive_file.start_step_function_zip.output_base64sha256

  environment {
    variables = {
      ENVIRONMENT = "dev"
      STATE_MACHINE_ARN = aws_sfn_state_machine.e_commerce_orchestration.arn
    }
  }

  timeout     = 30
  memory_size = 128

  tags = {
    Name        = "start_step_function"
    Environment = "dev"
  }
  depends_on = [ aws_sfn_state_machine.e_commerce_orchestration ]
}

resource "aws_lambda_function_event_invoke_config" "example" {
  function_name = aws_lambda_function.file_extension.function_name
}
#AWS Lambda end

#AWS Step Functions
resource "aws_sfn_state_machine" "e_commerce_orchestration" {
  name     = "e-commerce-sales-orchestration"
  role_arn = var.step_function_role_arn

  definition = jsonencode({
  "Comment": "A description of my state machine",
  "StartAt": "CreateExternalTables",
  "States": {
    "CreateExternalTables": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:ssm:sendCommand",
      "Parameters": {
        "InstanceIds": [
          aws_instance.this.id
        ],
        "DocumentName": "AWS-RunShellScript",
        "Parameters": {
          "commands": [
            "python3 /home/ec2-user/scripts/external_tables/create.py"
          ]
        }
      },
      "Next": "WaitForCreateExternalTables",
      "ResultPath": "$.CreateExternalTables"
    },
    "WaitForCreateExternalTables": {
      "Type": "Wait",
      "Seconds": 5,
      "Next": "CheckCreateExternalTables"
    },
    "CheckCreateExternalTables": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:ssm:getCommandInvocation",
      "Parameters": {
        "CommandId.$": "$.CreateExternalTables.Command.CommandId",
        "InstanceId": aws_instance.this.id
      },
      "Next": "EvaluateCreateExternalTables",
      "ResultPath": "$.CheckCreateExternalTables",
      "Retry": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "IntervalSeconds": 5,
          "MaxAttempts": 3
        }
      ]
    },
    "EvaluateCreateExternalTables": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.CheckCreateExternalTables.Status",
          "StringEquals": "Success",
          "Next": "LoadToStgBucket"
        },
        {
          "Variable": "$.CheckCreateExternalTables.Status",
          "StringEquals": "Failed",
          "Next": "HandleCreateTableFailure"
        }
      ],
      "Default": "WaitForCreateExternalTables"
    },
    "LoadToStgBucket": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:ssm:sendCommand",
      "Parameters": {
        "InstanceIds": [
          aws_instance.this.id
        ],
        "DocumentName": "AWS-RunShellScript",
        "Parameters": {
          "commands": [
            "python3 /home/ec2-user/scripts/loading/staging_bucket/filesystem_pipeline.py"
          ]
        }
      },
      "Next": "WaitForLoadToStgBucket",
      "ResultPath": "$.LoadToStgBucket"
    },
    "WaitForLoadToStgBucket": {
      "Type": "Wait",
      "Seconds": 5,
      "Next": "CheckLoadToStgBucketStatus"
    },
    "CheckLoadToStgBucketStatus": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:ssm:getCommandInvocation",
      "Parameters": {
        "CommandId.$": "$.LoadToStgBucket.Command.CommandId",
        "InstanceId": aws_instance.this.id
      },
      "Next": "EvaluateLoadToStgBucket",
      "ResultPath": "$.CheckLoadToStgBucketStatus",
      "Retry": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "IntervalSeconds": 5,
          "MaxAttempts": 3
        }
      ]
    },
    "EvaluateLoadToStgBucket": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.CheckLoadToStgBucketStatus.Status",
          "StringEquals": "Success",
          "Next": "InstallDbtDeps"
        },
        {
          "Variable": "$.CheckLoadToStgBucketStatus.Status",
          "StringEquals": "Failed",
          "Next": "HandleLoadFailure"
        }
      ],
      "Default": "WaitForLoadToStgBucket"
    },
    "InstallDbtDeps": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:ssm:sendCommand",
      "Parameters": {
        "InstanceIds": [
          aws_instance.this.id
        ],
        "DocumentName": "AWS-RunShellScript",
        "Parameters": {
          "commands": [
            "cd /home/ec2-user/dbt_files/e_commerce_sales && dbt deps"
          ]
        }
      },
      "Next": "WaitForDbtDeps",
      "ResultPath": "$.InstallDbtDeps"
    },
    "WaitForDbtDeps": {
      "Type": "Wait",
      "Seconds": 5,
      "Next": "CheckDbtDepsStatus"
    },
    "CheckDbtDepsStatus": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:ssm:getCommandInvocation",
      "Parameters": {
        "CommandId.$": "$.InstallDbtDeps.Command.CommandId",
        "InstanceId": aws_instance.this.id
      },
      "Next": "EvaluateDbtDeps",
      "ResultPath": "$.CheckDbtDepsStatus"
    },
    "EvaluateDbtDeps": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.CheckDbtDepsStatus.Status",
          "StringEquals": "Success",
          "Next": "RunDbt"
        },
        {
          "Variable": "$.CheckDbtDepsStatus.Status",
          "StringEquals": "Failed",
          "Next": "HandleDbtDepsFailure"
        }
      ],
      "Default": "WaitForDbtDeps"
    },
    "RunDbt": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:ssm:sendCommand",
      "Parameters": {
        "InstanceIds": [
          aws_instance.this.id
        ],
        "DocumentName": "AWS-RunShellScript",
        "Parameters": {
          "commands": [
            "cd /home/ec2-user/dbt_files/e_commerce_sales && dbt run --profiles-dir \"/home/ec2-user/dbt_files/e_commerce_sales\" --target dev"
          ]
        }
      },
      "Next": "WaitForDbtRun",
      "ResultPath": "$.DbtRunResult"
    },
    "WaitForDbtRun": {
      "Type": "Wait",
      "Seconds": 5,
      "Next": "CheckDbtRunStatus"
    },
    "CheckDbtRunStatus": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:ssm:getCommandInvocation",
      "Parameters": {
        "CommandId.$": "$.DbtRunResult.Command.CommandId",
        "InstanceId": aws_instance.this.id
      },
      "Next": "EvaluateDbtRun",
      "ResultPath": "$.CheckDbtRunStatus"
    },
    "EvaluateDbtRun": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.CheckDbtRunStatus.Status",
          "StringEquals": "Success",
          "Next": "EndPipeline"
        },
        {
          "Variable": "$.CheckDbtRunStatus.Status",
          "StringEquals": "Failed",
          "Next": "HandleDbtRunFailure"
        }
      ],
      "Default": "WaitForDbtRun"
    },
    "EndPipeline": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:ssm:getCommandInvocation",
      "Parameters": {
        "CommandId.$": "$.DbtRunResult.Command.CommandId",
        "InstanceId": aws_instance.this.id
      },
      "End": true
    },
    "HandleCreateTableFailure": {
      "Type": "Fail",
      "Error": "CreateExternalTablesFailed",
      "Cause": "External tables could not be created."
    },
    "HandleLoadFailure": {
      "Type": "Fail",
      "Error": "LoadToStgBucketFailed",
      "Cause": "Failed to load data to staging bucket"
    },
    "HandleDbtDepsFailure": {
      "Type": "Fail",
      "Error": "DbtDepsFailed",
      "Cause": "dbt deps command failed"
    },
    "HandleDbtRunFailure": {
      "Type": "Fail",
      "Error": "DbtRunFailed",
      "Cause": "dbt run command failed"
    }
  }
})

depends_on = [ aws_instance.this ]
}

#AWS Glue job
resource "aws_glue_job" "etl_job" {
  name              = var.job_name
  description       = "Job to process the data before loading it to Redshift"
  role_arn          = var.aws_glue_s3_access_iam
  glue_version      = var.glue_version
  max_retries       = var.max_retries
  timeout           = var.timeout
  number_of_workers = var.workers_num
  worker_type       = var.worker_type
  execution_class   = "STANDARD"

  command {
    script_location = var.script_location
    name            = "glue-etl"
    python_version  = "3"
  }

  notification_property {
    notify_delay_after = 3 # delay in minutes
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--continuous-log-logGroup"          = "/aws-glue/jobs"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
    "--enable-metrics"                   = ""
    "--enable-auto-scaling"              = "true"
  }

  execution_property {
    max_concurrent_runs = 1
  }

  depends_on = [aws_s3_object.pyspark_script]

  tags = {
    "ManagedBy" = "AWS"
  }
}