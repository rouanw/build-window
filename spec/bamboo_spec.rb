require 'spec_helper.rb'
require_job 'build_health.rb'

describe 'get build data from bamboo' do
  bamboo_response = {
    "results"  => {
      "result" => [
        {
          "state" => "Successful",
          "buildDurationDescription" => "some time it took",
          "plan" => {"shortName" => "Harvey"},
          "key" => 33,
          "buildRelativeTime" => "a long long time ago"
        }
      ]
    }
  }

  before(:each) do
    stub_request(:get, 'http://bamboo-place/rest/api/latest/result/MY-BUILD.json?expand=results.result').
         to_return(:status => 200, :body => bamboo_response.to_json, :headers => {})
  end

  it 'should get bamboo build info from bamboo api' do
    build_health = get_build_health 'id' => 'MY-BUILD', 'server' => 'Bamboo'
    expect(WebMock.a_request(:get, 'http://bamboo-place/rest/api/latest/result/MY-BUILD.json?expand=results.result')).to have_been_made
  end

  it 'should return the name of the build' do
    build_health = get_build_health 'id' => 'MY-BUILD', 'server' => 'Bamboo'
    expect(build_health[:name]).to eq('Harvey')
  end

  it 'should return the status of the latest build when Successful' do
    build_health = get_build_health 'id' => 'MY-BUILD', 'server' => 'Bamboo'
    expect(build_health[:status]).to eq('Successful')
  end

  it 'should return the status of the latest build when Failed' do
    failed_build = {
      "results"  => {
        "result" => [
          {
            "state" => "Failed",
            "plan" => {},
          }
        ]
      }
    }
    stub_request(:get, 'http://bamboo-place/rest/api/latest/result/MY-BUILD.json?expand=results.result').
         to_return(:status => 200, :body => failed_build.to_json, :headers => {})
    build_health = get_build_health 'id' => 'MY-BUILD', 'server' => 'Bamboo'
    expect(build_health[:status]).to eq('Failed')
  end

  it 'should return the duration of the latest build' do
    build_health = get_build_health 'id' => 'MY-BUILD', 'server' => 'Bamboo'
    expect(build_health[:duration]).to eq('some time it took')
  end

  it 'should return a link to the latest build' do
    build_health = get_build_health 'id' => 'MY-BUILD', 'server' => 'Bamboo'
    expect(build_health[:link]).to eq('http://bamboo-place/browse/33')
  end

  it 'should return the time of the latest build' do
    build_health = get_build_health 'id' => 'MY-BUILD', 'server' => 'Bamboo'
    expect(build_health[:time]).to eq('a long long time ago')
  end

  it 'should return the build health' do
    so_so = {
      "results"  => {
        "result" => [
          {
            "state" => "Failed",
            "plan" => {},
          },
          {
            "state" => "Successful",
            "plan" => {},
          }
        ]
      }
    }
    stub_request(:get, 'http://bamboo-place/rest/api/latest/result/MY-BUILD.json?expand=results.result').
         to_return(:status => 200, :body => so_so.to_json, :headers => {})
    build_health = get_build_health 'id' => 'MY-BUILD', 'server' => 'Bamboo'
    expect(build_health[:health]).to eq(50)
  end

  it 'should allow each build to specify its base url' do
    stub_request(:get, "http://example.org/bambooooo-server/rest/api/latest/result/A-BUILD.json?expand=results.result").
      to_return(:status => 200, :body => bamboo_response.to_json, :headers => {})
    build_health = get_build_health 'id' => 'A-BUILD', 'server' => 'Bamboo', 'baseUrl' => "http://example.org/bambooooo-server"
    expect(WebMock.a_request(:get, 'http://example.org/bambooooo-server/rest/api/latest/result/A-BUILD.json?expand=results.result')).to have_been_made
  end
end
