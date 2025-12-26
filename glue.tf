# =============================================================================
# GLUE DATABASE AND TABLES - For Athena Queries
# =============================================================================

# -----------------------------------------------------------------------------
# Glue Database
# -----------------------------------------------------------------------------

resource "aws_glue_catalog_database" "smartspend" {
  name        = local.glue_database_name
  description = "SmartSpend AI data catalog for AWS resource data (${var.stack_name})"
}

# -----------------------------------------------------------------------------
# EC2 Instances Table
# -----------------------------------------------------------------------------

resource "aws_glue_catalog_table" "ec2_instances" {
  name          = "ec2_instances"
  database_name = aws_glue_catalog_database.smartspend.name
  description   = "EC2 instance data collected by SmartSpend AI with CloudWatch metrics"
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    classification  = "parquet"
    compressionType = "snappy"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.data_bucket.id}/data/ec2_instances/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    # Basic instance info
    columns {
      name = "instance_id"
      type = "string"
    }
    columns {
      name = "instance_type"
      type = "string"
    }
    columns {
      name = "state"
      type = "string"
    }
    columns {
      name = "launch_time"
      type = "string"
    }
    columns {
      name = "name"
      type = "string"
    }
    columns {
      name = "availability_zone"
      type = "string"
    }
    columns {
      name = "vcpus"
      type = "int"
    }
    columns {
      name = "memory_gb"
      type = "double"
    }
    columns {
      name = "architecture"
      type = "string"
    }
    columns {
      name = "public_ip_address"
      type = "string"
    }
    columns {
      name = "private_ip_address"
      type = "string"
    }
    columns {
      name = "public_dns_name"
      type = "string"
    }
    columns {
      name = "private_dns_name"
      type = "string"
    }

    # AMI info
    columns {
      name = "image_id"
      type = "string"
    }
    columns {
      name = "image_name"
      type = "string"
    }
    columns {
      name = "operating_system"
      type = "string"
    }
    columns {
      name = "os_version"
      type = "string"
    }

    # Security groups and volumes (JSON arrays)
    columns {
      name = "security_groups"
      type = "string"
    }
    columns {
      name = "ebs_volume_ids"
      type = "string"
    }
    columns {
      name = "ebs_volume_types"
      type = "string"
    }
    columns {
      name = "ebs_sizes_gb"
      type = "string"
    }

    # Autoscaling
    columns {
      name = "is_in_autoscaling_group"
      type = "boolean"
    }
    columns {
      name = "autoscaling_group_name"
      type = "string"
    }

    # CPU metrics (aggregate)
    columns {
      name = "cpu_utilization"
      type = "double"
    }
    columns {
      name = "analyse_usage"
      type = "string"
    }

    # Network metrics (aggregate)
    columns {
      name = "network_in_bytes"
      type = "double"
    }
    columns {
      name = "network_out_bytes"
      type = "double"
    }
    columns {
      name = "network_in_gb"
      type = "double"
    }
    columns {
      name = "network_out_gb"
      type = "double"
    }

    # EBS Disk I/O metrics (aggregate)
    columns {
      name = "ebs_read_ops"
      type = "double"
    }
    columns {
      name = "ebs_write_ops"
      type = "double"
    }
    columns {
      name = "ebs_read_bytes"
      type = "double"
    }
    columns {
      name = "ebs_write_bytes"
      type = "double"
    }
    columns {
      name = "ebs_read_gb"
      type = "double"
    }
    columns {
      name = "ebs_write_gb"
      type = "double"
    }

    # Time-series metrics (JSON arrays with timestamp/value pairs)
    columns {
      name = "cpu_timeseries"
      type = "string"
    }
    columns {
      name = "network_in_timeseries"
      type = "string"
    }
    columns {
      name = "network_out_timeseries"
      type = "string"
    }
    columns {
      name = "ebs_read_ops_timeseries"
      type = "string"
    }
    columns {
      name = "ebs_write_ops_timeseries"
      type = "string"
    }
    columns {
      name = "ebs_read_bytes_timeseries"
      type = "string"
    }
    columns {
      name = "ebs_write_bytes_timeseries"
      type = "string"
    }

    # Detailed JSON objects
    columns {
      name = "vpc_info"
      type = "string"
    }
    columns {
      name = "subnet_info"
      type = "string"
    }
    columns {
      name = "network_interfaces"
      type = "string"
    }
    columns {
      name = "security_groups_detailed"
      type = "string"
    }
    columns {
      name = "ebs_volumes_detailed"
      type = "string"
    }
    columns {
      name = "instance_type_specs"
      type = "string"
    }
    columns {
      name = "autoscaling_info"
      type = "string"
    }

    # Metadata
    columns {
      name = "tags"
      type = "string"
    }
    columns {
      name = "region"
      type = "string"
    }
  }
}

# -----------------------------------------------------------------------------
# RDS Instances Table
# -----------------------------------------------------------------------------

