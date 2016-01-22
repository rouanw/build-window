require 'net/http'
require 'json'
require 'uri'
require 'teamcity'

SUCCESS = 'Successful'
FAILED = 'Failed'

def get_url(url, auth = nil)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  if uri.scheme == 'https'
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
  request = Net::HTTP::Get.new(uri.request_uri)

  if auth != nil then
    request.basic_auth *auth
  end

  response = http.request(request)
  return JSON.parse(response.body)
end

def calculate_health(successful_count, count)
  return (successful_count / count.to_f * 100).round
end

def get_build_health(build)
  if build['server'] == 'Bamboo' then
    return get_bamboo_build_health build['id']
  elsif build['server'] == 'Travis' then
    return get_travis_build_health build['id']
  elsif build['server'] == 'TeamCity' then
    return get_teamcity_build_health build['id']
  elsif build['server'] == 'Go' then
    return get_go_build_health build['id']
  elsif build['server'] == 'Jenkins' then
    return get_jenkins_build_health build['id']
  end
end

def get_teamcity_build_health(build_id)
  builds = TeamCity.builds(count: 25, buildType: build_id)
  latest_build = TeamCity.build(id: builds.first['id'])
  successful_count = builds.count { |build| build['status'] == 'SUCCESS' }

  return {
    name: latest_build['buildType']['name'],
    status: latest_build['status'] == 'SUCCESS' ? SUCCESS : FAILED,
    link: builds.first['webUrl'],
    health: calculate_health(successful_count, builds.count)
  }
end

def get_travis_build_health(build_id)
  url = "https://api.travis-ci.org/repos/#{build_id}/builds?event_type=push"
  results = get_url url
  successful_count = results.count { |result| result['result'] == 0 }
  latest_build = results[0]

  return {
    name: build_id,
    status: latest_build['result'] == 0 ? SUCCESS : FAILED,
    duration: latest_build['duration'],
    link: "https://travis-ci.org/#{build_id}/builds/#{latest_build['id']}",
    health: calculate_health(successful_count, results.count),
    time: latest_build['started_at']
  }
end

def get_go_pipeline_status(pipeline)
  return pipeline['stages'].index { |s| s['result'] == 'Failed' } == nil ? SUCCESS : FAILED
end

def get_go_build_health(build_id)
  url = "#{Builds::BUILD_CONFIG['goBaseUrl']}/go/api/pipelines/#{build_id}/history"
  build_info = get_url url, [ENV['GO_USER'], ENV['GO_PASSWORD']]

  results = build_info['pipelines']
  successful_count = results.count { |result| get_go_pipeline_status(result) == SUCCESS }
  latest_pipeline = results[0]

  return {
    name: latest_pipeline['name'],
    status: get_go_pipeline_status(latest_pipeline),
    duration: 0,
    link: "#{Builds::BUILD_CONFIG['goBaseUrl']}/go/tab/pipeline/history/#{build_id}",
    health: calculate_health(successful_count, results.count),
    time: Time.now
  }
end

def get_bamboo_build_health(build_id)
  url = "#{Builds::BUILD_CONFIG['bambooBaseUrl']}/rest/api/latest/result/#{build_id}.json?expand=results.result"
  build_info = get_url url

  results = build_info['results']['result']
  successful_count = results.count { |result| result['state'] == 'Successful' }
  latest_build = results[0]

  return {
    name: latest_build['plan']['shortName'],
    status: latest_build['state'] == 'Successful' ? SUCCESS : FAILED,
    duration: latest_build['buildDurationDescription'],
    link: "#{Builds::BUILD_CONFIG['bambooBaseUrl']}/browse/#{latest_build['key']}",
    health: calculate_health(successful_count, results.count),
    time: latest_build['buildRelativeTime']
  }
end

def get_jenkins_build_health(build_id)
  url = "#{Builds::BUILD_CONFIG['jenkinsBaseUrl']}/job/#{build_id}/api/json?tree=builds[status,timestamp,id,result,duration,url,fullDisplayName]"
  build_info = get_url URI.encode(url)
  builds = build_info['builds']
  successful_count = builds.count { |build| build['result'] == 'SUCCESS' }
  latest_build = builds[0]
  return {
    name: latest_build['fullDisplayName'],
    status: latest_build['result'] == 'SUCCESS' ? SUCCESS : FAILED,
    duration: latest_build['duration'] / 1000,
    link: latest_build['url'],
    health: calculate_health(successful_count, builds.count),
    time: latest_build['timestamp']
  }
end

SCHEDULER.every '20s' do
  Builds::BUILD_LIST.each do |build|
    send_event(build['id'], get_build_health(build))
  end
end
