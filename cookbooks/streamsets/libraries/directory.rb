require 'chef/mixin/shell_out'

module StreamsetsHelpers

  class CommunitiesList
    def self.sub_folders?(base_path)
      Chef::Log.info("Current Directory: #{Dir.pwd}")
      Chef::Log.info("base_path: '#{base_path}'")
      Dir.chdir(base_path)
      Chef::Log.info("Changed Directory: #{Dir.pwd}")
      folderList = Dir.glob('*').select { |f| File.directory? f }
      Chef::Log.info("Total communities: '#{folderList.length}' '#{folderList}'")
      return folderList
    end
  end
end