require "magento2/api/version"

module Magento2::Api

  require 'curb'

  class << self

    def configure(consumer_key, consumer_secret, access_token, access_token_secret, host)
      self.consumer_key = consumer_key
      self.consumer_secret = consumer_secret
      self.access_token = access_token
      self.access_token_secret = access_token_secret
      self.host = host
    end

    def consumer_key
      RequestStore.store[:magento2_consumer_key]
    end

    def consumer_key=(value)
      RequestStore.store[:magento2_consumer_key] = value
    end

    def consumer_secret
      RequestStore.store[:magento2_consumer_secret]
    end

    def consumer_secret=(value)
      RequestStore.store[:magento2_consumer_secret] = value
    end

    def access_token
      RequestStore.store[:magento2_access_token]
    end

    def access_token=(value)
      RequestStore.store[:magento2_access_token] = value
    end

    def access_token_secret
      RequestStore.store[:magento2_access_token_secret]
    end

    def access_token_secret=(value)
      RequestStore.store[:magento2_access_token_secret] = value
    end

    def host
      RequestStore.store[:magento2_host]
    end

    def host=(value)
      RequestStore.store[:magento2_host] = value
    end

    def get(url, query = {})
        url = "#{self.host}#{url}"
        http = Curl.get(url, query) do |http|
            http.headers['Content-type'] = "application/json"
            http.headers['Authorization'] = auth('GET', url, query)
        end
        return { response_code: http.response_code, body: http.body_str } if http.response_code != 200
        eval(http.body_str.gsub('null', 'nil'))
    end

    def delete(url)
        url = "#{self.host}#{url}"
        http = Curl.delete(url) do |http|
            http.headers['Content-type'] = "application/json"
            http.headers['Authorization'] = auth('DELETE', url)
        end
        return { response_code: http.response_code, body: http.body_str } if http.response_code != 200
        eval(http.body_str.gsub('null', 'nil'))
    end

    def post(url, body)
        url = "#{self.host}#{url}"
        http = Curl.post(url, body.to_json) do |http|
            http.headers['Content-type'] = "application/json"
            http.headers['Authorization'] = auth('POST', url)
        end
        return { response_code: http.response_code, body: http.body_str } if http.response_code != 200
        eval(http.body_str.gsub('null', 'nil'))
    end

    def put(url, body)
        url = "#{self.host}#{url}"
        http = Curl.put(url, body.to_json) do |http|
            http.headers['Content-type'] = "application/json"
            http.headers['Authorization'] = auth('PUT', url)
        end
        return { response_code: http.response_code, body: http.body_str } if http.response_code != 200
        eval(http.body_str.gsub('null', 'nil'))
    end

    private

    def auth(method, url, query = {})
      if self.consumer_key.present? and self.consumer_secret.present? and self.access_token_secret.present?
        data = {
            'oauth_consumer_key' => self.consumer_key,
            'oauth_nonce' => Digest::MD5.hexdigest(Random.new.rand.to_s),
            'oauth_signature_method' => 'HMAC-SHA1',
            'oauth_timestamp' => Time.new.to_i,
            'oauth_token' => self.access_token,
            'oauth_version' => '1.0'
        }.merge!(query)
        data['oauth_signature'] = sign(method, url, data, self.consumer_secret, self.access_token_secret)
        authorization = "OAuth #{http_build_query(data, ',')}"
      else
        authorization = "Bearer #{self.access_token}"        
      end

      return authorization
    end

    def urlEncodeAsZend(value)
        ERB::Util.url_encode(value).gsub('%7E', '~')
    end

    def sign(method, url, data, consumerSecret, accessTokenSecret)
        url = urlEncodeAsZend(url)
        data = urlEncodeAsZend(http_build_query(data))
        data = [method, url, data].join('&')
        secret = [consumerSecret, accessTokenSecret].join('&')
        [OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), secret, data)].pack("m").strip
    end

    def http_build_query(object, separator = nil)
      h = hashify(object)
      result = ""
      separator = '&' if separator.nil?
      h.keys.sort.each do |key|
        result << (CGI.escape(key) + '=' + CGI.escape(h[key]) + separator)
      end
      result = result.sub(/#{separator}$/, '') # Remove the trailing k-v separator
      return result
    end

    def hashify(object, parent_key = '')
      raise ArgumentError.new('This is made for serializing Hashes and Arrays only') unless (object.is_a?(Hash) or object.is_a?(Array) or parent_key.length > 0)
      result = {}
      case object
        when String, Symbol, Numeric
          result[parent_key] = object.to_s
        when Hash
          # Recursively call hashify, building closure-like state by
          # appending the current location in the tree as new "parent_key"
          # values.
          hashes = object.map do |key, value|
            if parent_key =~ /^[0-9]+/ or parent_key.length == 0
              new_parent_key = key.to_s
            else
              new_parent_key = parent_key + '[' + key.to_s + ']'
            end
            hashify(value, new_parent_key)
          end
          hash = hashes.reduce { |memo, hash| memo.merge hash }
          result.merge! hash
        when Enumerable
          # _Very_ similar to above, but iterating with "each_with_index"
          hashes = {}
          object.each_with_index do |value, index|
            if parent_key.length == 0
              new_parent_key = index.to_s
            else
              new_parent_key = parent_key + '[' + index.to_s + ']'
            end
            hashes.merge! hashify(value, new_parent_key)
          end
          result.merge! hashes
        else
          raise Exception.new("This should only be serializing Strings, Symbols, Boolean, or Numerics.")
      end
      return result
    end
  end

end
