#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the zip function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_zip([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should be able to zip an array" do
    result = scope.function_zip([['1','2','3'],['4','5','6']])
    expect(result).to(eq([["1", "4"], ["2", "5"], ["3", "6"]]))
  end
end
