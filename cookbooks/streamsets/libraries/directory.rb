require 'chef/mixin/shell_out'

module StreamsetsHelpers

  class CommunitiesList
    extend Chef::Mixin::ShellOut

#TODO: Catch exception if no directory exist and alert
    def self.sub_folders?(base_path)
      v = []
      Chef::Log.info("Current Directory: #{Dir.pwd}")
      Chef::Log.info("base_path: '#{base_path}'")
      Dir.chdir(base_path)
      Chef::Log.info("Changed Directory: #{Dir.pwd}")
      folderList = Dir.glob('*').select { |f| File.directory? f }
      v.push(folderList)
      Chef::Log.info("Total communities: '#{v.length}' '#{folderList}'")
      return v
    end
  end
end