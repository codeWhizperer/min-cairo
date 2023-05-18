#[contract]
mod Token {
    // imports
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::contract_address_const;
    use zeroable::Zeroable;
    use starknet::contract_address::ContractAddressZeroable;

    // Events

    #[event]
    fn Transfer(from: ContractAddress, to: ContractAddress, value: u256) {}

    #[event]
    fn Approval(owner: ContractAddress, spender: ContractAddress, value: u256) {}


    // Storage || State variables
    struct Storage {
        ERC20_name: felt252,
        ERC20_symbol: felt252,
        ERC20_decimals: u8,
        ERC20_total_supply: u256,
        ERC20_balance: LegacyMap::<ContractAddress, u256>,
        ERC20_allowance: LegacyMap::<(ContractAddress, ContractAddress), u256>
    }


    #[constructor]
    fn constructor(name: felt252, symbol: felt252, decimal: u8) {
        ERC20_name::write(name);
        ERC20_symbol::write(symbol);
        ERC20_decimals::write(decimal);
    }

    // view function

    #[view]
    fn name() -> felt252 {
        return ERC20_name::read();
    }

    #[view]
    fn symbol() -> felt252 {
        return ERC20_symbol::read();
    }

    #[view]
    fn total_supply() -> u256 {
        return ERC20_total_supply::read();
    }

    #[view]
    fn decimals() -> u8 {
        return ERC20_decimals::read();
    }

    #[view]
    fn balance_of(account: ContractAddress) -> u256 {
        return ERC20_balance::read(account);
    }

    #[view]
    fn allowance(owner: ContractAddress, spender: ContractAddress) -> u256 {
        return ERC20_allowance::read((owner, spender));
    }

    // External functions
    #[external]
    fn transfer(recipient: ContractAddress, amount: u256) {
        let caller = get_caller_address();
        _transfer(caller, recipient, amount);
    }

    #[external]
    fn tranferFrom(sender: ContractAddress, recipient: ContractAddress, amount: u256) {
        let caller = get_caller_address();
        _spend_allowance(sender, caller, amount);
        _transfer(sender, recipient, amount);
    }

    #[external]
    fn mint(amount: u256) {
        let caller = get_caller_address();
        let current_supply = ERC20_total_supply::read();
        ERC20_balance::write(caller, ERC20_balance::read(caller) + amount);
        ERC20_total_supply::write(current_supply + amount);
        Transfer(contract_address_const::<0>(), caller, amount);
    }

    #[external]
    fn approve(spender: ContractAddress, amount: u256) {
        let caller = get_caller_address();
        _approve(caller, spender, amount);
    }

    #[external]
    fn increase_allowance(spender: ContractAddress, added_value: u256) {
        let caller = get_caller_address();
        _approve(caller, spender, ERC20_allowance::read((caller, spender)) + added_value);
    }

    #[external]
    fn decrease_allowance(spender: ContractAddress, subtracted_value: u256) {
        let caller = get_caller_address();
        _approve(caller, spender, ERC20_allowance::read((caller, spender)) - subtracted_value);
    }


    // internal

    fn _transfer(sender: ContractAddress, recipient: ContractAddress, amount: u256) {
        assert(!sender.is_zero(), 'ERC20: transfer from 0');
        assert(!recipient.is_zero(), 'ERC20: transfer from 0');
        let sender_balance = ERC20_balance::read(sender);
        let recipient_balance = ERC20_balance::read(recipient);
        ERC20_balance::write(sender, sender_balance - amount);
        ERC20_balance::write(recipient, recipient_balance + amount);
        Transfer(sender, recipient, amount);
    }

    fn _approve(owner: ContractAddress, spender: ContractAddress, amount: u256) {
        assert(!spender.is_zero(), 'ERC20: approve from 0');
        ERC20_allowance::write((owner, spender), amount);
        Approval(owner, spender, amount);
    }
    fn _spend_allowance(owner: ContractAddress, spender: ContractAddress, amount: u256) {
        let current_allowance = ERC20_allowance::read((owner, spender));
        // These lines define a ONES_MASK constant that is a 128-bit integer with all bits set to 1. This is used to check if the allowance is unlimited. 
        let ONES_MASK = 0xffffffffffffffffffffffffffffffff_u128;
        let is_unlimited_allowance =
            current_allowance.low == ONES_MASK & current_allowance.high == ONES_MASK;
        if !is_unlimited_allowance {
            _approve(owner, spender, current_allowance - amount);
        }
    }
}

// unit test: testing individual functions
#[cfg(test)]
mod tests {
    use super::Token;

    #[test]
    #[available_gas(2000000)]
    fn test_constructor() {
        let name: felt252 = 'Starknet';
        let symbol: felt252 = 'ERC20S';
        let decimals: u8 = 18_u8;

        Token::constructor(name, symbol, decimals);
        assert(Token::name() == name, 'wrong names');
        assert(Token::symbol() == symbol, 'wrong symbol');
        assert(Token::decimals() == decimals, 'wrong decimal');
    }
}
