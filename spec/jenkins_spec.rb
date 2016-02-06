require 'spec_helper.rb'
require_job 'build_health.rb'

describe 'get build data from jenkins' do

  before(:each) do
    @jenkins_response = {
      "builds" => [{
        "duration" => 10000,
        "fullDisplayName" => "a build",
        "id" => "15",
        "result" => "SUCCESS",
        "timestamp" => 1453489268807,
        "url" => "urlOfSorts"
      }]
    }
    stub_request(:get, 'http://jenkins-url/job/jenkins-build/api/json?tree=builds[status,timestamp,id,result,duration,url,fullDisplayName]').
         to_return(:status => 200, :body => @jenkins_response.to_json, :headers => {})
  end

  it 'should get jenkins build info from jenkins api' do
    build_health = get_build_health 'id' => 'jenkins-build', 'server' => 'Jenkins'
    expect(WebMock.a_request(:get, 'http://jenkins-url/job/jenkins-build/api/json?tree=builds[status,timestamp,id,result,duration,url,fullDisplayName]')).to have_been_made
  end

  it 'should return the name of the build' do
    build_health = get_build_health 'id' => 'jenkins-build', 'server' => 'Jenkins'
    expect(build_health[:name]).to eq('a build')
  end

  it 'should return the status of the latest build when Successful' do
    build_health = get_build_health 'id' => 'jenkins-build', 'server' => 'Jenkins'
    expect(build_health[:status]).to eq('Successful')
  end

  it 'should return the status of the latest build when Failed' do
    failed_build = {
      "builds" => [{
        "duration" => 427875,
        "fullDisplayName" => "a build",
        "id" => "1",
        "result" => "FAILURE",
        "timestamp" => 1451584715235,
        "url" => "someurl/1/"
      }]
    }
    stub_request(:get, 'http://jenkins-url/job/jenkins-build/api/json?tree=builds[status,timestamp,id,result,duration,url,fullDisplayName]').
         to_return(:status => 200, :body => failed_build.to_json, :headers => {})
    build_health = get_build_health 'id' => 'jenkins-build', 'server' => 'Jenkins'
    expect(build_health[:status]).to eq('Failed')
  end

  it 'should return the duration of the latest build, in seconds' do
    build_health = get_build_health 'id' => 'jenkins-build', 'server' => 'Jenkins'
    expect(build_health[:duration]).to eq(10)
  end

  it 'should return a link to the latest build' do
    build_health = get_build_health 'id' => 'jenkins-build', 'server' => 'Jenkins'
    expect(build_health[:link]).to eq('urlOfSorts')
  end

  it 'should return the time of the latest build' do
    build_health = get_build_health 'id' => 'jenkins-build', 'server' => 'Jenkins'
    expect(build_health[:time]).to eq(1453489268807)
  end

  it 'should return the build health' do
    so_so = {
      "builds" => [{
        "duration" => 459766,
        "fullDisplayName" => "a build",
        "id" => "15",
        "result" => "SUCCESS",
        "timestamp" => 1453489268807,
        "url" => "someurl/15/"
      }, {
        "duration" => 427875,
        "fullDisplayName" => "a build",
        "id" => "1",
        "result" => "FAILURE",
        "timestamp" => 1451584715235,
        "url" => "someurl/1/"
      }]
    }
    stub_request(:get, 'http://jenkins-url/job/jenkins-build/api/json?tree=builds[status,timestamp,id,result,duration,url,fullDisplayName]').
         to_return(:status => 200, :body => so_so.to_json, :headers => {})
    build_health = get_build_health 'id' => 'jenkins-build', 'server' => 'Jenkins'
    expect(build_health[:health]).to eq(50)
  end

  it 'should return the build status of the latest non-nil build' do
    running_builds = {
      "builds" => [{
        "duration" => 459766,
        "fullDisplayName" => "a build",
        "id" => "15",
        "result" => nil,
        "timestamp" => 1453489268807,
        "url" => "someurl/15/"
      }, {
        "duration" => 427875,
        "fullDisplayName" => "a build",
        "id" => "1",
        "result" => nil,
        "timestamp" => 1451584715235,
        "url" => "someurl/1/"
      },
      {
        "duration" => 427875,
        "fullDisplayName" => "a build",
        "id" => "1",
        "result" => 'SUCCESS',
        "timestamp" => 1451584715235,
        "url" => "someurl/1/"
      }]
    }
    stub_request(:get, 'http://jenkins-url/job/jenkins-build/api/json?tree=builds[status,timestamp,id,result,duration,url,fullDisplayName]').
         to_return(:status => 200, :body => running_builds.to_json, :headers => {})
    build_health = get_build_health 'id' => 'jenkins-build', 'server' => 'Jenkins'
    expect(build_health[:status]).to eq('Successful')
  end

end
