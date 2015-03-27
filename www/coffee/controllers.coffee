root = "http://zachcapalbo-taiga.ngrok.com/api/v1"
# root = "http://localhost:8000/api/v1"

setupUSData = ($scope, usdata) ->
  status_stories = {}
  for story in usdata
    status_stories[story.status] = [] unless status_stories[story.status]
    status_stories[story.status].push story

  for status,status_set of status_stories
    $scope.meta.statuses.push status
    status_set.sort (a, b) ->
      return if a.kanban_order >= b.kanban_order then 1 else -1

  for status in $scope.meta.statuses
    status_set = status_stories[status]
    for x in [0..status_set.length - 1]
      $scope.user_stories[status] ||= []
      $scope.user_stories[status][x] = status_set[x]
      $scope.user_stories[status][x].idx = x

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



.controller "ProjectCtrl", ($scope, $http, $stateParams, $localstorage, $ionicModal) ->
  $http.get("#{root}/projects/by_slug?slug=#{$stateParams.slug}").success (data) =>
    $scope.project = data
    $scope.user_stories = {}
    $scope.meta = {}
    $scope.meta.statuses = []

    $http.get("#{root}/userstories?project=#{data.id}").success (usdata) =>
      setupUSData($scope, usdata)

    $ionicModal.fromTemplateUrl('categories.html', {
      scope: $scope
      animation: 'slide-in-up'
    }).then (modal) ->
      $scope.modal = modal

  $scope.reorderItem = (story, fromIndex, toIndex) =>
    return if fromIndex is toIndex and story.kanban_order is toIndex
    story.kanban_order = toIndex

    $scope.user_stories[story.status] ||= []
    $scope.user_stories[story.status].splice(fromIndex, 1) if fromIndex >= 0
    $scope.user_stories[story.status].splice(toIndex, 0, story)

    fromIndex = 1000 if fromIndex < 0

    start = Math.min(toIndex, fromIndex)
    stop = Math.max(toIndex, fromIndex)
    stop = Math.min(stop, $scope.user_stories[story.status].length - 1)

    bulk_data = { project_id: $scope.project.id; bulk_stories: []}

    for x in [0..stop]
      $scope.user_stories[story.status][x].kanban_order = x
      bulk_data.bulk_stories.push { us_id: $scope.user_stories[story.status][x].id; order: x }

    json = JSON.stringify(bulk_data)
    $http.post("#{root}/userstories/bulk_update_kanban_order", json)

  $scope.editCategory = (story) ->
    $scope.edit_story = story
    $scope.modal.show()

  $scope.setCategory = (status) ->
    story = $scope.edit_story
    old_status = story.status
    story.status = status.id

    $http.put("#{root}/userstories/#{story.id}", JSON.stringify(story)).success (data) ->
      story = data
      $scope.user_stories[old_status].splice(story.idx, 1)
      $scope.reorderItem story, -1, 0
    .error (data) ->
      alert(JSON.stringify(data))

    $scope.modal.hide()
