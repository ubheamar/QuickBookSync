class TransactionController < ApplicationController
  def index
    begin
      @error =Array.new
      mode = "all"
      type = "expense"
      type = params[:type]
      mode = params[:mode]
      Quickbooks.sandbox_mode = true
      tokenModel = Token.find(1)
      unless tokenModel.nil?
        access_token = OAuth::AccessToken.new(QB_OAUTH_CONSUMER, tokenModel.access_token, tokenModel.access_secret)
        realmid = tokenModel.company_id
        if type == "expense"
          getPurchase(realmid, access_token, mode)
        elsif type == "bill"
          getBills(realmid, access_token, mode)
        elsif type=="journalentry"
          getJournelEntry(realmid, access_token, mode)
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


  def getJournelEntry(realmid, access_token, mode)
    query = "select * from JournalEntry"
    if mode == "oneday"
      date = Date.yesterday.strftime("%F")
      query = "select * from JournalEntry Where Metadata.CreateTime > '#{date}'"
      create_JournelEntry(query, realmid, access_token, @error)
      query = "select * from JournalEntry Where Metadata.LastUpdatedTime > '#{date}'"
      create_JournelEntry(query, realmid, access_token, @error)
    else
      create_JournelEntry(query, realmid, access_token, @error)
    end
  end

  def getPurchase(realmid, access_token, mode)
    query = "select * from Purchase"
    if mode == "oneday"
      date = Date.yesterday.strftime("%F")
      query = "select * from Purchase Where Metadata.CreateTime > '#{date}'"
      create_purchase(query, realmid, access_token, @error)
      query = "select * from Purchase Where Metadata.LastUpdatedTime > '#{date}'"
      create_purchase(query, realmid, access_token, @error)
    else
      create_purchase(query, realmid, access_token, @error)
    end
  end

  def getBills(realmid, access_token, mode)
    query = "select * from Bill"
    if mode == "oneday"
      date = Date.yesterday.strftime("%F")
      query = "select * from Bill where Metadata.CreateTime > '#{date}'"
      create_bill(query, realmid, access_token, @error)
      query = "select * from Bill where Metadata.LastUpdatedTime > '#{date}'"
      create_bill(query, realmid, access_token, @error)
    else
      create_bill(query, realmid, access_token, @error)
    end
  end

  def create_bill(query, realmid, access_token, error)
    bill_service = Quickbooks::Service::Bill.new
    bill_service.access_token = access_token
    bill_service.company_id = realmid
    bill_service.query_in_batches(query, per_page: 1000) do |batch|
      batch.each do |bill|
        unless bill.line_items.empty?
          bill.line_items.each do |key, array|
            txn_id = "#{bill.id}#Bill##{key.id}"
            transaction = Transaction.where(txn_id: txn_id).first_or_initialize
            transaction.txn_date = bill.txn_date
            if (defined? bill.department_ref.name)
              transaction.dept = bill.department_ref.name
            end
            if (defined? bill.ap_account_ref.value)
              transaction.account_name = bill.ap_account_ref.value
            end
            if (defined? bill.vendor_ref.name)
              transaction.vendor_name = bill.vendor_ref.name
            end
            transaction.txn_id= txn_id
            transaction.txn_type = "Bill"
            if (defined? key.account_based_expense_line_detail.class_ref.name)
              transaction.klass = key.account_based_expense_line_detail.class_ref.name
            end
            transaction.desc = key.description
            transaction.amount = key.amount
            if transaction.save
              @error.push(Error.new("s","Bill id= #{transaction.id},txn_type=#{transaction.txn_type}"))
            else
              @error.push(Error.new("e","Bill id= #{transaction.id},txn_type=#{transaction.txn_type}"))
            end
          end
        end
      end
    end
  end

  def create_JournelEntry(query, realmid, access_token, error)
    journalentry_service = Quickbooks::Service::JournalEntry.new
    journalentry_service.access_token = access_token
    journalentry_service.company_id = realmid
    journalentry_service.query_in_batches(query, per_page: 1000) do |batch|
      batch.each do |journalentry|
        unless journalentry.line_items.empty?
          journalentry.line_items.each do |key, array|
            txn_id = "#{journalentry.id}#JournalEntry##{key.id}"
            transaction = Transaction.where(txn_id: txn_id).first_or_initialize
            transaction.txn_date = journalentry.txn_date
            if (defined? key.journal_entry_line_detail.department_ref.name)
              transaction.dept = key.journal_entry_line_detail.department_ref.name
            end
            if (defined? key.journal_entry_line_detail.account_ref)
              transaction.account_name = key.journal_entry_line_detail.account_ref.value
            end
            if (defined? key.journal_entry_line_detail.vendor_ref.name)
              transaction.vendor_name = key.journal_entry_line_detail.vendor_ref.name
            end
            transaction.txn_id= txn_id
            transaction.txn_type = "JournalEntry"
            if (defined? key.journal_entry_line_detail.class_ref.name)
              transaction.klass = key.journal_entry_line_detail.class_ref.name
            end
            transaction.desc = key.description
            transaction.amount = key.amount
            if transaction.save
              @error.push(Error.new("s","JournalEntry id= #{transaction.id},txn_type=#{transaction.txn_type}"))
            else
              @error.push(Error.new("e","JournalEntry id= #{transaction.id},txn_type=#{transaction.txn_type}"))
            end
          end
        end
      end
    end
  end

  def create_purchase(query, realmid, access_token, error)
    purchase_service = Quickbooks::Service::Purchase.new
    purchase_service.access_token = access_token
    purchase_service.company_id = realmid
    purchase_service.query_in_batches(query, per_page: 1000) do |batch|
      batch.each do |purchase|
        unless purchase.line_items.empty?
          purchase.line_items.each do |key, array|
            txn_id = "#{purchase.id}#Expense##{key.id}"
            transaction = Transaction.where(txn_id: txn_id).first_or_initialize
            transaction.txn_type = "Expense"
            transaction.txn_date = purchase.txn_date
            if (defined? purchase.department_ref.name)
              transaction.dept = purchase.department_ref.name
            end
            if (defined? purchase.class_ref.name)
              transaction.klass = purchase.class_ref.name
            end
            if (defined? purchase.account_ref.value)
              transaction.account_name = purchase.account_ref.value
            end
            if (defined? purchase.entity_ref.name)
              transaction.vendor_name = purchase.entity_ref.name
            end

            transaction.desc = key.description
            transaction.amount = key.amount
            if transaction.save
              @error.push(Error.new("s","Expense id= #{transaction.id},txn_type=#{transaction.txn_type}"))
            else
              @error.push(Error.new("e","Expense id= #{transaction.id},txn_type=#{transaction.txn_type}"))
            end
          end
        end
      end
    end

  end

end
