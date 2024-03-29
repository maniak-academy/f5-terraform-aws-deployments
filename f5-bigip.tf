
resource "aws_cloudformation_stack" "f5-payg-bigip-stack" {
  name         = var.f5-stack-name
  capabilities = ["CAPABILITY_IAM"]

  parameters = {
    Vpc = aws_vpc.f5-payg-vpc.id

    imageName    = var.imageName
    instanceType = "m4.large"
    sshKey       = var.aws_keypair

    managementSubnetAz1        = aws_subnet.f5-management-a.id
    managementSubnetAz1Address = var.f5-subnet1Az1Address
    provisionPublicIP          = "Yes"
    restrictedSrcAddress       = "0.0.0.0/0"
    restrictedSrcAddressApp    = "0.0.0.0/0"
    subnet1Az1                 = aws_subnet.public-a.id
    subnet1Az1Address          = var.f5-subnet1Az1Address

    bigIpModules  = "ltm:nominal"
    customImageId = "OPTIONAL"


    timezone  = "UTC"
    ntpServer = "0.pool.ntp.org"

    allowPhoneHome      = "No"
    allowUsageAnalytics = "No"

    owner       = "f5owner"
    costcenter  = "f5costcenter"
    environment = "f5env"
    group       = "f5group"
    application = "f5app"

  }
  template_url = "https://f5-payg-aws-cft-tf-env-s3.s3.amazonaws.com/f5-payg-cft.json"
}

data "template_file" "init" {
  template = "${file("${path.module}/app1.as3.tpl")}"
  vars = {
    UUID = "uuid()"
    TENANT = var.tenant
    VIP_ADDRESS = var.vip_address
  }
}
resource "bigip_as3"  "as3-example" {
     as3_json = data.template_file.init.rendered
     tenant_name = var.tenant
}