angular.module("starter.services", []).factory "Friends", ->
  # Some fake testing data
  friends = [
    {
      id: 0
      name: "Scruff McGruff"
    }
    {
      id: 1
      name: "G.I. Joe"
    }
    {
      id: 2
      name: "Miss Frizzle"
    }
    {
      id: 3
      name: "Ash Ketchum"
    }
  ]
  all: ->
    friends

  get: (friendId) ->
    friends[friendId]

angular.module('ionic.utils', []).factory '$localstorage', ($window) ->
  set: (key, value) ->
    $window.localStorage[key] = value

  get: (key, defaultValue) ->
    return $window.localStorage[key] || defaultValue;

  setObject: (key, value) ->
    $window.localStorage[key] = JSON.stringify(value)

  getObject: (key) ->
    return JSON.parse($window.localStorage[key] || '{}')
