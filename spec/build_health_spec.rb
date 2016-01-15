require 'spec_helper.rb'

describe 'get build health' do

  before(:all) do
    class SCHEDULER
      def self.every(ignoreme)
      end
    end

    module Builds
      BUILD_CONFIG = {"goBaseUrl"=> 'http://go-place', "bambooBaseUrl"=> 'http://bamboo-place'}
    end

    require_job 'build_health.rb'
  end

  describe 'for travis build' do
      before(:each) do
        @travis_response = [
          {
            "result" => 0,
            "duration" => 12345,
            "id" => 54321,
            "started_at" => 4444444
          }
        ]
        stub_request(:get, 'https://api.travis-ci.org/repos/myrepo/mybuild/builds?event_type=push').
             to_return(:status => 200, :body => @travis_response.to_json, :headers => {})
      end

      it 'should get travis build info from travis api' do
        build_health = get_build_health 'id' => 'myrepo/mybuild', 'server' => 'Travis'
        expect(WebMock.a_request(:get, 'https://api.travis-ci.org/repos/myrepo/mybuild/builds?event_type=push')).to have_been_made
      end

      it 'should return the name of the build' do
        build_health = get_build_health 'id' => 'myrepo/mybuild', 'server' => 'Travis'
        expect(build_health[:name]).to eq('myrepo/mybuild')
      end

      it 'should return the status of the latest build when Successful' do
        build_health = get_build_health 'id' => 'myrepo/mybuild', 'server' => 'Travis'
        expect(build_health[:status]).to eq('Successful')
      end

      it 'should return the status of the latest build when Failed' do
        failed_build = [{"result" => 1}]
        stub_request(:get, "https://api.travis-ci.org/repos/myrepo/mybuild/builds?event_type=push").
             to_return(:status => 200, :body => failed_build.to_json, :headers => {})
        build_health = get_build_health 'id' => 'myrepo/mybuild', 'server' => 'Travis'
        expect(build_health[:status]).to eq('Failed')
      end

      it 'should return the duration of the latest build' do
        build_health = get_build_health 'id' => 'myrepo/mybuild', 'server' => 'Travis'
        expect(build_health[:duration]).to eq(12345)
      end

      it 'should return a link to the latest build' do
        build_health = get_build_health 'id' => 'myrepo/mybuild', 'server' => 'Travis'
        expect(build_health[:link]).to eq('https://travis-ci.org/myrepo/mybuild/builds/54321')
      end

      it 'should return the time of the latest build' do
        build_health = get_build_health 'id' => 'myrepo/mybuild', 'server' => 'Travis'
        expect(build_health[:time]).to eq(4444444)
      end

      it 'should return the build health' do
        so_so = [{"result" => 1}, {"result" => 0}]
        stub_request(:get, 'https://api.travis-ci.org/repos/myrepo/mybuild/builds?event_type=push').
             to_return(:status => 200, :body => so_so.to_json, :headers => {})
        build_health = get_build_health 'id' => 'myrepo/mybuild', 'server' => 'Travis'
        expect(build_health[:health]).to eq(50)
      end
  end

  describe 'for bamboo build' do
      before(:each) do
        @bamboo_response = {
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
        stub_request(:get, 'http://bamboo-place/rest/api/latest/result/MY-BUILD.json?expand=results.result').
             to_return(:status => 200, :body => @bamboo_response.to_json, :headers => {})
      end

      it 'should get travis build info from travis api' do
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
  end
  describe 'for go build' do

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
        build_health = get_build_health 'id' => 'MY-BUILD', 'server' => 'GO'
        expect(WebMock.a_request(:get, 'http://go-place/go/api/pipelines/MY-BUILD/history')).to have_been_made
      end

      it 'should return the name of the build' do
        build_health = get_build_health 'id' => 'MY-BUILD', 'server' => 'GO'
        expect(build_health[:name]).to eq('Go Pipeline')
      end

      it 'should return the status of the latest build when Successful' do
        build_health = get_build_health 'id' => 'MY-BUILD', 'server' => 'GO'
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
        build_health = get_build_health 'id' => 'MY-BUILD', 'server' => 'GO'
        expect(build_health[:status]).to eq('Failed')

      end

  end

  describe 'for teamcity build' do
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
end
