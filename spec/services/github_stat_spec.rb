require_relative '../rails_helper'

describe GithubStat do
  describe '.contributors' do
    let(:repo_path){ 'foo/bar' }

    subject(:contributors){ described_class.contributors(repo_path) }

    let(:response_status){ 200 }
    let(:response_content_type){ 'application/json; charset=utf-8' }
    let(:response_body){ '{}' }

    let(:http_error){ nil }

    before {
      sr = stub_request :get, /api.github.com/
      if http_error
        sr.to_raise http_error
      else
        sr.to_return(
          status: response_status,
          body: response_body,
          headers: {
            'Content-Type' => response_content_type
          }
        )
      end
    }


    it 'performs GET request to https://api.github.com/repos/:owner/:repo/stats/contributors' do
      contributors
      expect(WebMock).to have_requested(:get, 'https://api.github.com/repos/foo/bar/stats/contributors').once
    end

    context 'on response 200' do
      let(:response_body){
        [
          {author: {login: 'bran'}, total: 34},
          {author: {login: 'jon'}, total: 756}
        ].to_json
      }

      it { should be_ready }

      it 'contains logins of contributors ordered by commits descending' do
        should eq %w(jon bran)
      end
    end

    context 'on response 202' do
      let(:response_status){ 202 }

      it { should_not be_ready }
    end

    context 'on other response' do
      let(:response_status){ 404 }

      it 'raises GithubStat::APIError' do
        expect{ contributors }.to raise_error GithubStat::APIError, /404/
      end
    end

    context 'on http error' do
      let(:http_error){ StandardError.new 'too bad' }

      it 'raises GithubStat::HTTPError' do
        expect{ contributors }.to raise_error GithubStat::HTTPError, /too bad/
      end
    end

  end
end