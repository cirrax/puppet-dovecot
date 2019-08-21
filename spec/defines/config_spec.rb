require 'spec_helper'

describe 'dovecot::config' do
  shared_examples 'dovecot::config shared examples' do
    context 'it compiles with dependencies' do
      it { is_expected.to compile.with_all_deps }
    end

    context 'it includes concat_fragment' do
      it {
        is_expected.to contain_concat_fragment('dovecot: ' + params[:file] + ' ' + params[:recursion] + ' vals')
          .with_target(params[:file])
          .with_order('50-' + params[:recursion] + '-0')
      }
    end
  end

  context 'whith defaults' do
    let(:title) { 'mytitle' }

    let :params do
      { file: title,
        recursion: '0' }
    end

    it_behaves_like 'dovecot::config shared examples'
  end

  context 'whith non defaults' do
    let(:title) { 'mytitle' }

    let :params do
      { file: 'my filename',
        recursion: '10' }
    end

    it_behaves_like 'dovecot::config shared examples'
  end

  context 'whith trim bigger 0 and sections' do
    let(:title) { 'mytitle' }

    let :params do
      { file: title,
        recursion: '0',
        trim: 2,
        sections: [{ 'mysection2' => {} }],
        values: { 'valname' => 'value' } }
    end

    it_behaves_like 'dovecot::config shared examples'

    it {
      is_expected.to contain_concat_fragment('dovecot: ' + params[:file] + ' ' + params[:recursion] + ' vals')
        .with_content(%r{^  valname = value$})
    }

    context 'it includes section fragments' do
      it {
        is_expected.to contain_concat_fragment('dovecot: ' + params[:file] + ' ' + params[:recursion] + ' 0 start')
          .with_target(params[:file])
          .with_order('50-' + params[:recursion] + '-0-a')
      }
      it {
        is_expected.to contain_concat_fragment('dovecot: ' + params[:file] + ' ' + params[:recursion] + ' 0 end')
          .with_target(params[:file])
          .with_order('50-' + params[:recursion] + '-0-c')
          .with_content('  }')
      }
    end

    context 'it does recursion' do
      it {
        is_expected.to contain_dovecot__config(params[:file] + ' ' + params[:recursion] + '_2_0')
          .with_file(params[:file])
          .with_recursion(params[:recursion] + '-0-b')
          .with_trim('4')
          .with_values('{}')
          .with_sections('[]')
      }
    end
  end

  context 'whith section' do
    let(:title) { 'mytitle' }

    let :params do
      { file: title,
        recursion: '0',
        sections: [{ 'mysection' => {} }],
        values: { 'valname' => 'value' } }
    end

    it_behaves_like 'dovecot::config shared examples'

    it {
      is_expected.to contain_concat_fragment('dovecot: ' + params[:file] + ' ' + params[:recursion] + ' vals')
        .with_content(%r{^valname = value$})
    }

    context 'it includes section fragments' do
      it {
        is_expected.to contain_concat_fragment('dovecot: ' + params[:file] + ' ' + params[:recursion] + ' 0 start')
          .with_target(params[:file])
          .with_order('50-' + params[:recursion] + '-0-a')
      }
      it {
        is_expected.to contain_concat_fragment('dovecot: ' + params[:file] + ' ' + params[:recursion] + ' 0 end')
          .with_target(params[:file])
          .with_order('50-' + params[:recursion] + '-0-c')
          .with_content('}')
      }
    end

    context 'it does recursion' do
      it {
        is_expected.to contain_dovecot__config(params[:file] + ' ' + params[:recursion] + '_2_0')
          .with_file(params[:file])
          .with_recursion(params[:recursion] + '-0-b')
          .with_trim('2')
          .with_values('{}')
          .with_sections('[]')
      }
    end
  end
end
