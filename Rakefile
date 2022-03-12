require 'rake/testtask'

#Run this file with the below command
#HOST=cards-m3 rake test
#HOST=cards-m3 rake test TEST=specs/cardService_specs.rb

=begin
Rake::TestTask.new do |t|
	  t.pattern = "specs/*_specs.rb"
end
=end

desc "Show usage information"
task :help do
  help_str = <<-HELP_STR

Configurable environment variables:

+---------------+----------------------------------+-----------------------------+
| Variable Name | Description                      | Default Value               |
+---------------+----------------------------------+-----------------------------+
| HOST          | HTTP Server name or IP           | dockervm                    |
| RMQ_HOST      | RabbitMQ Server name or IP       | dockervm                    |
| RMQ_VHOST     | RabbitMQ Virtual Host            | /                           |
| HTTP_PORT     | HTTP Server port                 | 443                         |
| HTTP_PROTOCOL | HTTP Protocol                    | https                       |
| DOCKER_PATH   | Path to docker-compose.yml       |                             |
| DOCKER_LOG    | Name of running logger container | integration_loggerservice_1 |
+---------------+----------------------------------+-----------------------------+

We often use the following env vars:

RMQ_HOST:
  If you are running specs against remote RabbitMQ use 10.32.102.109.
  If you are running against a RabbitMQ running within a Docker container,
  then use the same host as ENV['HOST']

RMQ_VHOST:
  Use '/' when RMQ is on localhost. Use 'qa' or 'dev' for remote RMQ.

HELP_STR
  puts help_str
end

namespace :cards do
	desc "Running the cards specs"
	Rake::TestTask.new do |t|
		t.name = "all"
		t.test_files = ["specs/happy_path_cards_spec.rb",
			"specs/memberService_specs.rb",
			"specs/cardService_specs.rb"]
	end

	desc "Running the cards specs"
	Rake::TestTask.new do |t|
		t.name = "dev"
		t.test_files = ["specs/cardService_specs.rb"]
	end
end

task :default => 'liquid'
