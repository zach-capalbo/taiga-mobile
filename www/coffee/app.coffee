
# Ionic Starter App

# angular.module is a global place for creating, registering and retrieving Angular modules
# 'starter' is the name of this angular module example (also set in a <body> attribute in index.html)
# the 2nd parameter is an array of 'requires'
# 'starter.services' is found in services.js
# 'starter.controllers' is found in controllers.js

# Hide the accessory bar by default (remove this to show the accessory bar above the keyboard
# for form inputs)

# org.apache.cordova.statusbar required
angular.module("starter", [
    "ionic"
    "starter.controllers"
    "starter.services"
    "ionic.utils"
  ])
  .run(($ionicPlatform, $http, $localstorage) ->
    $ionicPlatform.ready ->
      window.cordova?.plugins.Keyboard?.hideKeyboardAccessoryBar()
      window.StatusBar?.styleDefault()

      auth = $localstorage.get("auth", "")
      $http.defaults.headers.common["Authorization"] = "Bearer #{auth}"
  )
  .config ($stateProvider, $urlRouterProvider, $httpProvider, $localstorageProvider) ->
    $stateProvider.state("tab",
      url: "/tab"
      abstract: true
      templateUrl: "templates/tabs.html"
    ).state("tab.dash",
      url: "/dash"
      views:
        "tab-dash":
          templateUrl: "templates/tab-dash.html"
          controller: "DashCtrl"
    ).state("tab.friends",
      url: "/friends"
      views:
        "tab-friends":
          templateUrl: "templates/tab-friends.html"
          controller: "FriendsCtrl"
    ).state("tab.project",
      url: "/project/:slug"
      views:
        "tab-project":
          templateUrl: "templates/tab-project.html"
          controller: "ProjectCtrl"
    ).state "tab.account",
      url: "/account"
      views:
        "tab-account":
          templateUrl: "templates/tab-account.html"
          controller: "AccountCtrl"

    $urlRouterProvider.otherwise "/tab/dash"

    $httpProvider.defaults.headers.common["Content-Type"] = "application/json"


  # if none of the above states are matched, use this as the fallback
