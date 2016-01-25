Batman.Filters.dateFormat = (date) ->
  if moment(date).isValid() then moment(date).fromNow() else date

Batman.Filters.durationFormat = (duration) ->
  if /^[0-9]*$/.test(duration) then moment.duration(duration, 'seconds').humanize() else duration

class Dashing.BuildWindow extends Dashing.Widget
  onData: (data) ->
    if data.status == 'Failed'
      $(@node).css('background-color', '#a73737')
    else if data.status == 'Successful'
      $(@node).css('background-color', '#03A06E')

  @accessor 'image', ->
    health = @get('health')
    if (health >= 80) then 'assets/health-80plus.svg'
    else if (health >= 60) then 'assets/health-60to79.svg'
    else if (health >= 40) then 'assets/health-40to59.svg'
    else if (health >= 20) then 'assets/health-20to39.svg'
    else 'assets/health-00to19.svg'

  @accessor 'show-health', ->
    @get('health') >= 0
