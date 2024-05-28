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

        # We leverage process substitution to create "temporary files which don't stick around"
        # If the pull provider would set up a directory for us to write into, we could just write those files out, exec into ansible-playbook and rely on the pull provider to wipe the directory afterwards. This way we wouldn't use an bash specific features and we could use posix sh instead.
        <<~SCRIPT
          #!/bin/bash
          # We need to force the inventory plugin. Ansible attempts to autodetect the format, but each attempt reads the file again from the start, which doesn't really work when the inventory is piped in
          export ANSIBLE_INVENTORY_ENABLED=yaml

          # ansible_connection variable has higher precedence than --connection=local
          exec ansible-playbook -e ansible_connection=local --inventory <(base64 -d <<EOF
          #{Base64.strict_encode64(JSON.dump(inventory))}
          EOF
          ) \
          <(base64 -d <<EOF
          #{Base64.strict_encode64(input['action_input']['script'])}
          EOF
          )
        SCRIPT
      end
    end
  end
end
