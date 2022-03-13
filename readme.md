### API Automation tests

This repo is a rough automation testing framework for writing API tests.

The project is organized in a few folders explained below.

1. services - this folder contains classes to represent the services for a app where one file is a class for a test specific service like for a blog post or an user or an album or a todo

2. tests - here are the tests for a particular service. One tests file for one specific service

### External libraries used

1. httparty - for http calls like GET, POST, PUT, PATCH, DELETE and all. The native net/http library seems cumbersome for implementation

2. minitest - for organizing and running tests

3. rake - for running tests woth a simple command

### Running Automation tests

Running all tests is like below. It can be assigned like in the rake file

```rake test```

OR

For Individual tests file using rake

```rake test TEST=tests/postsService.rb```

OR

Also you can run the individual tests file with many tests like below if you don't like using rake

```ruby tests/postsService.rb```

OR

For running individual test

```ruby tests/postsService.rb --name "test_0001_Get all posts"```
