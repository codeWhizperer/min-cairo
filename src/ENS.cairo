#[contract]
mod ENS{
 use starknet::get_caller_address;
 use starknet::ContractAddress;

struct Storage{
names: LegacyMap::<ContractAddress, felt252>,
}

#[event]
fn stored_name(caller:ContractAddress, name:felt252){}


#[external]
fn store_name(_name:felt252){
let caller = get_caller_address();
names::write(caller, _name);
stored_name(caller,_name);
}

#[view]
fn get_name(_address:ContractAddress) -> felt252{
let name = names::read(_address);
return name;
}

 }