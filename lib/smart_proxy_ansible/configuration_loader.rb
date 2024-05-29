module Proxy::Ansible
  class ConfigurationLoader
    def load_classes
      require 'smart_proxy_dynflow'
      require 'smart_proxy_dynflow/continuous_output'
      require 'smart_proxy_ansible/task_launcher/ansible_runner'
      require 'smart_proxy_ansible/task_launcher/ansible_pull_batch'
      require 'smart_proxy_ansible/runner/ansible_runner'
    end
  end
end
