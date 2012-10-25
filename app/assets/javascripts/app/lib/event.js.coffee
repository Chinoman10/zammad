class App.Event
  _instance = undefined

  @init: ->
    _instance = new _Singleton

  @bind: ( events, callback, level ) ->
    if _instance == undefined
      _instance ?= new _Singleton
    _instance.bind( events, callback, level )

  @unbind: ( events, callback, level ) ->
    if _instance == undefined
      _instance ?= new _Singleton
    _instance.unbind( events, callback, level )

  @trigger: ( events, data ) ->
    if _instance == undefined
      _instance ?= new _Singleton
    _instance.trigger( events, data )

  @unbindLevel: (level) ->
    if _instance == undefined
      _instance ?= new _Singleton
    _instance.unbindLevel(level)

class _Singleton

  constructor: ->
    @eventCurrent = {}

  unbindLevel: (level) ->
    return if !@eventCurrent[level]
    for item in @eventCurrent[level]
      @unbind( item.event, item.callback, level )
    @eventCurrent[level] = []

  bind: ( events, callback, level ) ->

    if !level
      level = '_all'

    if !@eventCurrent[level]
      @eventCurrent[level] = []

    # level boundary events
    eventList = events.split(' ')
    for event in eventList

      # remember all events
      @eventCurrent[ level ].push {
        event:    event,
        callback: callback,
      }

      # bind
      Spine.bind( event, callback )

  unbind: ( events, callback, level ) ->

    if !level
      level = '_all'

    if !@eventCurrent[level]
      @eventCurrent[level] = []

    eventList = events.split(' ')
    for event in eventList

      # remove from
      @eventCurrent[level] = _.filter( @eventCurrent[level], (item) ->
        if callback
          return item if item.event isnt event && item.callback isnt callback
        else
          return item if item.event isnt event
      )
      Spine.unbind( event, callback )

  trigger: ( events, data ) ->
    eventList = events.split(' ')
    for event in eventList
      Spine.trigger event, data
