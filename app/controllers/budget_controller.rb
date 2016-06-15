class BudgetController < ApplicationController

  def index
    begin
      @error =Array.new
      tokenModel = Token.find(1)
      unless tokenModel.nil?
        access_token = OAuth::AccessToken.new(QB_OAUTH_CONSUMER, tokenModel.access_token, tokenModel.access_secret)
        realmid = tokenModel.company_id
        mode = "all"
        query = "select * from Account"
        if mode == "oneday"
          date = Date.yesterday.strftime("%F")
          query = "select * from Account where Metadata.CreateTime > '#{date}'"
          create_budget(query, realmid, access_token, @error)
          query = "select * from Account where Metadata.LastUpdatedTime > '#{date}'"
          create_budget(query, realmid, access_token, @error)
        else
          create_budget(query, realmid, access_token, @error)
        end
      else
        @error.push(Error.new("e", "No token stored in database.please login."))
      end
    rescue Exception => e
      @error.push(Error.new("e",e.message.to_s))
      puts e.message
      puts e.backtrace.inspect
    end
  end

  def create_budget(query, realmid, access_token, error)
    account_service = Quickbooks::Service::Account.new
    account_service.access_token = access_token
    account_service.company_id = realmid
    account_service.query_in_batches(query, per_page: 1000) do |batch|
      batch.each do |account|
        if account.active?
          budget = Budget.where(id: account.id).first_or_initialize
          budget.id= account.id
          budget.name = account.name
          if account.sub_account?
            budget.parent_id = account.parent_ref.value
          else
            budget.parent_id = ""
          end
          if budget.save
            @error.push(Error.new("s","id=#{account.id},name=#{account.name}"))
          else
            @error.push(Error.new("e","id= #{account.id},name=#{account.name}"))
          end
        else
          @error.push(Error.new("w","id= #{account.id},name=#{account.name}"))
        end
      end
    end
  end
end
