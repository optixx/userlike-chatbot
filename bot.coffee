core = require './core.coffee'
State = core.State


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
    @fsm.event "send", "$any"

module.exports = AskName
