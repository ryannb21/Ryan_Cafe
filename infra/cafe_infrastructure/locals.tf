locals {
  public_subnet_ids = {
    for k in var.public_subnet_keys : k => module.subnets.subnet_ids[k]
  }

  app_subnet_ids = {
    for k in var.app_subnet_keys : k => module.subnets.subnet_ids[k]
  }

  db_subnet_ids = {
    for k in var.db_subnet_keys : k => module.subnets.subnet_ids[k]
  }

  private_to_nat = {
    for idx in range(length(var.app_subnet_keys)) :
    var.app_subnet_keys[idx] => module.nat_gateway.nat_gateway_ids[var.public_subnet_keys[idx]]
  }


  #NATGateway Configuration begins here
  nat_gateway_configs = {
    for key in var.public_subnet_keys : key => {
      allocation_id = module.eip.eip_allocation_ids[key]
      subnet_id     = module.subnets.subnet_ids[key]
    }
  }

  nat_gateway_ids = module.nat_gateway.nat_gateway_ids
}