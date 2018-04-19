Records      = require 'shared/services/records.coffee'
ModalService = require 'shared/services/modal_service.coffee'
I18n         = require 'shared/services/i18n.coffee'
EventBus     = require 'shared/services/event_bus.coffee'
utils        = require 'shared/record_store/utils.coffee'

{ audiencesFor, audienceValuesFor } = require 'shared/helpers/announcement.coffee'

angular.module('loomioApp').directive 'announcementForm', ->
  scope: {announcement: '='}
  restrict: 'E'
  templateUrl: 'generated/components/announcement/form/announcement_form.html'
  controller: ['$scope', ($scope) ->
    $scope.announcement.recipients = []

    $scope.audiences      = -> audiencesFor($scope.announcement.model)
    $scope.audienceValues = -> audienceValuesFor($scope.announcement.model)

    $scope.search = (query) ->
      Records.announcements.search(query, $scope.announcement.model).then (users) ->
        utils.parseJSONList(users)

    buildRecipientFromEmail = (email) ->
      email: email
      emailHash: email
      avatarKind: 'mdi-email-outline'

    $scope.addRecipient = (recipient) ->
      return unless recipient
      _.each recipient.emails, (email) -> $scope.addRecipient buildRecipientFromEmail(email)
      if !recipient.emails && !_.contains(_.pluck($scope.announcement.recipients, "emailHash"), recipient.emailHash)
        $scope.announcement.recipients.unshift recipient
      $scope.selected = undefined
      $scope.query = ''

    EventBus.listen $scope, 'removeRecipient', (_event, recipient) ->
      _.pull $scope.announcement.recipients, recipient

    $scope.loadAudience = (kind) ->
      Records.announcements.fetchAudience($scope.announcement.model, kind).then (data) ->
        _.each _.sortBy(utils.parseJSONList(data), (e) -> e.name || e.email ), $scope.addRecipient
  ]
