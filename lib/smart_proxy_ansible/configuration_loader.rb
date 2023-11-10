module Proxy::Ansible
  class ConfigurationLoader
    def load_classes
      require 'smart_proxy_dynflow'
      require 'smart_proxy_dynflow/continuous_output'
      require 'smart_proxy_ansible/task_launcher/ansible_runner'
      require 'smart_proxy_ansible/task_launcher/ansible_pull_batch'
      require 'smart_proxy_ansible/runner/ansible_runner'

      launcher_class = if Proxy::RemoteExecution::Ssh::Plugin.settings.mode == "pull-mqtt"
			       TaskLauncher::AnsiblePullBatch
		       else
			       TaskLauncher::AnsibleRunner
		       end
      Proxy::Dynflow::TaskLauncherRegistry.register('ansible-runner', launcher_class)
    end
  end
end
