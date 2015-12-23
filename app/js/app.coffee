app = angular.module('app', [
  'ngRoute'
])

app.config(['$routeProvider',
  ($routeProvider) ->
    $routeProvider.when('/', {
        templateUrl: 'partials/info.html',
        controller: 'InfoController'
      }).when('/:sha', {
        templateUrl: 'partials/summoner-list.html',
        controller: 'TwitchUserController'
      }).when('/:sha/:summonerID', {
        templateUrl: 'partials/summoner-detail.html',
        controller: 'SummonerDetailController'
      }).otherwise({
        redirectTo: '/'
      })
  ])

capitalize = (str) ->
  str = str.toLowerCase()
  str.charAt(0).toUpperCase() + str.slice(1)

app.factory 'apiService', ($http, $httpParamSerializer) ->
  apiUrl = 'http://127.0.0.1:8001/'

  getTwitchUser: (sha) ->
    $http.get(apiUrl + 'user/' +  sha).then (response) ->
      response.data
  getSummoner: (sha, summonerID) ->
    $http.get(apiUrl + 'user/' + sha + '/summoner/' + summonerID).then (response) ->
      response.data
  unlinkSummoner: (sha, summonerID) ->
    data = {sha: sha, summoner_id: summonerID}
    data = $httpParamSerializer(data)
    $http.post(apiUrl + 'unlink', data, {headers: {'Content-Type': 'application/x-www-form-urlencoded'}}).then (response) ->
      response.data
  summonerDivision: (name, region) ->
    $http.get(apiUrl + 'summoner_division/' + name + '?region=' + region).then (response) ->
      response.data

app.controller 'TwitchUserController', (apiService, $routeParams, $window, $scope, $log) ->
  $scope.sha = $routeParams.sha

  $scope.unlink = (summonerID) ->
    confirm = $window.confirm('Are you sure you want to unlink this summoner?')
    if confirm
      apiService.unlinkSummoner($scope.sha, summonerID).then ->
        get()


  get = -> apiService.getTwitchUser($scope.sha).then (data) ->
    $scope.twitchName = data.name
    $scope.summoners = data.summoners

    $scope.summoners.forEach (summoner, i) ->
      $scope.summoners[i].division = "Loading..."
      apiService.summonerDivision(summoner.name, summoner.region).then (data) ->
        league = capitalize(data.league)
        $scope.summoners[i].division = league + ' ' + data.division + ' ' + data.points + 'LP'


  get()

app.controller 'InfoController', ($scope, $log) ->
  $scope.info = "INFO"

app.controller 'SummonerDetailController', (apiService, $routeParams, $scope, $log) ->
  $scope.sha = $routeParams.sha

  apiService.getSummoner($scope.sha, $routeParams.summonerID).then (data) ->
    $scope.twitchName = data.name
    $scope.summoner = data.summoner
    $scope.sharedCode = $scope.sha + '-' + $scope.summoner.id

app.controller 'SearchController', ($scope, $log, $location) ->
  validateSearch = (searchValue) ->
    if searchValue && searchValue.length >= 42
      a = searchValue.split('-')
      return {error: 'Code should have one hyphen'} if a.length != 2
      return {error: 'The first part of the code only has ' + a[0].length + ' characters, but should have 40'} if a[0].length != 40
      return {path: a[0] + '/' + a[1]}
    else
      return {error: 'Code should have a total of at least 42 characters, you gave only ' + searchValue.length}

  $scope.keyDownListener = (event) ->
    if event.which == 13 || event.keyCode == 13
      validated = validateSearch($scope.searchValue)
      if !validated.error
        $location.path(validated.path) if validated
        $scope.searchError = ''
        $scope.searchValue = ''
      else
        $scope.searchError = validated.error
