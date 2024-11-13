require 'open3'

module Proxy::Ansible
  class ValidateSettings < ::Proxy::PluginValidators::Base
    def validate!(settings)
      raise NotExistingWorkingDirException.new("Working directory does not exist") unless settings[:working_dir].nil? || File.directory?(File.expand_path(settings[:working_dir]))

      raise "'ansible_execution_environment_image' setting is not set" unless settings[:ansible_execution_environment_image]

      begin
        _, _, _ = Open3.popen3('podman', '--help')
      rescue Errno::ENOENT
        raise "'podman' utility is not available"
      end

      _, _, status = Open3.capture3('podman', 'image', 'inspect', settings[:ansible_execution_environment_image])
      raise "'#{settings[:ansible_execution_environment_image]}' container image is not available" unless status.success?
    end
  end
end
