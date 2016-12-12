# vim: ts=4:sw=2:expandtab
Client = require 'node-xmpp-client'
weather = require 'yahoo-weather'

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

class GetWeather extends State

  enter:  ->
    weather 'Cologne'
      .then (res) =>
        sessions['weather_data'] = res
        @fsm.next ReturnCurrent, res
      .catch (error) =>
        console.log error
        @fsm.event "send", "Could not get weather data - try again?"
        @fsm.next ProcessAnswer, GetWeather

  message: ->
    @fsm.event "send", "Still looking up"


class AskCurrent extends State

  enter: ->
    @fsm.event "send", "Do you want the current weather conditions for Cologne?"

  message: =>
    @fsm.next ProcessAnswer, GetWeather

class ReturnCurrent extends State

  enter: (data) ->
    @fsm.event "send", "The weather in Cologne today: #{data.item.condition.text} (#{data.item.condition.temp} °C)"
    @fsm.next AskForecast


class AskForecast extends State

  enter: =>
    @fsm.event "send", "Do you also want a forecast for the next ten days?"
    @fsm.next ProcessAnswer, ReturnForecast

class ReturnForecast extends State

  enter: =>
    for day in sessions.weather_data.item.forecast
      @fsm.event "send", "The weather in Cologne on #{day.date}: #{day.text} (between #{day.low} and #{day.high} °C)"
    @fsm.event "send", "Ok then, have a nice day!"
    @fsm.event "send", "$quit"

class ProcessAnswer extends State

  enter: (@next) ->

  fuzzyInput: (message) ->
    stripped_message = message.toLowerCase().replace /^\s+|\s+$/g, ""
    if message in ['yes', 'y', 'ja', 'j', 'ok', 'jep']
      message = 'yes'
    if message in ['no', 'n', 'nope', 'nein', 'nö']
      message = 'no'
    return message

  message: (message) ->
    answer = @fuzzyInput message
    if answer is 'yes'
      @fsm.event "send", "Ok, I will look it up..."
      @fsm.next @next
    else if answer is 'no'
      @fsm.event "send", "Ok then, have a nice day!"
      @fsm.event "send", "$quit"
    else
      @fsm.event "send", "Sorry, I didn't understand that"


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
  if stanza.is('message') and stanza.attrs.type isnt 'error' and stanza.attrs.level is "chat"
    from = stanza.attrs.from
    body = stanza.getChildText 'body'
    unless from of sessions
      fsm = new FSM from
      sessions[from] = fsm
      fsm.next AskCurrent
    sessions[from].event "message", body
