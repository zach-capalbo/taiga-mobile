root = "http://zachcapalbo-taiga.ngrok.com/api/v1"

setupUSData = ($scope, usdata) ->
  usdata.sort (a, b) ->
    return if a.kanban_order >= b.kanban_order then 1 else -1

  for x in [0..usdata.length]
    $scope.user_stories[x] = usdata[x]

angular.module("starter.controllers", [])

.controller "DashCtrl", ($scope, $http) ->
  $http.get("#{root}/projects").success (data) =>
    $scope.projects = data

.controller "AccountCtrl", ($scope, $http, $localstorage, $timeout) ->
  user = $localstorage.getObject "user", null
  delete $http.defaults.headers.common.Authorization unless user
  logged_in = if user then true else false
  $scope.meta = {logged_in: logged_in, user: user} unless $scope.meta
  $scope.submit = ->
    $http.post("#{root}/auth",
    {type: "normal", username: $scope.name, password: $scope.password})
    .success (data) ->
      $localstorage.set "auth", data.auth_token
      $localstorage.setObject "user", data
      $http.defaults.headers.common.Authorization = "Bearer #{data.auth_token}"
      $scope.meta.user = data
      $scope.meta.logged_in = true
    .error (data) ->
      alert(data)

  $scope.logout = ->
    $localstorage.set "auth", null
    $localstorage.setObject "user", null
    delete $http.defaults.headers.common.Authorization if $http.defaults.headers.common.Authorization
    $scope.meta.user = null
    $scope.meta.logged_in = false



.controller "ProjectCtrl", ($scope, $http, $stateParams, $localstorage) ->
  $http.get("#{root}/projects/by_slug?slug=#{$stateParams.slug}").success (data) =>
    $scope.project = data
    $scope.user_stories = []
    $http.get("#{root}/userstories?project=#{data.id}").success (usdata) =>
      setupUSData($scope, usdata)


  $scope.reorderItem = (story, fromIndex, toIndex) =>
    return if fromIndex is toIndex and story.kanban_order is toIndex
    story.kanban_order = toIndex

    $scope.user_stories.splice(fromIndex, 1)
    $scope.user_stories.splice(toIndex, 0, story)

    start = Math.min(toIndex, fromIndex)
    stop = Math.max(toIndex, fromIndex)

    bulk_data = { project_id: $scope.project.id; bulk_stories: []}

    for x in [0..stop]
      $scope.user_stories[x].kanban_order = x
      bulk_data.bulk_stories.push { us_id: $scope.user_stories[x].id; order: x }

    json = JSON.stringify(bulk_data)
    $http.post("#{root}/userstories/bulk_update_kanban_order", json)
