React = require 'react'
_ = require 'underscore'
ScenarioEditorRow = require './scenario-editor-row'
{RetinaImg, Flexbox} = require 'nylas-component-kit'
{Actions, Utils} = require 'nylas-exports'

###
The ScenarioEditor takes an array of ScenarioTemplate objects which define the
scenario value space. Each ScenarioTemplate defines a `key` and it's valid
`comparators` and `values`. The ScenarioEditor gives the user the option to
create and combine instances from different factories to create a scenario.

For example:

  Scenario Space:
   - ScenarioFactory("user-name", "The name of the user")
      + valueType: string
      + comparators: "contains", "starts with", etc.
    - SecnarioFactor("profession", "The profession of the user"")
      + valueType: enum
      + comparators: 'is'

  Scenario Value:
    [{
      'key': 'user-name'
      'comparator': 'contains'
      'value': 'Ben'
    },{
      'key': 'profession'
      'comparator': 'is'
      'value': 'Engineer'
    }]
###
class ScenarioTemplate

  constructor: (@key, {@name} = {}) ->
    @valueType = 'none'
    @valueComparators = {}

  createDefaultInstance: ->
    key: @key,
    value: undefined
    valueComparator: Object.keys(@valueComparators)[0]

  coerceInstance: (instance) ->
    instance.key = @key
    if not @valueComparators
      delete instance.valueComparator
    else if not (instance.valueComparator in Object.keys(@valueComparators))
      instance.valueComparator = Object.keys(@valueComparators)[0]
    instance

class StringScenarioTemplate extends ScenarioTemplate
  constructor: (@key, {@name, @valueComparators} = {}) ->
    @valueType = 'string'

class EnumScenarioTemplate extends ScenarioTemplate
  constructor: (@key, {@name, @valueLabel, @valueComparators, @values} = {}) ->
    @valueType = 'enum'

class ScenarioEditor extends React.Component
  @displayName: 'ScenarioEditor'

  @propTypes:
    rules: React.PropTypes.array
    className: React.PropTypes.string
    onChange: React.PropTypes.func
    templates: React.PropTypes.array

  @Template:
    Base: ScenarioTemplate
    Enum: EnumScenarioTemplate
    String: StringScenarioTemplate

  constructor: (@props) ->
    @state =
      collapsed: true

  render: =>
    <div className={@props.className}>
    { (@props.rules || []).map (rule, idx) =>
      <ScenarioEditorRow
        key={idx}
        rule={rule}
        removable={@props.rules.length > 1}
        templates={@props.templates}
        onRemove={ => @_onRemoveRule(idx) }
        onInsert={ => @_onInsertRule(idx) }
        onChange={ (rule) => @_onChangeRowValue(rule, idx) } />
    }
    </div>

  _performChange: (block) =>
    rules = JSON.parse(JSON.stringify(@props.rules))
    block(rules)
    @props.onChange(rules)

  _onRemoveRule: (idx) =>
    @_performChange (rules) =>
      return if rules.length is 1
      rules.splice(idx, 1)

  _onInsertRule: (idx) =>
    @_performChange (rules) =>
      rules.push @props.templates[0].createDefaultInstance()

  _onChangeRowValue: (newRule, idx) =>
    @_performChange (rules) =>
      rules[idx] = newRule

module.exports = ScenarioEditor
