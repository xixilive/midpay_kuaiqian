require 'midpay'
module Midpay
  module Strategies
    class Kuaiqian
      
      GATEWAY = "https://www.99bill.com/gateway/recvMerchantInfoAction.htm"

      REQUEST_PARAM_KEYS = %w[
        inputCharset bgUrl pageUrl version language signType merchantAcctId
        payerName payerContactType payerContact orderId orderAmount orderTime
        productName productNum productId productDesc ext1 ext2 payType redoFlag pid
      ]

      RETURN_PARAM_KEYS = %w[
        merchantAcctId version language signType payType bankId orderId orderTime
        orderAmount dealId bankDealId dealTime payAmount fee ext1 ext2 payResult errorCode
      ]

      include Midpay::Strategy

      set :inputCharset, "1" #utf-8
      set :version, "v2.0"
      set :language, "1" #zh_CN
      set :signType, "1" #MD5
      set :payType, "00"
      set :redoFlag, "0"

      def request_phase response
        response.redirect kuaiqian_request_url
      end

      def callback_phase pi
        raise Midpay::Errors::InvalidSignature.new unless request_params[:sign] == request_params.sign(:signType){|h| kuaiqian_sign_str(RETURN_PARAM_KEYS,h) }
        pi.raw_data = request_params.symbolize_keys
        pi.success = (pi.raw_data['payResult'] == "10")
      end

      def kuaiqian_request_params
        params = request_data
        params.merge_if!(arguments.merge(merchantAcctId: options.app_key, pageUrl: callback_url))
        params.sign!(:signMsg, kuaiqian_sign_type(params[:signType])) do |hash|
          kuaiqian_sign_str(REQUEST_PARAM_KEYS, hash)
        end
      end

      def kuaiqian_request_url
        GATEWAY + '?' + kuaiqian_request_params.to_query
      end

      def kuaiqian_sign_str keys, hash
        keys.collect{|k| hash[k].to_s.empty? ? nil : [k, hash[k]]}.compact.push(["key",options.app_secret]).collect{|i| i.join("=") }.join("&")
      end

      def kuaiqian_sign_type sign_type
        {
          "1" => "MD5"
        }[sign_type.to_s]
      end
    end
  end
end
::Midpay[:kuaiqian] = ::Midpay::Strategies::Kuaiqian