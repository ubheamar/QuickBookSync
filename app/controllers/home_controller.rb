class HomeController < ApplicationController
  def index

  end
  def authenticate
    callback = url_for(:controller=>'home',:action=>'oauth_callback')
    token = QB_OAUTH_CONSUMER.get_request_token(:oauth_callback => callback)
    session[:qb_request_token] = Marshal.dump(token)
    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}") and return
  end
  def oauth_callback
    session_token = Marshal.load(session[:qb_request_token]).get_access_token(:oauth_verifier => params[:oauth_verifier])
    token = session_token.token
    secret = session_token.secret
    realm_id = params['realmId']
    token_model = Token.where(id:1).first_or_initialize
    token_model.access_token = token
    token_model.access_secret = secret
    token_model.company_id = realm_id
    token_model.token_expires_at = 6.months.from_now.utc
    token_model.save
    redirect_to action: 'index'
    # store the token, secret & RealmID somewhere for this user, you will need all 3 to work with Quickbooks-Ruby
  end
end
