

require 'spec_helper'

describe 'dovecot' do

  let :default_params do
      { :main_config        => {},
        :configs            => {},
        :main_config_file   => 'dovecot.conf',
        :config_path        => '/etc/dovecot',
        :local_configdir    => 'conf.d',
        :owner              => 'root',
        :group              => 'root',
        :mode               => '0644',
        :include_sysdefault => true,
      }
  end

  shared_examples 'dovecot shared examples' do
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_file( params[:config_path] + '/' + params[:local_configdir] )
      .with_ensure('directory')
      .with_owner( params[:owner])
      .with_group( params[:group])
      .with_mode( '0755' )
    }

    it { is_expected.to contain_concat__fragment('dovecot: include system defaults')
      .with_target(params[:config_path] + '/' + params[:main_config_file] )
      .with_content( '!include conf.d/*')
      .with_order('00')
    }

    it { is_expected.to contain_class('dovecot::install') }
    it { is_expected.to contain_class('dovecot::service') }

    it { is_expected.to contain_dovecot__configfile('main_config')
      .with_filename( params[:main_config_file] )
      .with_path( params[:config_path] )
      .with_local_configdir( params[:local_configdir] )
      .with_owner( params[:owner] )
      .with_group( params[:group] )
      .with_mode( params[:mode] )
      .with_include_in('')
    }

  end

  context 'with defaults' do
    let :params do
      default_params
    end
    it_behaves_like 'dovecot shared examples'

    it { is_expected.to contain_dovecot__configfile('main_config')
      .with_sections('[]')
      .with_values('{}')
    }
  end

  context 'with non default permissions' do
    let :params do
      default_params.merge( 
        :owner              => 'toor',
        :group              => 'toor',
        :mode               => '4460',
      )
    end
    it_behaves_like 'dovecot shared examples'
  end

  context 'with different local_configdir' do
    let :params do
      default_params.merge( 
        :local_configdir    => 'local.d',
      )
    end
    it_behaves_like 'dovecot shared examples'
  end

  context 'with different configpath' do
    let :params do
      default_params.merge( 
        :config_path        => '/somewhere',
      )
    end
    it_behaves_like 'dovecot shared examples'
  end

  context 'with different configfile' do
    let :params do
      default_params.merge( 
        :main_config_file   => 'anotherdovecot.conf', 
      )
    end
    it_behaves_like 'dovecot shared examples'
  end

  context 'with main config values' do
    let :params do
      default_params.merge( 
        :main_config   => { 'values' => { 'val' => 'myval' } }
      )
    end
    it_behaves_like 'dovecot shared examples'

    it { is_expected.to contain_dovecot__configfile('main_config')
      .with_values('{"val"=>"myval"}')
      .with_sections('[]')
    }
  end

  context 'with main config sections' do
    let :params do
      default_params.merge( 
        :main_config   => { 'sections' => [ { 'name' => 'service auth' }] }
      )
    end
    it_behaves_like 'dovecot shared examples'

    it { is_expected.to contain_dovecot__configfile('main_config')
      .with_sections('[{"name"=>"service auth"}]')
      .with_values('{}')
    }
  end

  context 'with local configs' do
    let :params do
      default_params.merge( 
        :configs   => { 'myconfig' => { 'values' => { 'blah' => 'fasel' }}},
      )
    end
    it_behaves_like 'dovecot shared examples'

    it { is_expected.to contain_dovecot__configfile('myconfig')
      .with_path( params[:config_path] + '/' + params[:local_configdir] )
      .with_local_configdir( params[:local_configdir] )
      .with_owner( params[:owner] )
      .with_group( params[:group] )
      .with_mode( params[:mode] )
      .with_include_in( params[:config_path] + '/' + params[:main_config_file] )
    }
  end

  context 'without including system defaults ' do
    let :params do
      default_params.merge( 
        :include_sysdefault => false,
      )
    end

    it { is_expected.to_not contain_concat__fragment('dovecot: include system defaults') }
  end
end
