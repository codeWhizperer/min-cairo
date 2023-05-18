
use Contract::ENS::ENS;
use starknet::contract_address_const;
use starknet::testing::set_caller_address;

#[test]

#[available_gas(200000)]

fn test_store_name(){
let name:felt252 = 'Starknet';
let account = contract_address_const::<1>();
set_caller_address(account);
ENS::store_name(name);
assert(ENS::get_name(account) == name, 'error');
}



