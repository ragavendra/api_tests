to understand this project: 

The ApiLib Library (lib folder) - reused by many specs - require 'ApiLib' from your spec to use

1.urlObjects - folder contains 1 class per URL under test. the class offers a method for every remote method this URL under test exposes. 

2.entityObjects - folder contains class objects to represent the JSON bodies used in requests and responses. expect that every remote method offered by a URL has 2 entityObjects, one for the request and one for the response body

3.contextObjects - some general classes to glue this together into a user driven scenario

The Specs (specs folder) - here are the tests - try to keep re-use out of the specs and in the ApiLib library

##Running Automation tests

All specs in rake file

```rake test```

OR

For Individual specs file

```rake test TEST=specs/happy_path_spec_manualBV.rb```

OR

We have shell scripts in the bin folder which should run the specs or tests but may not be updated.

OR

Also you can run the individual specs or tests like below from within the api folder

```ruby -Ilib specs/memberService_specs.rb```

OR

For Individual spec

```ruby -Ilib specs/memberService_specs.rb --name "test_0001_An anonymous user can signup for a new member account"```

For Scheduling using cron

```crontab crontab```

Confirming/ listong cron schedule

```crontab -l```

