require 'spec_helper.rb'
require_job 'build_health.rb'

describe 'get build data from go' do

  before(:each) do
    @go_response = {
      "pipelines"  => [
        {
          "name" => "Go Pipeline",
          "label" => "90",
          "stages" => [
            {
              "result" => "Passed"
            }
          ]
        }
      ],
      "pagination" => {
        "offset" => 0,
        "total" => 92,
        "page_size" => 10
      }
    }
    stub_request(:get, 'http://go-place/go/api/pipelines/MY-BUILD/history').
         to_return(:status => 200, :body => @go_response.to_json, :headers => {})
  end

  it 'should get go build info from go api' do
    build_health = get_build_health 'id' => 'MY-BUILD', 'server' => 'Go'
    expect(WebMock.a_request(:get, 'http://go-place/go/api/pipelines/MY-BUILD/history')).to have_been_made
  end

  it 'should return the name of the build' do
    build_health = get_build_health 'id' => 'MY-BUILD', 'server' => 'Go'
    expect(build_health[:name]).to eq('Go Pipeline')
  end

  it 'should return the status of the latest build when Successful' do
    build_health = get_build_health 'id' => 'MY-BUILD', 'server' => 'Go'
    expect(build_health[:status]).to eq('Successful')
  end

  it 'should return the status of the latest build when Failed' do

    failed_build = {
      "pipelines"  => [
        {
          "name" => "Go Pipeline",
          "label" => "90",
          "stages" => [
            {
              "result" => "Passed"
            },
            {
              "result" => "Failed"
            }
          ]
        }
      ],
      "pagination" => {
        "offset" => 0,
        "total" => 92,
        "page_size" => 10
      }
    }
    stub_request(:get, 'http://go-place/go/api/pipelines/MY-BUILD/history').
         to_return(:status => 200, :body => failed_build.to_json, :headers => {})
    build_health = get_build_health 'id' => 'MY-BUILD', 'server' => 'Go'
    expect(build_health[:status]).to eq('Failed')
  end

  it 'should return the build health' do
    so_so = {
      "pipelines"  => [
        {
          "name" => "Go Pipeline",
          "label" => "90",
          "stages" => [
            {
              "result" => "Passed"
            },
            {
              "result" => "Failed"
            }
          ]
        },
        {
          "name" => "Go Pipeline",
          "label" => "90",
          "stages" => [
            {
              "result" => "Passed"
            },
            {
              "result" => "Passed"
            }
          ]
        }
      ],
      "pagination" => {
        "offset" => 0,
        "total" => 92,
        "page_size" => 10
      }
    }
    stub_request(:get, 'http://go-place/go/api/pipelines/MY-BUILD/history').
         to_return(:status => 200, :body => so_so.to_json, :headers => {})
    build_health = get_build_health 'id' => 'MY-BUILD', 'server' => 'Go'
    expect(build_health[:health]).to eq(50)
  end
end
