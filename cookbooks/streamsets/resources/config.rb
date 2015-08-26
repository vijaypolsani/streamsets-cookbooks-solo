actions :create, :remove

default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :config_file, :kind_of => String