resource "aws_glue_catalog_table" "rds_instances" {
  name          = "rds_instances"
  database_name = aws_glue_catalog_database.smartspend.name
  description   = "RDS instance data collected by SmartSpend AI"
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    classification  = "parquet"
    compressionType = "snappy"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.data_bucket.id}/data/rds_instances/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "db_instance_arn"
      type = "string"
    }
    columns {
      name = "db_instance_identifier"
      type = "string"
    }
    columns {
      name = "engine"
      type = "string"
    }
    columns {
      name = "engine_version"
      type = "string"
    }
    columns {
      name = "db_instance_class"
      type = "string"
    }
    columns {
      name = "db_instance_status"
      type = "string"
    }
    columns {
      name = "allocated_storage"
      type = "int"
    }
    columns {
      name = "storage_type"
      type = "string"
    }
    columns {
      name = "storage_encrypted"
      type = "boolean"
    }
    columns {
      name = "multi_az"
      type = "boolean"
    }
    columns {
      name = "publicly_accessible"
      type = "boolean"
    }
    columns {
      name = "vpc_id"
      type = "string"
    }
    columns {
      name = "tags"
      type = "string"
    }
    columns {
      name = "region"
      type = "string"
    }
    columns {
      name = "account_id"
      type = "string"
    }
    columns {
      name = "timestamp"
      type = "string"
    }
  }
}

# -----------------------------------------------------------------------------
# S3 Buckets Table
# -----------------------------------------------------------------------------

resource "aws_glue_catalog_table" "s3_buckets" {
  name          = "s3_buckets"
  database_name = aws_glue_catalog_database.smartspend.name
  description   = "S3 bucket data collected by SmartSpend AI"
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    classification  = "parquet"
    compressionType = "snappy"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.data_bucket.id}/data/s3_buckets/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "bucket_arn"
      type = "string"
    }
    columns {
      name = "bucket_name"
      type = "string"
    }
    columns {
      name = "region"
      type = "string"
    }
    columns {
      name = "account_id"
      type = "string"
    }
    columns {
      name = "creation_date"
      type = "string"
    }
    columns {
      name = "versioning"
      type = "string"
    }
    columns {
      name = "encryption"
      type = "string"
    }
    columns {
      name = "tags"
      type = "string"
    }
    columns {
      name = "public_access_block"
      type = "string"
    }
    columns {
      name = "object_count"
      type = "bigint"
    }
    columns {
      name = "total_size_bytes"
      type = "bigint"
    }
    columns {
      name = "timestamp"
      type = "string"
    }
  }
}

# -----------------------------------------------------------------------------
# CUR Data Table
# -----------------------------------------------------------------------------

resource "aws_glue_catalog_table" "cur_data" {
  name          = "cur_data"
  database_name = aws_glue_catalog_database.smartspend.name
  description   = "Cost and Usage Report data collected by SmartSpend AI"
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    classification  = "parquet"
    compressionType = "snappy"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.data_bucket.id}/data/cur_data/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "line_item_usage_start_date"
      type = "timestamp"
    }
    columns {
      name = "line_item_usage_end_date"
      type = "timestamp"
    }
    columns {
      name = "line_item_resource_id"
      type = "string"
    }
    columns {
      name = "line_item_line_item_type"
      type = "string"
    }
    columns {
      name = "line_item_usage_type"
      type = "string"
    }
    columns {
      name = "line_item_operation"
      type = "string"
    }
    columns {
      name = "line_item_usage_amount"
      type = "double"
    }
    columns {
      name = "line_item_unblended_cost"
      type = "double"
    }
    columns {
      name = "line_item_blended_cost"
      type = "double"
    }
    columns {
      name = "product_servicecode"
      type = "string"
    }
    columns {
      name = "product_product_name"
      type = "string"
    }
    columns {
      name = "product_region"
      type = "string"
    }
  }
}

# -----------------------------------------------------------------------------
# Orphaned Resources Table
# -----------------------------------------------------------------------------

resource "aws_glue_catalog_table" "orphaned_resources" {
  name          = "orphaned_resources"
  database_name = aws_glue_catalog_database.smartspend.name
  description   = "Orphaned AWS resources detected by SmartSpend AI"
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    classification  = "parquet"
    compressionType = "snappy"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.data_bucket.id}/data/orphaned_resources/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "resource_type"
      type = "string"
    }
    columns {
      name = "resource_id"
      type = "string"
    }
    columns {
      name = "arn"
      type = "string"
    }
    columns {
      name = "region"
      type = "string"
    }
    columns {
      name = "created_at"
      type = "string"
    }
    columns {
      name = "tags"
      type = "string"
    }
    columns {
      name = "recommendations"
      type = "string"
    }
    columns {
      name = "analysis_timestamp"
      type = "string"
    }
    columns {
      name = "fetched_at"
      type = "string"
    }
  }
}

# -----------------------------------------------------------------------------
# Resource Inventory Table
# -----------------------------------------------------------------------------

resource "aws_glue_catalog_table" "resource_inventory" {
  name          = "resource_inventory"
  database_name = aws_glue_catalog_database.smartspend.name
  description   = "Resource Explorer inventory collected by SmartSpend AI"
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    classification  = "parquet"
    compressionType = "snappy"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.data_bucket.id}/data/resource_inventory/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "arn"
      type = "string"
    }
    columns {
      name = "account_id"
      type = "string"
    }
    columns {
      name = "resource_type"
      type = "string"
    }
    columns {
      name = "service"
      type = "string"
    }
    columns {
      name = "region"
      type = "string"
    }
    columns {
      name = "last_reported_at"
      type = "timestamp"
    }
    columns {
      name = "properties"
      type = "string"
    }
    columns {
      name = "tags"
      type = "string"
    }
    columns {
      name = "updated_at"
      type = "timestamp"
    }
  }
}

