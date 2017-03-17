RSpec.describe Dry::Configurable do
  context 'with nested configuration and a subclass' do
    let(:base_base_klass) do
      Class.new do
        extend Dry::Configurable

        setting :nested do
          setting :thing, 42
        end
      end
    end

    let(:base_klass) do
      Class.new(base_base_klass) do
        setting :unrelated
      end
    end

    shared_examples 'superclass config is not clobbered' do
      it 'reading base class config before' do
        expect(base_klass.config.nested.thing).to eq 42
        expect(klass.config.nested.thing).to eq 3.14
      end

      it 'reading subclass config before' do
        expect(klass.config.nested.thing).to eq 3.14
        expect(base_klass.config.nested.thing).to eq 42
      end

      context 'independent configuration of superclasses' do
        before do
          base_base_klass.config.nested.thing = 84
          base_klass.config.nested.thing = 168
        end

        it 'has all distinct values' do
          expect(base_base_klass.config.nested.thing).to eq 84
          expect(base_klass.config.nested.thing).to eq 168
          expect(klass.config.nested.thing).to eq 3.14
        end
      end
    end

    context 'when setting is configured inside' do
      let(:klass) do
        Class.new(base_klass) do
          configure do |k|
            k.nested.thing = 3.14
          end
        end
      end

      include_examples 'superclass config is not clobbered'
    end

    context 'when setting is configured from outside' do
      let(:klass) do
        Class.new(base_klass)
      end

      before do
        klass.config.nested.thing = 3.14
      end

      include_examples 'superclass config is not clobbered'
    end
  end
end
