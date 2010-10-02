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
    blah = "accountType=HOSTED_OR_GOOGLE&Email=#{user}&Passwd=#{pass}&service=cl&source=github-vig-0.1"
    resp, data = http.post(path, blah, headers)

    unless !resp.code.eql? 200
      puts 'oh noes!'
      exit
    end

    kvs = data.split

    self.auth_token = kvs.last.split("=").last
  end

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
gc.list_documents
