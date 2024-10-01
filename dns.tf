data "http" "dynu" {
  depends_on = [aws_instance.this]
  url        = "https://api.dynu.com/v2/dns/100202404/record"
  method     = "POST"
  request_headers = {
    Accept  = "application/json",
    API-Key = ""
  }

  request_body = jsonencode(
    {
      nodeName    = "${var.dns_subdomain}",
      recordType  = "A",
      ttl         = 300,
      state       = true,
      group       = "",
      ipv4Address = "${aws_instance.this.public_ip}"
    }
  )
}

