// Generated by CoffeeScript 1.9.3
(function() {
  var app, capitalize;

  app = angular.module('app', ['ngRoute']);

  app.config([
    '$routeProvider', function($routeProvider) {
      return $routeProvider.when('/', {
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
      });
    }
  ]);

  capitalize = function(str) {
    str = str.toLowerCase();
    return str.charAt(0).toUpperCase() + str.slice(1);
  };

  app.factory('apiService', function($http, $httpParamSerializer) {
    var apiUrl;
    apiUrl = 'http://127.0.0.1:8001/';
    return {
      getTwitchUser: function(sha) {
        return $http.get(apiUrl + 'user/' + sha).then(function(response) {
          return response.data;
        });
      },
      getSummoner: function(sha, summonerID) {
        return $http.get(apiUrl + 'user/' + sha + '/summoner/' + summonerID).then(function(response) {
          return response.data;
        });
      },
      unlinkSummoner: function(sha, summonerID) {
        var data;
        data = {
          sha: sha,
          summoner_id: summonerID
        };
        data = $httpParamSerializer(data);
        return $http.post(apiUrl + 'unlink', data, {
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
          }
        }).then(function(response) {
          return response.data;
        });
      },
      summonerDivision: function(name, region) {
        return $http.get(apiUrl + 'summoner_division/' + name + '?region=' + region).then(function(response) {
          return response.data;
        });
      }
    };
  });

  app.controller('TwitchUserController', function(apiService, $routeParams, $window, $scope, $log) {
    var get;
    $scope.sha = $routeParams.sha;
    $scope.unlink = function(summonerID) {
      var confirm;
      confirm = $window.confirm('Are you sure you want to unlink this summoner?');
      if (confirm) {
        return apiService.unlinkSummoner($scope.sha, summonerID).then(function() {
          return get();
        });
      }
    };
    get = function() {
      return apiService.getTwitchUser($scope.sha).then(function(data) {
        $scope.twitchName = data.name;
        $scope.summoners = data.summoners;
        return $scope.summoners.forEach(function(summoner, i) {
          $scope.summoners[i].division = "Loading...";
          return apiService.summonerDivision(summoner.name, summoner.region).then(function(data) {
            var league;
            league = capitalize(data.league);
            return $scope.summoners[i].division = league + ' ' + data.division + ' ' + data.points + 'LP';
          });
        });
      });
    };
    return get();
  });

  app.controller('InfoController', function($scope, $log) {
    return $scope.info = "INFO";
  });

  app.controller('SummonerDetailController', function(apiService, $routeParams, $scope, $log) {
    $scope.sha = $routeParams.sha;
    return apiService.getSummoner($scope.sha, $routeParams.summonerID).then(function(data) {
      $scope.twitchName = data.name;
      $scope.summoner = data.summoner;
      return $scope.sharedCode = $scope.sha + '-' + $scope.summoner.id;
    });
  });

  app.controller('SearchController', function($scope, $log, $location) {
    var validateSearch;
    validateSearch = function(searchValue) {
      var a;
      if (searchValue && searchValue.length >= 42) {
        a = searchValue.split('-');
        if (a.length !== 2) {
          return {
            error: 'Code should have one hyphen'
          };
        }
        if (a[0].length !== 40) {
          return {
            error: 'The first part of the code only has ' + a[0].length + ' characters, but should have 40'
          };
        }
        return {
          path: a[0] + '/' + a[1]
        };
      } else {
        return {
          error: 'Code should have a total of at least 42 characters, you gave only ' + searchValue.length
        };
      }
    };
    return $scope.keyDownListener = function(event) {
      var validated;
      if (event.which === 13 || event.keyCode === 13) {
        validated = validateSearch($scope.searchValue);
        if (!validated.error) {
          if (validated) {
            $location.path(validated.path);
          }
          $scope.searchError = '';
          return $scope.searchValue = '';
        } else {
          return $scope.searchError = validated.error;
        }
      }
    };
  });

}).call(this);

//# sourceMappingURL=app.js.map
