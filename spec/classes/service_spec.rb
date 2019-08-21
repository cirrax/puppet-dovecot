
require 'spec_helper'

describe 'dovecot::service' do
  let :default_params do
    { ensure: 'running',
      enable: true,
      service_name: 'dovecot' }
  end

  shared_examples 'dovecot::service shared examples' do
    it { is_expected.to compile.with_all_deps }

    it 'configures dovecot service' do
      is_expected.to contain_service('dovecot')
        .with_ensure(params[:ensure])
        .with_enable(params[:enable])
        .with_name(params[:service_name])
    end
  end

  context 'with defaults' do
    let :params do
      default_params
    end

    it_behaves_like 'dovecot::service shared examples'
  end

  context 'with non defaults' do
    let :params do
      default_params.merge(
        ensure: 'stopped',
        enable: false,
        service_name: 'tocevod',
      )
    end

    it_behaves_like 'dovecot::service shared examples'
  end
end
