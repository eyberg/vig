require 'rubygems'
require 'uri'
require 'net/http'
require 'net/https'
require 'yaml'

class GoogleConnect
  attr_accessor :auth_token

  def initialize
    creds = YAML::load(File.open('creds.yml'))

    user, pass = creds.collect{ |k,v| v }

    authenticate(user, pass)
  end

  def authenticate(user, pass)
    http = Net::HTTP.new('www.google.com', 443)
    http.use_ssl = true
    path = '/accounts/ClientLogin'
    headers = {'Content-Type' => 'application/x-www-form-urlencoded'}
    blah = "accountType=HOSTED_OR_GOOGLE&Email=#{user}&Passwd=#{pass}&service=writely&source=github-vig-0.1"
    resp, data = http.post(path, blah, headers)

    unless !resp.code.eql? 200
      puts 'oh noes!'
      exit
    end

    kvs = data.split

    self.auth_token = kvs.last.split("=").last
  end

  # upload new blank document
  def create_new
    http = Net::HTTP.new('docs.google.com', 443)
    http.use_ssl = true
    path = '/feeds/default/private/full'
    headers = {
      'Content-Type' => 'application/x-www-form-urlencoded',
      'Host' => 'docs.google.com',
      'GData-Version' => '3.0',
      'Content-Length' => '287',
      'Content-Type' => 'application/atom+xml',
      'Authorization' => "GoogleLogin auth=#{self.auth_token}"
    }

data =<<END
<?xml version='1.0' encoding='UTF-8'?>
<entry xmlns="http://www.w3.org/2005/Atom">
  <category scheme="http://schemas.google.com/g/2005#kind"
      term="http://schemas.google.com/docs/2007#document"/>
  <title>new document</title>
</entry>
END

    resp, data = http.post(path, data, headers)

    puts data
  end

  # list documents
  def list_documents
    url = URI.parse('https://docs.google.com/feeds/default/private/full')

    req = Net::HTTP::Get.new(url.path)

    puts self.auth_token
    req.add_field("Authorization", "GoogleLogin auth=#{self.auth_token}")
    req.add_field("GData-Version", "3.0")

    http = Net::HTTP.new(url.host, url.port) #.start do |http|
    http.use_ssl = true
    res = http.request(req)

    puts res.body
  end

end

gc = GoogleConnect.new
#gc.create_new
gc.list_documents
