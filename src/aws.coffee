_ = require 'lodash'
Promise = require 'when'

AWS = require 'aws-sdk'

module.exports = (System) ->
  getSES = do () ->
    ses = null
    ->
      return ses if ses
      ses = System.getSettings().then (settings) ->
        AWS.config.update
          accessKeyId: settings.accessKeyId
          secretAccessKey: settings.secretAccessKey
          region: settings.region
        new AWS.SES()

  preSendEmail = (obj) ->
    console.log 'preSendEmail', obj
    return obj unless obj.notify
    System.getSettings().then (settings) ->
      obj.to = [settings.notificationEmail] unless obj?.to?.length > 0
      obj.from = settings.from
      obj

  sendEmail = (obj) ->
    console.log 'email.send', obj
    # return obj
    for field in ['subject', 'body', 'from']
      return Promise.reject new Error "#{field} required" unless obj[field]
    return Promise.reject new Error "to address required" unless obj.to?.length > 0
    getSES().then (ses) ->
      params =
        Destination:
          BccAddresses: []
          CcAddresses: []
          ToAddresses: obj.to
        Message:
          Body:
            Text:
              Data: obj.body ? '[body]'
          Subject:
            Data: obj.subject ? '[subject]'
        Source: obj.from
      Promise.promise (resolve, reject) ->
        ses.sendEmail params, (err, data) ->
          return reject err if err
          resolve data
    .then (result) ->
      console.log 'email sent?', result
      result

  send = (req, res, next) ->
    subject = req.body?.subject ? req.query?.subject
    body = req.body?.body ? req.query?.body
    to = req.body?.to ? req.query?.to
    return next new Error 'Subject required' unless subject
    return next new Error 'Body required' unless body
    Promise preSendEmail
      notify: true
      to: if to?.length > 0 then [to] else null
      subject: subject
      body: body
    .then sendEmail
    .done (result) ->
      res.send
        result: result
    , (err) ->
      next err

  setup = (req, res, next) ->
    System.getSettings (err, settings) ->
      return next err if err
      if req.body?.settings?.aws?.accessKeyId
        if req.body.settings.aws.secretAccessKey == ''
          delete req.body.settings.aws.secretAccessKey
        settings = _.merge settings, req.body.settings.aws
        client = null
        System.updateSettings settings, (err) ->
          return next err if err
          res.render 'app',
            settings:
              aws: settings
        return
      res.render 'app',
        settings:
          aws: settings

  globals:
    public:
      nav:
        Admin:
          Settings:
            AWS:
              Configure: '/admin/aws/setup/app'

  events:
    email:
      send:
        pre: preSendEmail
        do: sendEmail

  routes:
    admin:
      '/admin/aws/send': 'send'
      '/admin/aws/setup/:step': 'setup'
      '/admin/aws': 'index'

  handlers:
    setup: setup
    send: send
    index: (req, res) -> res.redirect '/admin/aws/setup/app'
