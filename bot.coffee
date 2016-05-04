# vim: ts=4:sw=2:expandtab
Client = require 'node-xmpp-client'

class FSM

  constructor: (@from)->
    @state = new Init(@)
  
  next: (state, data) ->
    console.log "next:  #{@state.constructor.name} -> #{state.name}"
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
      @fsm.event "send", "Ok i will forward you"
      @fsm.next Forward
    else if message is "no"
      @fsm.event "send", "Bye bye"
      @fsm.event "send", "$quit"
    else 
      @fsm.event "send", "I didn't understand that"

class Forward extends State

  enter: ->
    @fsm.event "send", "$forward david"


args = process.argv.slice(2)
sessions = {} 
client = new Client
  jid: args[0]
  password: args[1]
  host: args[2] or 'www.userlike.com'

client.on 'online', ->
  console.log 'Bot is online'

client.on 'error', (e) ->
  console.error e

client.on 'stanza', (stanza) ->
  if stanza.is('message') and stanza.attrs.type isnt 'error' and stanza.attrs.level is "chat"
    from = stanza.attrs.from
    body = stanza.getChildText 'body'
    unless from of sessions
      fsm = new FSM from 
      sessions[from] = fsm 
      fsm.next AskName
    sessions[from].event "message", body 



