require 'smart_proxy_dynflow/task_launcher/abstract'
require 'smart_proxy_dynflow/task_launcher/single'

module Proxy::Ansible
  module TaskLauncher
    class AnsiblePullSingle < Proxy::Dynflow::TaskLauncher::Single
      def launch!(input, id: nil)
	      input['action_input']['script'] = build_script(input)
	      input['action_class'] = 'Proxy::RemoteExecution::Ssh::Actions::RunScript'
	      super(input, id: id)
      end

      private

      def build_script(input)
        inventory_hash = input['action_input']['ansible_inventory']
        name = input['action_input']['name']
        vars = inventory_hash['_meta']['hostvars']

        # TODO: tags
        # TODO: verbosity
        # TODO: check mode
        # TODO?: secrets

        inventory = { 'all' => { 'hosts' => { name: nil }, 'vars' => inventory_hash['all']['vars'].merge(vars[name]) } }

        <<~SCRIPT
          #!/bin/sh
          
          WORKDIR="$(dirname "$0")"

          base64 -d >"${WORKDIR}/inventory" <<EOF
          #{Base64.strict_encode64(JSON.dump(inventory))}
          EOF

          base64 -d >"${WORKDIR}/playbook" <<EOF
          #{Base64.strict_encode64(input['action_input']['script'])}
          EOF

          # ansible_connection variable has higher precedence than --connection=local
          exec ansible-playbook -e ansible_connection=local --inventory "${WORKDIR}/inventory" "${WORKDIR}/playbook"
        SCRIPT
      end
    end
  end
end
