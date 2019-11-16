#!/usr/bin/env ruby
require 'uri'
require 'json'
require 'webrick'
require 'openssl'
require 'webrick/https'
require_relative './config.rb'

config = ServerConfig.new
if(config.error)
    print "Error loading configuration!\n"
    print config.error
    print "\n"
    exit  false
end

https_certificate = OpenSSL::X509::Certificate.new File.read('search.yahoo.com.crt')
https_private_key = OpenSSL::PKey::RSA.new File.read('search.yahoo.com.key')

server = WEBrick::HTTPServer.new({
    :Port => 443,
    :BindAddress => '0.0.0.0',
    :SSLEnable => true,
    :SSLCertificate => https_certificate,
    :SSLPrivateKey => https_private_key
})

# server.mount '/editor', WEBrick::HTTPServlet::FileHandler, File.expand_path('./editor/dist')

server.mount_proc '/data' do |request, response|
    data_command = request.query['cmd']
    case data_command
        when 'config-read'
            config.read
            if(config.error)
                response.status = 500
                response.body = 'Error reading configuration.'
            else
                response.header['Content-Type'] = 'application/json'
                response.header['Cache-Control'] = 'no-cache'
                response.body = JSON.pretty_generate(config.searches)
            end
        when 'config-write'
            begin
                new_search_engines = JSON.parse(request.body)
                config.searches = new_search_engines
                config.write
                if(config.error)
                    response.status = 500
                    response.body = 'Error writing configuration.'
                else
                    response.header['Content-Type'] = 'application/json'
                    response.header['Cache-Control'] = 'no-cache'
                    response.body = JSON.pretty_generate(config.searches)
                end
            rescue
                response.status = 400
                response.body = 'Bad JSON Document'
            end
        else
            response.status = 400
            response.body = 'Bad Request'
    end
end

server.mount_proc '/search' do |request, response|
    search_input      = request.query['p'] || ''
    search_components = search_input.split(' ')
    search_components.append('') if (search_components.length < 2)
    search_components.append('') if (search_components.length < 2)
    search_engine     = search_components[0]
    search_engine_q   = search_components[1..-1].join(' ')

    # if search_engine == 'search-edit'
    #     response.set_redirect WEBrick::HTTPStatus::TemporaryRedirect, '/editor/index.html'
    #     next
    # end

    search_url =
        if config.searches[search_engine]
            (config.searches[search_engine] % [search_engine_q]) 
        else
            (config.searches['default'] % [search_input])
        end

    redirect_url = URI::encode(search_url)
    response.set_redirect WEBrick::HTTPStatus::TemporaryRedirect, redirect_url
end

['INT', 'TERM'].each {|signal| trap(signal) {server.shutdown}}
server.start
