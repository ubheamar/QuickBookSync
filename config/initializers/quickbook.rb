OAUTH_CONSUMER_KEY = "qyprdrGK7Io1zSYsY4pjxqRSM0wfFF"
OAUTH_CONSUMER_SECRET = "A2hUTAjtw8lN6srSysJ2BZUC2w2958ECAEYEfDI6"

::QB_OAUTH_CONSUMER = OAuth::Consumer.new(OAUTH_CONSUMER_KEY, OAUTH_CONSUMER_SECRET, {
    :site                 => "https://oauth.intuit.com",
    :request_token_path   => "/oauth/v1/get_request_token",
    :authorize_url        => "https://appcenter.intuit.com/Connect/Begin",
    :access_token_path    => "/oauth/v1/get_access_token"
})
