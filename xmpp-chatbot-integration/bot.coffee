# vim: ts=4:sw=2:expandtab
Client = require 'node-xmpp-client'

class FSM

  constructor: (@from)->
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

class State

  constructor: (@fsm)->

  enter: ->

  send: (message)->
    stanza = new (Client.Stanza)('message',
      to: @fsm.from
      type: "chat"
      level: "chat"
    ).c('body').t(message)
    client.send stanza

class Init extends State

class AskName extends State

  message: ->
    @fsm.event "send", "May I ask your name?"
    @fsm.next SetName

class SetName extends State

  message: (message)->
    @fsm.event "send", "$name #{message}"
    @fsm.next AskEmail

class AskEmail extends State

  enter: ->
    @fsm.event "send", "May I ask your email?"
    @fsm.next SetEmail

class SetEmail extends State

  message: (message)->
    @fsm.event "send", "$email #{message}"
    @fsm.next OfferHelp

class OfferHelp extends State

  enter: ->
    @fsm.event "send", "Do you want to talk to an Agent?"
    @fsm.next ProcessAnswer

class ProcessAnswer extends State

  message: (message)->
    if message is "yes"
      @fsm.event "send", "Is there a specific Agent you want to talk to?"
      @fsm.next ForwardTo
    else if message is "no"
      @fsm.next EndChat
    else
      @fsm.event "send", "I didn't understand that"

class EndChat extends State

  enter: ()->
      @fsm.event "send", "!bye"
      @fsm.event "send", "$quit"

class ForwardTo extends State

  message: (message)->
    if message is "yes"
      @fsm.event "send", "Please tell me the name of the Agent"
      @fsm.next Forward
    else if message is "no"
      @fsm.next ForwardAny
    else
      @fsm.event "send", "I didn't understand that"

class Forward extends State

  message: (message)->
    @fsm.event "send", "$forward.json #{message}"
    @fsm.next Idle

class ForwardAny extends State

  enter: ->
    @fsm.event "send", "$any.json"
    @fsm.next Idle

class Idle extends State

class ProcessErrorJSON extends State

  message: (message)->
    @fsm.event "send", "JSON Response:\n#{message}"
    @fsm.next EndChat

args = process.argv.slice(2)
sessions = {}
client = new Client
  jid: args[0]
  password: args[1]
  host: args[2] or 'www.userlike.com'

client.on 'online', ->
  console.log 'Bot is online'
  client.send new (Client.Stanza)('presence', {}).c('show').t('chat').up().c('status').t('I\'m a bot')


client.on 'error', (e) ->
  console.error e

client.on 'stanza', (stanza) ->
  has_next = false
  if stanza.is('message')
    body = stanza.getChildText 'body'
    if stanza.attrs.type isnt 'error' and stanza.attrs.level is 'chat'
      state = AskName # Ask for Name if chat just started
    else if stanza.attrs.type is 'chat' and stanza.attrs.level is 'warning'
      try
        # Send JSON Response to client if body contains valid JSON
        if body.length
          JSON.parse(body)
          state = ProcessErrorJSON
          has_next = true
      catch
    if state?
      from = stanza.attrs.from
      unless from of sessions
        fsm = new FSM from
        sessions[from] = fsm
        has_next = true
      sessions[from].next(state) if has_next
      sessions[from].event "message", body
