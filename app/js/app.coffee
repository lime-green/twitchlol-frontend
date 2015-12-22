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

app.controller 'TwitchUserController', (apiService, $routeParams, $scope, $log) ->
  $scope.sha = $routeParams.sha

  $scope.unlink = (summonerID) ->
    if $scope.twitchName
      apiService.unlinkSummoner($scope.sha, summonerID).then ->
        $log.info('unlinked')


  apiService.getTwitchUser($scope.sha).then (data) ->
    $scope.twitchName = data.name
    $scope.summoners = data.summoners

app.controller 'InfoController', ($scope, $log) ->
  $scope.info = "INFO"

app.controller 'SummonerDetailController', (apiService, $routeParams, $scope, $log) ->
  $scope.sha = $routeParams.sha

  apiService.getSummoner($scope.sha, $routeParams.summonerID).then (data) ->
    $scope.twitchName = data.name
    $scope.summoner = data.summoner
