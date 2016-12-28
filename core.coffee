Client = require 'node-xmpp-client'


class FSM

  constructor: (@from, @client)->
    @state = new Init(@)

  next: (state, data) ->
    console.log "next:  #{@state.constructor.name} -> #{state.name}"
    console.log "Data:", data
    @state = new state(@)
    @state.enter(data)

  event: (name, data) ->
    if @state[name]? and typeof(@state[name]) == 'function'
      console.log "event: Event #{@state.constructor.name}:#{name} data=#{data}"
      @state[name](data)

  sharedState: {}

class State

  constructor: (@fsm)->

  enter: ->

  send: (message)->
    stanza = new (Client.Stanza)('message',
      to: @fsm.from
      type: "chat"
      level: "chat"
    ).c('body').t(message)
    @fsm.client.send stanza

class Init extends State

core = exports
exports.FSM = FSM
exports.State = State
