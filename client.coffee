# vim: ts=4:sw=2:expandtab
Client = require 'node-xmpp-client'
core = require './core.coffee'
FSM = core.FSM
EntryState = require './weather-bot.coffee'


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
      fsm = new FSM from, client
      sessions[from] = fsm
      fsm.next EntryState
    sessions[from].event "message", body
