require_relative '../rails_helper'

describe RepoController do
  describe 'GET index' do
    let(:github_stat_error){ nil }
    let(:github_stat_result){ double :github_stat_result }

    before {
      allow(GithubStat).to(
        receive(:contributors).tap{|r|
          if github_stat_error
            r.and_raise github_stat_error
          else
            r.and_return github_stat_result
          end
        }
      )
    }

    def self.it_does_not_get_stats
      it 'does not get stats' do
        expect(GithubStat).to_not have_received(:contributors)
        expect(assigns(:result)).to be_nil
      end
    end

    context 'without params' do
      before { get :index }

      it 'is OK' do
        expect(response.status).to eq 200
      end

      it_does_not_get_stats
    end

    context 'with :address param' do
      let(:raises_error){ false }

      before { 
        unless raises_error
          get :index, params: {address: address}

          # во всех случаях ответ должен быть ОК
          expect(response.status).to eq 200
        end
      }      

      context 'when address is blank' do
        let(:address){ '' }

        it_does_not_get_stats

        it 'does not fill @error' do
          expect(assigns(:error)).to be_nil
        end
      end

      def self.it_says_the_address_is_invalid
        it_does_not_get_stats

        it 'fills @error' do
          expect(assigns(:error)).to be_present
        end
      end

      context 'when address is malformed' do
        let(:address){ 'grsfgh' }

        it_says_the_address_is_invalid
      end

      context 'when address does not belong to Github' do
        let(:address){ 'https://bitbucket.org/foo/bar' }

        it_says_the_address_is_invalid
      end

      context 'when address belongs to Github' do
        let(:address){ 'https://github.com/foo/bar' }

        it 'calls GithubStat.contributors with repo path' do
          expect(GithubStat).to have_received(:contributors).with('foo/bar')
        end

        it 'assigns GithubStat.contributors result to @contributors' do
          expect(assigns(:contributors)).to eq github_stat_result
        end

        it 'does not fill @error' do
          expect(assigns(:error)).to be_nil
        end

        context 'when address is not SSL' do
          let(:address){ 'http://github.com/foo/bar' }

          it 'is acceptable' do
            expect(GithubStat).to have_received(:contributors).with('foo/bar')
            expect(assigns(:error)).to be_nil
          end
        end

        context 'when address includes www subdomain' do
          let(:address){ 'https://www.github.com/foo/bar' }

          it 'is acceptable' do
            expect(GithubStat).to have_received(:contributors).with('foo/bar')
            expect(assigns(:error)).to be_nil
          end
        end

        context 'when GithubStat.contributors raises error' do
          context 'GithubStat::Error' do
            let(:github_stat_error){ GithubStat::Error.new 'terrible mistake' }

            it 'assigns error message to @error' do
              expect(assigns(:error)).to include 'terrible mistake'
            end
          end

          context 'other error' do
            let(:raises_error){ true }
            let(:github_stat_error){ StandardError.new }

            it 'raises the error' do
              expect{ get :index, params: {address: address} }.to raise_error github_stat_error
            end
          end
        end
      end
    end
  end


end