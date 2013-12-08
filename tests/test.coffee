process.env.NODE_ENV = 'test'

assert = require 'assert'

describe 'test', ->

  it 'should be 2', ->
    return assert.equal 2, 1 + 1
