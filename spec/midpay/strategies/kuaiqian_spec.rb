require 'spec_helper'

describe Midpay::Strategies::Kuaiqian do
  include Rack::Test::Methods

  let(:inner_app){
    lambda { |env| [200, {"Content-Type" => "text/html"}, ["body"]] }
  }

  let(:app){
    Midpay::Strategies::Kuaiqian.new(inner_app, 
      :app_key => "APPKEY", 
      :app_secret => "APPSECRET", 
      :request_params_proc => Proc.new{|params|
        {
          :orderId => params['order_id'],
          :orderAmount => 1,
          :orderTime => "20130710154023",
          :productName => "product name",
          :productNum => 1,
          :productDesc=> "product desc"
        }
      }
    )
  }

  let(:query_data){
    {
      "merchantAcctId"=>"1002109591401", "version"=>"v2.0", "language"=>"1", "signType"=>"1", 
      "payType"=>"10", "bankId"=>"CCB", "orderId"=>"5094e515bcc1261dc1000013", "orderTime"=>"20121103173413", 
      "orderAmount"=>"20500", "dealId"=>"783157316", "bankDealId"=>"121103701336", "dealTime"=>"20121103173749", 
      "payAmount"=>"20500", "fee"=>"123", "payResult"=>"10", "signMsg" => "777bea3ae5c45d311eda964d4c76e276"
    }
  }

  let(:query){
    query_data.to_a.collect{|i| i.join("=") }.join("&")
  }

  it 'request phase' do
    get '/midpay/kuaiqian?order_id=123456'
    expect(last_response.headers["Location"]).to eq("https://www.99bill.com/gateway/recvMerchantInfoAction.htm?inputCharset=1&language=1&merchantAcctId=APPKEY&orderAmount=1&orderId=123456&orderTime=20130710154023&pageUrl=http%3A%2F%2Fexample.org%2Fmidpay%2Fkuaiqian%2Fcallback&payType=00&productDesc=product+desc&productName=product+name&productNum=1&redoFlag=0&signMsg=b161c0227172e3529eb10b193ce79f62&signType=1&version=v2.0")
  end

  it 'callback phase' do
    get "/midpay/kuaiqian/callback?#{query}"
    expect(last_request.env['midpay.callback'].pay).to eq("kuaiqian")
    expect(last_request.env['midpay.callback'].raw_data).to eq(query_data)
    expect(last_request.env['midpay.callback'].success?).to be_true
  end

end