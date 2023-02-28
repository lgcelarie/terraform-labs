terraform {

}

module "apache-example" {
  source = ".//terraform-aws-apache-example"
  vpc_id = ""

  access_ip = ""

  public_key = ""
}
