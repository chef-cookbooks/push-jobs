require 'spec_helper'

describe 'push-jobs::install' do
  context 'with package_url' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '10.04')
      runner.node.set['push_jobs']['package_url'] = 'http://foo.bar.com/opscode-push-jobs-client_1.0.0_amd64.deb?key=value'
      runner.converge('recipe[push-jobs::install]')
    end

    before { @package_file = 'opscode-push-jobs-client_1.0.0_amd64.deb' }

    it 'fetches the push jobs package' do
      expect(chef_run).to create_remote_file "#{Chef::Config[:file_cache_path]}/#{@package_file}"
    end

    it 'installs the chef_ingredient push-client' do
      expect(chef_run).to install_chef_ingredient('push-jobs-client').with(package_source: "#{Chef::Config[:file_cache_path]}/#{@package_file}")
    end

    it 'includes the config recipe' do
      expect(chef_run).to include_recipe("#{described_cookbook}::config")
    end

    it 'starts the opscode-push-jobs-client' do
      expect(chef_run).to start_runit_service 'opscode-push-jobs-client'
      expect(chef_run).to enable_runit_service 'opscode-push-jobs-client'
    end
  end

  context 'without package_url' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '10.04')
      runner.converge('recipe[push-jobs::install]')
    end

    it 'installs the chef_ingredient push-client' do
      expect(chef_run).to install_chef_ingredient('push-jobs-client')
    end

    it 'includes the config recipe' do
      expect(chef_run).to include_recipe("#{described_cookbook}::config")
    end

    it 'starts the opscode-push-jobs-client' do
      expect(chef_run).to start_runit_service 'opscode-push-jobs-client'
      expect(chef_run).to enable_runit_service 'opscode-push-jobs-client'
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end
  end
end
