#!/usr/bin/env ruby
require 'uri'
require 'json'
require 'webrick'
require 'openssl'
require 'webrick/https'


https_certificate = OpenSSL::X509::Certificate.new File.read('search.yahoo.com.crt')
https_private_key = OpenSSL::PKey::RSA.new File.read('search.yahoo.com.key')

server = WEBrick::HTTPServer.new({
    :Port => 443,
    :BindAddress => '0.0.0.0',
    :SSLEnable => true,
    :SSLCertificate => https_certificate,
    :SSLPrivateKey => https_private_key
})

search_engines = JSON.parse File.read('engines.json')

server.mount_proc '/search' do |request, response|
    search_input      = request.query['p'] || ''
    search_components = search_input.split(' ')
    search_components.append('') if (search_components.length < 2)
    search_components.append('') if (search_components.length < 2)
    search_engine     = search_components[0]
    search_engine_q   = search_components[1..-1].join(' ')

    if search_engine == 'search-reload'
        search_engines = JSON.parse File.read('engines.json')
        response.body = JSON.pretty_generate(search_engines)
        next
    end

    search_url =
        if search_engines[search_engine]
            (search_engines[search_engine] % [search_engine_q]) 
        else
            (search_engines['default'] % [search_input])
        end

    redirect_url = URI::encode(search_url)
    response.set_redirect WEBrick::HTTPStatus::TemporaryRedirect, redirect_url
end

server.start
