import credits.aleo;
import token_registry.aleo;

program omerozer_mytoken11122222.aleo {
  const my_token_id: field = 71619063553950105623579field;
  const ADMIN_ADDRESS: address = aleo1xupj2km9048avhkn7vwld4ewv2s4fmzp3zqmsp5p5gmmjfcgguysd29enp;
  const MAX_SUPPLY: u128 = 1_000_000_000_000u128;
  const BLOCKS_IN_A_DAY: u32 = 28_500u32;
  const MAX_SPEND_PER_DAY: u128 = 5_000_000_000u128;
  const MAX_U32: u32 = 4294967295u32;

  record SpendLimit {
    owner: address,
    amount_spent: u128,
    epoch_spent: u32
  }

  mapping has_minted: u8 => bool;
  
  mapping has_spend_limit: field => bool;

  async transition initialize() -> Future {
    assert_eq(self.caller, ADMIN_ADDRESS);

    let name: u128 = 71619063553950105623531u128;
    let symbol: u128 = 71619063553950105623531u128;
    let decimals: u8 = 6u8;
    let max_supply: u128 = 1_000_000_000_000u128;
    let external_authorization_required: bool = true;
    let external_authorization_party: address = self.address;

    let f0: Future = token_registry.aleo/register_token(
      my_token_id,
      name,
      symbol,
      decimals,
      max_supply,
      external_authorization_required,
      external_authorization_party
    );

    return finalize_register_token(f0);
  }

  async function finalize_register_token(f0: Future) {
    f0.await();
  }

  async transition mint_private() -> (token_registry.aleo/Token, Future) {
    assert_eq(self.caller, ADMIN_ADDRESS);
    
    let mint_output: (token_registry.aleo/Token, Future) = token_registry.aleo/mint_private(
      my_token_id,
      ADMIN_ADDRESS,
      MAX_SUPPLY,
      true,
      MAX_U32
    );

    return (mint_output.0, finalize_mint_private(mint_output.1));
  }

  async function finalize_mint_private(f0: Future) {
    f0.await();

    let has_already_minted: bool = has_minted.contains(0u8);
    assert(!has_already_minted);
    has_minted.set(0u8, true);
  }

  transition issue_limit(
    owner: address
  ) -> SpendLimit {
    assert_eq(self.caller, ADMIN_ADDRESS);

    return SpendLimit {
      owner: owner,
      amount_spent: 0u128,
      epoch_spent: 0u32
    };
  }

  async transition transfer_private(
    input_token: token_registry.aleo/Token,
    spend_limit: SpendLimit,
    amount: u128,
    recipient: address,
    public epoch: u32
  ) -> (SpendLimit, token_registry.aleo/Token, token_registry.aleo/Token, token_registry.aleo/Token, Future) {
    
    let updated_amount_spent: u128 = spend_limit.epoch_spent < epoch 
        ? amount
        : amount + spend_limit.amount_spent;
    
    assert(updated_amount_spent <= MAX_SPEND_PER_DAY);

    let updated_spend_limit: SpendLimit = SpendLimit {
      owner: spend_limit.owner,
      amount_spent: updated_amount_spent,
      epoch_spent: epoch
    };

    let prehook_output: (token_registry.aleo/Token, token_registry.aleo/Token, Future) = token_registry.aleo/prehook_private(
      input_token,
      amount,
      MAX_U32
    );

    let transfer_output: (token_registry.aleo/Token, token_registry.aleo/Token, Future) = token_registry.aleo/transfer_private(
      recipient,
      amount,
      prehook_output.1
    );

    return (
      updated_spend_limit,
      prehook_output.0,
      transfer_output.0,
      transfer_output.1,
      finalize_transfer_private(prehook_output.2, transfer_output.2, epoch)
    );
  }

  async function finalize_transfer_private(
    f0: Future,
    f1: Future,
    epoch: u32
  ) {
    f0.await();
    f1.await();

    let current_epoch: u32 = block.height % BLOCKS_IN_A_DAY;
    assert_eq(epoch, current_epoch);
  }
}