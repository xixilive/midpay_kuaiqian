lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'midpay/kuaiqian/version'
require 'midpay/strategies/kuaiqian'
