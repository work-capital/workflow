defmodule Engine.Example.Account do
  use Engine.Aggregate, fields: [account_number: nil, balance: 0, is_active?: false]
  alias Engine.Example.Account


  ### ALIASES
  alias Engine.Example.Account.Commands.{OpenAccount,DepositMoney,WithdrawMoney,CloseAccount}
  alias Engine.Example.Account.Event.{AccountOpened,MoneyDeposited,MoneyWithdrawn,AccountClosed}

  ### API
  def open_account(%Account{state: %{is_active?: true}}, %OpenAccount{}), do: {:error, :account_already_open}
  def open_account(%Account{state: %{is_active?: false}} = account, 
                   %OpenAccount{account_number: account_number, initial_balance: initial_balance})
                        when is_number(initial_balance) and initial_balance > 0 do
    account = account |> update(%AccountOpened{account_number: account_number, initial_balance: initial_balance})
    {:ok, account}
  end


  def deposit(%Account{} = account, 
              %DepositMoney{account_number: account_number, 
                            transfer_uuid: transfer_uuid, 
                            amount: amount, 
                            source: source})
              when is_number(amount) and amount > 0 do
    balance = account.state.balance + amount
    account = account |> update(%MoneyDeposited{account_number: account_number,
                                transfer_uuid: transfer_uuid, amount: amount, balance: balance, source: source})
    {:ok, account}
  end


  def withdraw(%Account{} = account, 
               %WithdrawMoney{account_number: account_number, 
                              transfer_uuid: transfer_uuid, 
                              amount: amount,
                              target: target})
               when is_number(amount) and amount > 0 do
    balance = account.state.balance - amount
    account = account |> update(%MoneyWithdrawn{account_number: account_number,
                                transfer_uuid: transfer_uuid, amount: amount, balance: balance, target: target})
    {:ok, account}
  end

  def close_account(%Account{state: %{is_active?: false}},          %OpenAccount{}), do: {:error, :account_already_closed}
  def close_account(%Account{state: %{is_active?: true}} = account, %CloseAccount{account_number: account_number}) do
    account = account
      |> update(%AccountClosed{account_number: account_number})
    {:ok, account}
  end

  ### STATE MUTATORS
  def apply(%Account.State{} = state, %AccountOpened{} = account_opened) do
    %Account.State{state |
      account_number: account_opened.account_number,
      balance: account_opened.initial_balance,
      is_active?: true,
    }
  end

  def apply(%Account.State{} = state, %MoneyDeposited{} = money_deposited) do
    %Account.State{state |
      balance: money_deposited.balance
    }
  end

  def apply(%Account.State{} = state, %MoneyWithdrawn{} = money_withdrawn) do
    %Account.State{state |
      balance: money_withdrawn.balance
    }
  end

  def apply(%Account.State{} = state, %AccountClosed{}) do
    %Account.State{state |
      is_active?: false,
    }
  end
end
