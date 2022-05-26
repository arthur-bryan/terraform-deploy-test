variable "availability_zone" {
    default = "sa-east-1a"
}

variable "region" {
    default = "sa-east-1"
}

variable "vm_instance_name" {
    default = "AW1P-TESTMOB-123"
}

variable "private_ip_address" {
    default = "10.50.22.123"
}


variable "ec2_instance_type" {
    default = "t2.large"
}


variable "admin_username" {
    default = "test_user"
}

variable "admin_password" {
    default = "Test@123"
}


variable "instance_tags" {
    type = map
    default = {
		"Name"			= "AW1P-TESTMOB-123"
        "Centro_Custo"  = "Renner"
        "Application"   = "Front End"
        "Ambiente"      = "Producao"
        "Processing"    = "Issuer"
        "Produto"       = "Mobilidade"
    }
}

variable "app_tags" {
	type = map
	default = {
		"Centro_Custo"	= "Renner"
        "Application"	= "Front End"
        "Ambiente"		= "Producao"
        "Processing"	= "Issuer"
        "Produto"		= "Mobilidade"
	}
}
