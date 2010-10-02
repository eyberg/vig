require 'net/http'
require 'net/https'

email = ""
password = ""

http = Net::HTTP.new('www.google.com', 443)
http.use_ssl = true
path = '/accounts/ClientLogin'
headers = {'Content-Type'=> 'application/x-www-form-urlencoded'}
blah = "accountType=HOSTED_OR_GOOGLE&Email=#{email}&Passwd=#{password}&service=cl&source=github-vig-0.1"
resp, data = http.post(path, blah, headers)

puts data 
