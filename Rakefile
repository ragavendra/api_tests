require 'rake/testtask'

#Run this file with the below command
#HOST=jsonplaceholder.typicode.com rake test
#HOST=jsonplaceholder.typicode.com rake test TEST=tests/postsService.rb

#=begin
Rake::TestTask.new do |t|
	  t.pattern = "tests/*.rb"
end
#=end

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

namespace :jsonplaceholder do
	desc "Running the posts tests"
	Rake::TestTask.new do |t|
		t.name = "posts"
		t.test_files = ["tests/postsService.rb"]
	end

  desc "Running the dev tests"
	Rake::TestTask.new do |t|
		t.name = "dev"
    t.test_files = ["specs/.......rb",
			"tests/userService.rb",
			"tests/commentService.rb"]
	end
end
