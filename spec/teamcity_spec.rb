require 'spec_helper.rb'
require_job 'build_health.rb'

describe 'get build data from teamcity' do
  before(:each) do
    @teamcity_builds = [
      {
        'webUrl' => 'webUrl',
        'status' => 'SUCCESS',
        'id' => 123
      },
      {
        'webUrl' => 'webUrl',
        'status' => 'FAILURE',
        'id' => 113
      }
    ]
    @teamcity_build = {
      'buildType' => {
        'name' => 'my build'
      },
      'status' => 'SUCCESS',
      'startDate' => '20150930T141149+0300'
    }
    TeamCity = double('tc')
    allow(TeamCity).to receive(:builds).and_return(@teamcity_builds)
    allow(TeamCity).to receive(:build).and_return(@teamcity_build)
  end

  it 'should request 25 recent builds for build id' do
    expect(TeamCity).to receive(:builds).with(count: 25, buildType: 'some_build')
    build_health = get_build_health 'id' => 'some_build', 'server' => 'TeamCity'
  end

  it 'should request more info for most recent build' do
    expect(TeamCity).to receive(:build).with(id: 123)
    build_health = get_build_health 'id' => 'some_build', 'server' => 'TeamCity'
  end

  it 'should return the name of the build' do
    build_health = get_build_health 'id' => 'some_build', 'server' => 'TeamCity'
    expect(build_health[:name]).to eq('my build')
  end

  it 'should return the status of the latest build when Successful' do
    build_health = get_build_health 'id' => 'some_build', 'server' => 'TeamCity'
    expect(build_health[:status]).to eq('Successful')
  end

  it 'should return the status of the latest build when Failed' do
    failed_build = {
      'buildType' => {
        'name' => 'my build'
      },
      'status' => 'FAILURE'
    }
    allow(TeamCity).to receive(:build).and_return(failed_build)
    build_health = get_build_health 'id' => 'some_build', 'server' => 'TeamCity'
    expect(build_health[:status]).to eq('Failed')
  end

  it 'should return a link to the latest build' do
    build_health = get_build_health 'id' => 'some_build', 'server' => 'TeamCity'
    expect(build_health[:link]).to eq('webUrl')
  end

  it 'should return the build health' do
    build_health = get_build_health 'id' => 'some_build', 'server' => 'TeamCity'
    expect(build_health[:health]).to eq(50)
  end
end
