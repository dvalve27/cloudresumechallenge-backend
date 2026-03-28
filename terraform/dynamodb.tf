resource "aws_dynamodb_table" "site_counter" {
  name         = "site-hits"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# Initialize the counter at 0
resource "aws_dynamodb_table_item" "init_counter" {
  table_name = aws_dynamodb_table.site_counter.name
  hash_key   = aws_dynamodb_table.site_counter.hash_key

  item = <<ITEM
{
  "id": {"S": "counter"},
  "hits": {"N": "0"}
}
ITEM
}