
locals {
  # The port for this service to listen on
  port = var.service_definition.port != null ? var.service_definition.port : 3000

  # Add service-specific env vars
  env_vars = merge(
    var.service_definition.env_vars,
    tomap({
      # Core Bloom vars
      NEXTJS_PORT      = local.port,
      BACKEND_API_BASE = var.backend_api_base

      # AWS-specific vars
      PUBLIC_BUCKET_NAME = var.public_upload_bucket
      SECURE_BUCKET_NAME = var.secure_upload_bucket
      UPLOAD_PREFIX      = local.bucket_prefix
    })
  )

  service_definition = merge(
    var.service_definition,
    {
      env_vars = local.env_vars
    }
  )

  # A namespace for resources created in this module
  resource_namespace = "${var.name_prefix}-service-${var.service_definition.name}"

  # The prefix to use when saving files to upload buckets
  bucket_prefix = "${var.name_prefix}/${var.service_definition.name}"

  # The ARN pattern scoping access to the public upload bucket
  public_bucket_arn = "arn:aws:s3:::${var.public_upload_bucket}"

  # The ARN pattern scoping access to the secure upload bucket
  secure_bucket_arn = "arn:aws:s3:::${var.secure_upload_bucket}"

  # The value to use in IAM policies restricting access to upload buckets
  /* Probably not needed at this time
  s3_access_policy_bucket_resource = [
    local.public_bucket_arn,
    local.secure_bucket_arn
  ]
  */

  # The value to use in IAM policies restricting access to upload objects
  s3_access_policy_object_resource = [
    "${local.public_bucket_arn}/${local.bucket_prefix}/*",
    "${local.secure_bucket_arn}/${local.bucket_prefix}/*",
  ]
}