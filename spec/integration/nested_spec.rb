RSpec.describe Dry::Configurable do
  context 'with nested configuration' do
    let(:base_klass) do
      Class.new do
        extend Dry::Configurable

        setting :nested do
          setting :thing, 'from base klass'
        end
      end
    end

    let(:klass) do
      Class.new(base_klass) do
        configure do |k|
          k.nested.thing = 'from klass'
        end
      end
    end

    let(:other_klass) do
      Class.new(base_klass) do
        configure do |k|
          k.nested.thing = 'from other klass'
        end
      end
    end

    it 'subclasses do not clobber each other' do
      # expect(base_klass.config.nested.thing).to eq 'from base klass'
      expect(klass.config.nested.thing).to eq 'from klass'
      expect(other_klass.config.nested.thing).to eq 'from other klass'

      # the following fails, as it has been then changed by the configure block
      # of other_klass.
      expect(klass.config.nested.thing).to eq 'from klass'
    end

    it 'subclasses respect superclass own config' do
      expect(base_klass.config.nested.thing).to eq 'from base klass'
      expect(klass.config.nested.thing).to eq 'from klass'

      # the following fails, as it has been then changed by the configure block
      # of klass.
      expect(base_klass.config.nested.thing).to eq 'from base klass'
    end
  end
end
