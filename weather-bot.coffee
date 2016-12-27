weather = require 'yahoo-weather'
core = require './core.coffee'
State = core.State


class GetWeather extends State

  enter:  ->
    weather 'Cologne'
      .then (res) =>
        @fsm.sharedState['weatherData'] = res
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
    for day in @fsm.sharedState.weatherData.item.forecast
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

module.exports = AskCurrent
