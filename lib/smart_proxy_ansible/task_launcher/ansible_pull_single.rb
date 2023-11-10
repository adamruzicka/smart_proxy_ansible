require 'smart_proxy_dynflow/task_launcher/abstract'
require 'smart_proxy_dynflow/task_launcher/single'

module Proxy::Ansible
  module TaskLauncher
    class AnsiblePullSingle < Proxy::Dynflow::TaskLauncher::Single
      def launch!(input, id: nil)
	input['action_input']['script'] = "#!/usr/bin/env -S ansible-playbook -c local -i,localhost\n" + input['action_input']['script']
	input['action_class'] = 'Proxy::RemoteExecution::Ssh::Actions::RunScript'
	super(input, id: id)
      end
    end
  end
end
