# frozen_string_literal: true

class RemitService
  class InsufficientBalanceError < StandardError; end

  class << self
    def execute!(remit_request)
      ActiveRecord::Base.transaction do
        user_balance = remit_request.user.balance
        requested_user_balance = remit_request.requested_user.balance

        # 整合性を担保するため、悲観的ロックをかける
        # # 悲観的ロックの理由
        # ## Balance
        # 送金処理中に残高が減ってしまい、本来送金できるべきではないのに送金できてしまうことを防ぐため
        #
        # ## RemitRequest
        # 送金処理中にRemitRequestが削除等され、RemitRequestが存在しない状態で送金処理が行われないようにするため
        lock_targets = [remit_request, user_balance, requested_user_balance]
        aquire_lock!(lock_targets)

        raise InsufficientBalanceError unless can_remit?(requested_user_balance, remit_request.amount)

        transfer_balance!(user_balance, requested_user_balance, remit_request.amount)
        remit_request.finalize!(RemitRequestResult::RESULT_ACCEPTED)
      end
    end

    private

    def can_remit?(requested_user_balance, amount)
      requested_user_balance.can_withdraw?(amount)
    end

    def transfer_balance!(user_balance, requested_user_balance, amount)
      requested_user_balance.withdraw!(amount)
      user_balance.deposit!(amount)
    end

    # 整合性を担保するため悲観的行ロックを獲得する
    # デッドロックを防ぐため、id昇順にロックを獲得していく
    def aquire_lock!(balances)
      balances.sort_by(&:id).each(&:lock!)
    end
  end
end
