resource "aws_config_configuration_recorder_status" "status" {
  name       = aws_config_configuration_recorder.recorder.name
  is_enabled = true

  depends_on = [
    aws_config_delivery_channel.channel
  ]
}
