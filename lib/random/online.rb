# = RealRand
#
# Author::    Maik Schmidt <contact@maik-schmidt.de>
# Copyright:: Copyright (c) 2003-2011 Maik Schmidt
# License::   Distributes under the same terms as Ruby.
#

require 'net/http'

module RealRand
  class OnlineGenerator
    attr_reader :host
    attr_accessor :proxy_host, :proxy_port, :proxy_usr, :proxy_pwd

    def initialize(host)
      @host = host
      @proxy_host = nil
      @proxy_port = -1
      @proxy_usr = nil
      @proxy_pwd = nil
    end

    protected 

    def get_response(script, parameters)
      Net::HTTP::Proxy(
        @proxy_host,
        @proxy_port,
        @proxy_usr,
        @proxy_pwd
      ).start(@host) { |h|
        response = h.get("#{script}?#{parameters}")
        if response.class == Net::HTTPOK
          return check_response(response)
        else
          handle_response_error(response)
        end
      }
    end
    
    protected
    
    def  check_response(response)
      return response
    end
    
    def  handle_response_error(response)         
      raise "An HTTP error occured."
    end
  end
  
  class RandomOrg < OnlineGenerator
    def initialize
      super("www.random.org")
    end

    def randnum(num = 100, min = 1, max = 100, args = {})
      check_amount_requested(num)
      check_min_max_range(min, max)

      parameters = "num=#{num}&min=#{min}&max=#{max}&col=#{num}"
      parameters << "&format=plain&base=10"
      parameters << "&rnd=#{args[:rnd]}" if args[:rnd]
      
      response = get_response("/integers/", parameters)
      convert_result(response.body)
    end
    alias :integers :randnum

    ##
    # Note: randbyte is deprecated, should use '/integers/' instead.
    # Network load decrease if using hex format instead here?
    def randbyte(nbytes = 256)
      if nbytes <= 0 || nbytes > 16_384
        raise RangeError, "Invalid amount: #{nbytes}."
      end
      return [] if nbytes == 0
      parameters = "nbytes=#{nbytes}&format=d"
      response = get_response("/cgi-bin/randbyte", parameters)
      convert_result(response.body)
    end

    def randseq(min = 1, max = 100, args = {})
      check_min_max_range(min, max)
      
      parameters = "min=#{min}&max=#{max}&col=1"
      parameters << "&format=plain" # TODO: No need for "&base=10" here?
      parameters << "&rnd=#{args[:rnd]}" if args[:rnd]
      
      response = get_response("/sequences/", parameters)
      convert_result(response.body)
    end
    alias :sequences :randseq


    def randstring(num, len, args = {})
      default_args = { 
          :digits => :on, 
          :upperalpha =>:on, 
          :loweralpha =>:on,
          :unique => :off,
          # :rnd => :new
        }
      args = default_args.update(args)

      check_amount_requested(num)
      check_num_within(len, 1, 20, 'length')

      parameters = "num=#{num}&len=#{len}&format=plain"
      parameters << "&" << hash_args_to_params(args)
      
      response = get_response("/strings/", parameters)
      response.body.split
    end
    alias :strings :randstring
    

    def quota(ip=nil)
      parameters = "format=plain"
      parameters += "&ip=#{ip}" if ip
      response = get_response("/quota/", parameters)
      convert_result(response.body).first
    end
    
    protected
    
    def  check_response(response)
      # RandomOrg returns 200 OK even for failures...
      error = contains_error(response.body)
      handle_response_error(response, error.to_s) if error
      return response
    end

    def  handle_response_error(response, message = nil)
      unless message then
        # Check the response body for an error message.
        error = contains_error(response.body)
        message = error.to_s if error
      end
      message ||= "An HTTP error occured."
      raise message
    end
    
    def contains_error(body)
      body.match(/error:.*/i)
    end
    
    private

    def convert_result(response)
      result = []
      response.each_line { |line|
        result += line.chomp.split.map { |x| x.to_i }
      }
      result
    end
    
    
    def hash_args_to_params(args)
      args.collect{|k,v| "#{k}=#{v}"}.join('&')
    end
    
    def check_amount_requested(num)
      check_num_within(num, 1, 10_000, 'amount')
    end
    
    def check_num_within(num, min, max, desc = "number")
      raise RangeError, "Invalid #{desc}: #{num}." if num < min || num > max
    end
    
    def check_min_max_range(min, max)
      if min < -1_000_000_000
        raise RangeError, "Invalid minimum: #{min}."
      end
      if max > 1_000_000_000
        raise RangeError, "Invalid maximum: #{max}."
      end
      if max <= min
        raise RangeError, "Maximum has to be bigger than minimum."
      end
    end
    
  end

  class FourmiLab < OnlineGenerator
    def initialize
      super("www.fourmilab.ch")
    end

    def randbyte(nbytes = 128)
      if nbytes < 0 || nbytes > 2048
        raise RangeError, "Invalid amount: #{nbytes}."
      end
      return [] if nbytes == 0
      parameters = "nbytes=#{nbytes}&fmt=bin"
      response = get_response("/cgi-bin/uncgi/Hotbits", parameters)
      if response['content-type'] != 'application/octet-stream'
        raise "Unexpected content type: #{response['content-type']}."
      end
      result = []
      response.body.each_byte { |b| result << b }
      result
    end
  end

  class EntropyPool < OnlineGenerator
    def initialize
      super("random.hd.org")
    end

    def randbyte(nbytes = 16, limit = true)
      if nbytes < 0 || nbytes > 256
        raise RangeError, "Invalid amount: #{nbytes}."
      end
      return [] if nbytes == 0
      parameters = "numBytes=#{nbytes}&type=bin&limit=#{limit}"
      response = get_response("/getBits.jsp", parameters)
      if response['content-type'] !~ /application\/octet-stream/
        raise "Unexpected content type: <#{response['content-type']}>."
      end
      result = []
      response.body.each_byte { |b| result << b }
      result
    end
  end
end

# vim:sw=2

