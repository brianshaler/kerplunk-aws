React = require 'react'

{DOM} = React

module.exports = React.createFactory React.createClass
  render: ->
    DOM.section
      className: 'content admin-panel'
    ,
      DOM.h1 null, 'AWS Configuration'
      DOM.p null,
        DOM.form
          method: 'post'
          action: '/admin/aws/setup/app'
        ,
          DOM.table null,
            DOM.tr null,
              DOM.td null,
                DOM.strong null, 'Access Key ID:'
              DOM.td null,
                DOM.input
                  name: 'settings[aws][accessKeyId]'
                  defaultValue: @props.settings?.aws?.accessKeyId
            DOM.tr null,
              DOM.td null,
                DOM.strong null, 'Secret Access Key:'
              DOM.td null,
                DOM.input
                  type: 'password'
                  name: 'settings[aws][secretAccessKey]'
            DOM.tr null,
              DOM.td null,
                DOM.strong null, 'AWS Region:'
              DOM.td null,
                DOM.input
                  name: 'settings[aws][region]'
                  defaultValue: @props.settings?.aws?.region
            DOM.tr null,
              DOM.td null,
                DOM.strong null, 'From Address:'
              DOM.td null,
                DOM.input
                  name: 'settings[aws][from]'
                  defaultValue: @props.settings?.aws?.from
            DOM.tr null,
              DOM.td null,
                DOM.strong null, 'Notification Email:'
              DOM.td null,
                DOM.input
                  name: 'settings[aws][notificationEmail]'
                  defaultValue: @props.settings?.aws?.notificationEmail
            DOM.tr null,
              DOM.td()
              DOM.td null,
                DOM.input
                  type: 'submit'
                  value: 'Save'
