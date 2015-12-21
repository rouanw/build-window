module Builds
  BUILD_CONFIG = JSON.parse(File.read('config/builds.json'))
  BUILD_LIST = BUILD_CONFIG['builds']
end
