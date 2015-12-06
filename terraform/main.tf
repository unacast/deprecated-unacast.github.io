# Specify the provider and access details
provider "aws" {
    region = "${var.aws_region}"
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
}

variable "hosted_zone_id" {
  default = "ZEO3NSW9NETHV"
}


resource "aws_s3_bucket" "unacast-io" {
  bucket = "unacast.io"
  acl = "public-read"

  website {
    redirect_all_requests_to = "labs.unacast.io"
  }

  tags {
    Name = "Domain forwarding"
  }
}

resource "aws_route53_record" "naked" {
  zone_id = "${var.hosted_zone_id}"
  name = "unacast.io"
  type = "A"

  alias {
    name = "${aws_s3_bucket.unacast-io.website_domain}"
    zone_id = "${aws_s3_bucket.unacast-io.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = "${var.hosted_zone_id}"
  name = "www.unacast.io"
  type = "CNAME"
  ttl = 60
  records = ["unacast.github.io"]
}

resource "aws_route53_record" "labs" {
  zone_id = "${var.hosted_zone_id}"
  name = "labs.unacast.io"
  type = "CNAME"
  ttl = 60
  records = ["unacast.github.io"]
}


