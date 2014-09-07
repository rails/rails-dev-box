#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the reverse function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("reverse")).to eq("function_reverse")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_reverse([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should reverse a string" do
    result = scope.function_reverse(["asdfghijkl"])
    expect(result).to(eq('lkjihgfdsa'))
  end
end
