locals {
  dns_domain_id = [
    for d in jsondecode(data.http.dynu_get_dns_domains.response_body)["domains"] : d
    if d["name"] == var.dns_domain
  ][0]["id"]

  dns_subdomains = [
    for d in jsondecode(data.http.dynu_get_dns_domain_subdomains.response_body)["dnsRecords"] : d
    if d["nodeName"] == var.dns_subdomain
  ]

  dns_subdomain_id = length(local.dns_subdomains) > 0 ? local.dns_subdomains[0]["id"] : ""

  dynu_request_headers = {
    Accept  = "application/json",
    API-Key = var.dynu_api_key
  }
  dynu_dns_request_body = jsonencode(
    {
      nodeName    = "${var.dns_subdomain}",
      recordType  = "A",
      ttl         = 300,
      state       = true,
      group       = "",
      ipv4Address = "${var.dns_ipv4_address}"
    }
  )

  dns_subdomain_exists = length(jsondecode(data.http.dynu_get_dns_domain.response_body)["dnsRecords"]) != 0
}

data "http" "dynu_get_dns_domains" {
  url             = "https://api.dynu.com/v2/dns"
  method          = "GET"
  request_headers = local.dynu_request_headers
}

data "http" "dynu_get_dns_domain_subdomains" {
  url             = "https://api.dynu.com/v2/dns/${local.dns_domain_id}/record"
  method          = "GET"
  request_headers = local.dynu_request_headers
}

data "http" "dynu_get_dns_domain" {
  url             = "https://api.dynu.com/v2/dns/record/${var.dns_subdomain}.${var.dns_domain}?recordType=A"
  method          = "GET"
  request_headers = local.dynu_request_headers
}
data "http" "dynu_create_record" {
  count      = local.dns_subdomain_exists ? 0 : 1

  url             = "https://api.dynu.com/v2/dns/${local.dns_domain_id}/record"
  method          = "POST"
  request_headers = local.dynu_request_headers
  request_body    = local.dynu_dns_request_body
}

data "http" "dynu_update_record" {
  count      = local.dns_subdomain_exists ? 1 : 0

  url             = "https://api.dynu.com/v2/dns/${local.dns_domain_id}/record/${local.dns_subdomain_id}"
  method          = "POST"
  request_headers = local.dynu_request_headers
  request_body    = local.dynu_dns_request_body
}
