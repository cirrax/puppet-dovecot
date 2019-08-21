require 'spec_helper'

describe 'dovecot::configfile' do
  let(:pre_condition) { 'service {"dovecot": }' }

  shared_examples 'dovecot::configfile shared examples' do
    context 'it compiles with dependencies' do
      it { is_expected.to compile.with_all_deps }
    end

    context 'it uses concat' do
      it {
        is_expected.to contain_concat(params[:path] + '/' + params[:filename])
          .with_owner(params[:owner])
          .with_group(params[:group])
          .with_mode(params[:mode])
          .with_ensure_newline(true)
          .with_warn(true)
          .with_notify('Service[dovecot]')
      }
    end

    context 'it contains dovecot::config' do
      it {
        is_expected.to contain_dovecot__config(params[:filename])
          .with_file(params[:path] + '/' + params[:filename])
      }
    end

    context 'it includes not include_in fragment' do
      it {
        is_expected.not_to contain_concat_fragment('dovecot: include ' + params[:filename] + ' in ')
      }
    end
  end

  context 'whith defaults' do
    let(:title) { 'with_defaults' }
    let :params do
      { path: '/etc/dovecot',
        owner: 'besitzer',
        group: 'gruppe',
        mode: '4242',
        local_configdir: 'conf.d',
        filename: title }
    end

    it_behaves_like 'dovecot::configfile shared examples'
  end

  context 'whith values' do
    let(:title) { 'with_defaults' }
    let :params do
      { path: '/etc/dovecot',
        owner: 'besitzer',
        group: 'gruppe',
        mode: '4242',
        local_configdir: 'conf.d',
        filename: title,
        values: { 'myval' => 'test' } }
    end

    it_behaves_like 'dovecot::configfile shared examples'

    it {
      is_expected.to contain_dovecot__config(params[:filename])
        .with_values('{"myval"=>"test"}')
    }
  end

  context 'with sections' do
    let(:title) { 'with_defaults' }
    let :params do
      { path: '/etc/dovecot',
        owner: 'besitzer',
        group: 'gruppe',
        mode: '4242',
        local_configdir: 'conf.d',
        filename: title,
        sections: [{ 'mysec' => {} }] }
    end

    it_behaves_like 'dovecot::configfile shared examples'
    it {
      is_expected.to contain_dovecot__config(params[:filename])
        .with_sections([{ 'mysec' => {} }])
    }
  end

  context 'with filename' do
    let(:title) { 'with_filename' }
    let :params do
      { path: '/etc/dovecot',
        owner: 'besitzer',
        group: 'gruppe',
        mode: '4242',
        local_configdir: 'conf.d',
        filename: 'myfilename' }
    end

    it_behaves_like 'dovecot::configfile shared examples'
  end

  context 'with include_in' do
    let(:title) { 'with_include_in' }
    let :params do
      { path: '/etc/dovecot',
        owner: 'besitzer',
        group: 'gruppe',
        mode: '4242',
        include_in: '/include_in',
        local_configdir: 'conf.d' }
    end

    context 'it includes concat_fragment' do
      it {
        is_expected.to contain_concat_fragment('dovecot: include ' + title + ' in ' + params[:include_in])
          .with_target(params[:include_in])
          .with_order('01')
          .with_content(%r{!include })
      }
    end
  end
end
