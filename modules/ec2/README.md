# ec2

A single EC2 instance with secure defaults: encrypted root volume, IMDSv2 required, and an
optional SSM instance role so you can connect with Session Manager instead of opening SSH.
Defaults to the latest Amazon Linux 2023 AMI.

## Usage

```hcl
module "instance" {
  source = "github.com/sohailriyas01/terraform-template//modules/ec2"

  name      = "bastion"
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]

  instance_type = "t3.small"
}
```

With an inbound rule (e.g. a web server in a public subnet):

```hcl
module "web" {
  source = "github.com/sohailriyas01/terraform-template//modules/ec2"

  name                = "web"
  vpc_id              = module.vpc.vpc_id
  subnet_id           = module.vpc.public_subnet_ids[0]
  associate_public_ip = true

  ingress_rules = [{
    description = "http"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }]
}
```

A runnable example is in [`examples/complete`](./examples/complete).

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `name` | Instance name and prefix | — |
| `vpc_id` | VPC for the security group | — |
| `subnet_id` | Subnet to launch in | — |
| `instance_type` | Instance type | `t3.micro` |
| `ami_id` | AMI; latest AL2023 if unset | `null` |
| `key_name` | SSH key pair | `null` |
| `associate_public_ip` | Assign a public IP | `false` |
| `create_iam_role` | Create an SSM-enabled instance role | `true` |
| `iam_instance_profile` | Existing profile (when not creating one) | `null` |
| `ingress_rules` | Inbound SG rules | `[]` |
| `user_data` | First-boot script | `null` |
| `root_volume_size` | Root volume GiB | `20` |
| `root_volume_type` | Root volume type | `gp3` |
| `detailed_monitoring` | 1-minute CloudWatch metrics | `false` |
| `tags` | Tags for all resources | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `instance_id` | Instance ID |
| `private_ip` | Private IP |
| `public_ip` | Public IP (if assigned) |
| `security_group_id` | Instance security group |
| `iam_role_arn` | Instance role ARN (null if none) |
| `ami_id` | AMI used |

## Notes

- With `create_iam_role = true` you get SSM access out of the box — no SSH key or public IP
  needed. In a private subnet this needs NAT or SSM VPC endpoints for the agent to reach AWS.
- The root volume is always encrypted and IMDSv2 is always required; these aren't optional
  because they're the secure default.
- Each `ingress_rules` entry expands into one SG rule per CIDR in its `cidr_blocks` list.
