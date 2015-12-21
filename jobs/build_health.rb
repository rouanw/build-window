require 'net/http'
require 'json'
require 'uri'

def get_build_health(build_id)
  max_builds = Builds::BUILD_CONFIG['maxBuilds'] || '25'
  uri = URI.parse(Builds::BUILD_CONFIG['bambooBaseUrl'] + 'rest/api/latest/result/' + build_id + '.json?expand=results.result&max-results=' + max_builds)
  http = Net::HTTP.new(uri.host, uri.port)
  if uri.scheme == 'https'
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  build_info = JSON.parse(response.body)

  results = build_info['results']['result']
  successful_count = results.count { |result| result['state'] == 'Successful' }
  health = (successful_count / results.count.to_f * 100).round

  latest_build = results[0]
  name = latest_build['plan']['shortName']
  link = Builds::BUILD_CONFIG['bambooBaseUrl'] + 'browse/' + latest_build['key']
  status = latest_build['state']
  duration = latest_build['buildDurationDescription']
  time = latest_build['buildRelativeTime']

  return {
    :name => name,
    :status => status,
    :duration => duration,
    :link => link,
    :health => health,
    :time => time
  }
end

SCHEDULER.every '10s' do
  Builds::BUILD_LIST.each do |build|
    send_event(build, get_build_health(build))
  end
end
