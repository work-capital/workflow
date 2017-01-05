defmodule Workflow.Domain.Account do
  defstruct [
    account_number: nil,
    balance: 0,
    state: nil,
  ]

  alias Workflow.Domain.Account

  defmodule Commands do
    defmodule OpenAccount,        do: defstruct [:account_number, :initial_balance]
    defmodule DepositMoney,       do: defstruct [:account_number, :transfer_uuid, :amount]
    defmodule WithdrawMoney,      do: defstruct [:account_number, :transfer_uuid, :amount]
    defmodule CloseAccount,       do: defstruct [:account_number]
  end

  defmodule Events do
    defmodule AccountOpened,      do: defstruct [:account_number, :initial_balance]
    defmodule MoneyDeposited,     do: defstruct [:account_number, :transfer_uuid, :amount, :balance]
    defmodule MoneyWithdrawn,     do: defstruct [:account_number, :transfer_uuid, :amount, :balance]
    defmodule AccountOverdrawn,   do: defstruct [:account_number, :balance]
    defmodule AccountClosed,      do: defstruct [:account_number]
  end

  alias Commands.{OpenAccount,DepositMoney,WithdrawMoney,CloseAccount}
  alias Events.{AccountOpened,MoneyDeposited,MoneyWithdrawn,AccountOverdrawn,AccountClosed}

  def handle(%Account{state: nil}, 
    %OpenAccount{account_number: account_number, initial_balance: initial_balance})
    when is_number(initial_balance) and initial_balance > 0 do
      %AccountOpened{account_number: account_number, initial_balance: initial_balance}
  end

  def handle(%Account{state: :active, balance: balance}, 
    %DepositMoney{account_number: account_number, transfer_uuid: transfer_uuid, amount: amount})
    when is_number(amount) and amount > 0 do
      balance = balance + amount
      %MoneyDeposited{account_number: account_number, transfer_uuid: transfer_uuid, amount: amount, balance: balance}
  end

  def handle(%Account{state: :active, balance: balance}, 
    %WithdrawMoney{account_number: account_number, transfer_uuid: transfer_uuid, amount: amount})
    when is_number(amount) and amount > 0 do
      case balance - amount do
        balance when balance < 0 ->
          [
            %MoneyWithdrawn{account_number: account_number, transfer_uuid: transfer_uuid, amount: amount, balance: balance},
            %AccountOverdrawn{account_number: account_number, balance: balance},
          ]
        balance ->
          %MoneyWithdrawn{account_number: account_number, transfer_uuid: transfer_uuid, amount: amount, balance: balance}
      end
  end

  def handle(%Account{state: :active}, 
    %CloseAccount{account_number: account_number}), do: %AccountClosed{account_number: account_number}

  # state mutatators

  def apply(%Account{} = state, %AccountOpened{account_number: account_number, initial_balance: initial_balance}) do
    %Account{state |
      account_number: account_number,
      balance: initial_balance,
      state: :active,
    }
  end

  def apply(%Account{} = state, %MoneyDeposited{balance: balance}), do: %Account{state | balance: balance}
  def apply(%Account{} = state, %MoneyWithdrawn{balance: balance}), do: %Account{state | balance: balance}
  def apply(%Account{} = state, %AccountOverdrawn{}), do: state
  def apply(%Account{} = state, %AccountClosed{}) do
    %Account{state |
      state: :closed,
    }
  end
end
