class ProfitLossController < ApplicationController
  def index
    @errors =Array.new
    begin
      oauth_consumer_key = "qyprdrGK7Io1zSYsY4pjxqRSM0wfFF"
      oauth_consumer_secret = "A2hUTAjtw8lN6srSysJ2BZUC2w2958ECAEYEfDI6"
      access_token ="qyprdPmhoKQwEaChiLhjwHZhIo5hGCxw1reWwBS3lZ6061ZZ"
      access_token_secret="P7vAbqmos9fqp6iPl9AGS3ngnMZGc2EvTmQVv732"
      realmid ="123145804749202"
      Quickbooks.sandbox_mode = true
      qb_oauth_consumer = OAuth::Consumer.new(oauth_consumer_key, oauth_consumer_secret, {
          :site => "https://oauth.intuit.com",
          :request_token_path => "/oauth/v1/get_request_token",
          :authorize_url => "https://appcenter.intuit.com/Connect/Begin",
          :access_token_path => "/oauth/v1/get_access_token"
      })
      access_token = OAuth::AccessToken.new(qb_oauth_consumer, access_token, access_token_secret)
      report = Quickbooks::Service::Reports.new
      report.company_id = realmid
      report.access_token = access_token
      paramters = {'start_date' => '2016-01-01', 'end_date' => '2020-06-30', 'columns' => 'txn_id,tx_date,txn_type,doc_num,name,klass_name,dept_name,split_acc,memo,subt_nat_amount'}
      data = report.query("ProfitAndLossDetail", "", paramters)
      hashData = Hash.from_xml(data.xml.to_s)
      check_for_data(hashData["Report"]["Rows"]["Row"])
      puts hashData.inspect
    rescue Exception => e
      @errors.push(e.message.to_s)
      puts e.message
      puts e.backtrace.inspect
    end
  end

  def check_for_data(row)
    begin
      unless row.nil?
        temp_row = row
        row.each do |key, value|
          if key.include?("type")
            if key["type"] == "Section"
              if key["Rows"] && key["Rows"]["Row"]
                check_for_data(key["Rows"]["Row"])
              end
            elsif key["type"] == "Data"
              colData = key["ColData"]
              puts colData.inspect
            end
          end
        end
      end
    rescue Exception => e
      @errors.push(e.message.to_s)
      puts e.message
      puts e.backtrace.inspect
    end
  end
end
