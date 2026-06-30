# vpc

A VPC with public and private subnets spread across availability zones, an internet
gateway for the public tier, and NAT gateways for private egress. Subnet CIDRs are
derived from the VPC block, so you only pick the VPC CIDR and how many AZs to use.

Pairs with [`ecs-fargate-service`](../ecs-fargate-service): feed its `vpc_id`,
`public_subnet_ids`, and `private_subnet_ids` straight from this module's outputs.

## Usage

```hcl
module "vpc" {
  source = "github.com/sohailriyas01/terraform-template//modules/vpc"

  name       = "prod"
  cidr_block = "10.0.0.0/16"
  az_count   = 3

  single_nat_gateway = false # one NAT per AZ for production

  tags = {
    Environment = "prod"
  }
}
```

A runnable example is in [`examples/complete`](./examples/complete).

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `name` | Name prefix for all resources | — |
| `cidr_block` | VPC CIDR | `10.0.0.0/16` |
| `az_count` | Number of AZs to use (ignored if `azs` set) | `2` |
| `azs` | Explicit AZs to use | `[]` |
| `subnet_newbits` | Bits added to the VPC prefix per subnet | `8` |
| `enable_nat_gateway` | Create NAT gateways for private egress | `true` |
| `single_nat_gateway` | Share one NAT instead of one per AZ | `true` |
| `tags` | Tags for all resources | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | VPC ID |
| `vpc_cidr_block` | VPC CIDR |
| `azs` | AZs in use |
| `public_subnet_ids` | Public subnet IDs, ordered by AZ |
| `private_subnet_ids` | Private subnet IDs, ordered by AZ |
| `public_route_table_id` | Public route table ID |
| `private_route_table_ids` | Private route table IDs, ordered by AZ |
| `internet_gateway_id` | Internet gateway ID |
| `nat_gateway_ids` | NAT gateway IDs |
| `nat_public_ips` | NAT gateway public IPs |

## Notes

- `single_nat_gateway = true` (the default) runs one NAT for the whole VPC — cheaper, but
  a zone outage takes out private egress for every AZ. Set it `false` in production to get
  one NAT per AZ.
- With a `/16` VPC and the default `subnet_newbits = 8`, subnets are `/24` (~250 hosts
  each). Raise `subnet_newbits` for smaller subnets.
- Set `enable_nat_gateway = false` if private subnets don't need outbound internet — it
  drops the NAT gateways and their hourly cost.
