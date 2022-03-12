#this file defines library contents 

require 'rubygems'
require 'bundler/setup'

require 'httparty'
require 'json'
require 'date'

require_relative '../lib/contextObjects/ApiUser'
require_relative '../lib/contextObjects/ApiDefaultTestData'

require_relative '../lib/serviceObjects/ServiceBase'
require_relative '../lib/serviceObjects/MemberService'
require_relative '../lib/serviceObjects/ResponseAssertions'

