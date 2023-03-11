---
savon_version: v2
order: 10
title: Testing
layout: guides
nav_savon_version: v2
---

Testing integration with a SOAP service does not differ from testing integration with any other service.
There is really no "right way" of doing this, but from my experience, it's good to have both unit and
integration tests to strike a balance between test speed and reliability.

Where Savon 1.0 had [Savon::Spec](https://rubygems.org/gems/savon_spec) to mock SOAP requests, Savon 2.0
adds support for mocking requests on top of observers. Since it's always a good idea to wrap external
libraries, let's assume you created a simple class for talking to some kind of authentication service.

``` ruby
require "savon"

class AuthenticationService

  def initialize
    @client = Savon.client(wsdl: "http://example.com?wsdl")
  end

  def authenticate(message)
    @client.call(message: message)
  end

end
```

When you're using RSpec, you can include the `Savon::SpecHelper` module in your specs.
The helper module comes with a simple mock interface available through the `savon` method.
Instructions for MiniTest will be added asap.

``` ruby
require "spec_helper"

# require the helper module
require "savon/mock/spec_helper"

describe AuthenticationService do
  # include the helper module
  include Savon::SpecHelper

  # set Savon in and out of mock mode
  before(:all) { savon.mock!   }
  after(:all)  { savon.unmock! }

  describe "#authenticate" do
    it "authenticates the user with the service" do
      message = { username: "luke", password: "secret" }
      fixture = File.read("spec/fixtures/authentication_service/authenticate.xml")

      # set up an expectation
      savon.expects(:authenticate).with(message: message).returns(fixture)

      # call the service
      service = AuthenticationService.new
      response = service.authenticate(message)

      expect(response).to be_successful
    end
  end
end
```

As you can see in this example, you have to explicitly set Savon in and out of mock mode before and after
your specs. The example uses RSpec's `before` and `after` hooks for that.

#### Expectations

Are specified through the `#expects` method on the `savon` mock interface. It takes the
name of a SOAP operation that is expected to be called.

``` ruby
savon.expects(:authenticate)
```

#### Options

Can be tested through the `#with` method. This currently only supports checking the SOAP message,
but can easily be changed to support any global and or local option along with the generated request XML.
This is possible because Savon mocks the request as late as possible to ensure everything works as expected
in your integration tests.

If you're trying to "stub" a request, you can pass `message: :any` to the `#with` method to accept any message. You still need to call the
`#returns` method to return a response that Savon can work with.

``` ruby
message = { username: "luke", password: "secret" }
savon.expects(:authenticate).with(message: message)
```

#### Fixtures

Should match a recorded SOAP response from the server for the request you're testing.
The `#returns` method accepts a few options which are used to create an HTTPI response.

``` ruby
message = { username: "luke", password: "secret" }
fixture = File.read("spec/fixtures/authentication_service/authenticate.xml")

savon.expects(:authenticate).with(message: message).returns(fixture)
```

When passed a String, like in the example above, the `#returns` method defaults to a response code of 200
with no headers and uses the String as the response body. You can also pass a Hash to specify all values
yourself. This can be useful if you're testing SOAP fault responses which have a response code of 500.

``` ruby
soap_fault = File.read("spec/fixtures/authentication_service/soap_fault.xml")

response = { code: 500, headers: {}, body: soap_fault }
savon.expects(:authenticate).with(message: message).returns(response)
```

This is a brand new feature, so please give it a try and let me know what you think.
