require 'smart_proxy_dynflow/task_launcher/abstract'
require 'smart_proxy_dynflow/task_launcher/batch'
require 'smart_proxy_ansible/task_launcher/ansible_pull_single'

module Proxy::Ansible
  module TaskLauncher
    class AnsiblePullBatch < Proxy::Dynflow::TaskLauncher::Batch
      def child_launcher(parent)
        AnsiblePullSingle.new(world, callback, :parent => parent)
      end
    end
  end
end
