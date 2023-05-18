use Contract::ERC20::Token;
use starknet::contract_address_const;
use starknet::testing::set_caller_address;
use starknet::ContractAddress;
use integer::u256;
use integer::u256_from_felt252;

fn setup() -> ContractAddress {
    let name: felt252 = 'Starknet';
    let symbol: felt252 = 'ERC20S';
    let decimals: u8 = 18_u8;
    let account = contract_address_const::<1>();
    set_caller_address(account);
    Token::constructor(name, symbol, decimals);

    account
}

#[test]
#[available_gas(2000000)]
fn test_mint(){
   let caller = setup();
   let mint_amount:u256 =  u256_from_felt252(2000);
   Token::mint(mint_amount);
   assert(Token::total_supply() == mint_amount, 'wrong amount');
   assert(Token::balance_of(caller) == mint_amount,'wrong balance');

}

#[test]
#[available_gas(2000000)]
fn test_transfer(){
    let caller = setup();

    let recipient = contract_address_const::<2>();
    let amount:u256 = u256_from_felt252(100);
    let total_supply:u256 = u256_from_felt252(2000);
    Token::mint(total_supply);
    Token::transfer(recipient, amount);

    assert(Token::balance_of(recipient) == amount, 'wrong balance');
    assert(Token::balance_of(caller) == total_supply - amount , 'wrong balance');
}