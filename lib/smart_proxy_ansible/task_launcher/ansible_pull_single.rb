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

        # We need to force local connection. We force it with a parameter passed
        # to ansible-playbook, but this host variable would override it if left
        # there.
        vars[name].delete('ansible_connection')
        inventory = { 'all' => { 'hosts' => vars }, 'vars' => inventory_hash['all']['vars'] }
        <<~SCRIPT
          #!/bin/bash
          export ANSIBLE_INVENTORY_ENABLED=yaml

          exec ansible-playbook -c local --inventory <(cat | base64 -d <<EOF
          #{Base64.strict_encode64(JSON.dump(inventory))}
          EOF
          ) \
          <(cat | base64 -d <<EOF
          #{Base64.strict_encode64(input['action_input']['script'])}
          EOF
          )
        SCRIPT
      end
    end
  end
end
