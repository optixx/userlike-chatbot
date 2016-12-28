Client = require 'node-xmpp-client'
inquirer = require 'inquirer'
core = require './core.coffee'
FSM = core.FSM
bots = require './bots/'

validateValue = (value, min_length) ->
  if value.length >= min_length
    return true
  "Please provide a valid value (min #{min_length} chars)"

inquirer
  .prompt [
      type: 'input',
      name: 'jid',
      message: 'Enter your account\'s username:'
      min_length: 5
      validate: (value) ->
        validateValue value, 3
    ,
      type: 'password',
      name: 'password',
      message: 'Enter your account\'s password:'
      validate: (value) ->
        validateValue value, 8
    ,
      type: 'input',
      name: 'host',
      message: 'Which host you want to connect to?',
      default: 'www.userlike.com'
    ,
      type: 'list',
      name: 'bot',
      message: 'Choose a bot',
      choices: Object.keys bots
    ]
    .then (answers) ->
      sessions = {}
      client = new Client
        jid: "#{answers.jid}@userlike.com"
        password: answers.password
        host: answers.host

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
            fsm = new FSM from, client
            sessions[from] = fsm
            fsm.next bots[answers.bot]
          sessions[from].event "message", body
