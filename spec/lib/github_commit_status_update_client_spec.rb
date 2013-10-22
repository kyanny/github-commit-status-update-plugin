require 'spec_helper'
require 'securerandom'

describe GithubCommitStatusUpdateClient do
  let(:github_oauth_token) { SecureRandom.hex }
  let(:owner) { 'jenkins' }
  let(:repo) { 'jenkins.rb' }
  let(:sha) { SecureRandom.hex }
  let(:params) { { target_url: 'http://example.com', description: 'Hello, world!' } }

  subject { described_class.new(github_oauth_token, owner, repo, sha) }

  describe '#initialize' do
    it 'should take 4 arguments' do
      expect { described_class.new }.to raise_error
      expect { described_class.new(github_oauth_token) }.to raise_error
      expect { described_class.new(github_oauth_token, owner) }.to raise_error
      expect { described_class.new(github_oauth_token, owner, repo) }.to raise_error
      expect { described_class.new(github_oauth_token, owner, repo, sha) }.to_not raise_error
    end
  end

  describe '#pending' do
    it "should call #call with 'pending'" do
      expect(subject).to receive(:call).with('pending', params)
      subject.pending(params)
    end
  end

  describe '#success' do
    it "should call #call with 'success'" do
      expect(subject).to receive(:call).with('success', params)
      subject.success(params)
    end
  end

  describe '#error' do
    it "should call #call with 'error'" do
      expect(subject).to receive(:call).with('error', params)
      subject.error(params)
    end
  end

  describe '#failure' do
    it "should call #call with 'failure'" do
      expect(subject).to receive(:call).with('failure', params)
      subject.failure(params)
    end
  end

  describe '#call' do
    it 'should send POST request to api.github.com' do
      http = double.as_null_object
      expect(http).to receive(:request).with { |req| req.is_a?(Net::HTTP::Post) }
      allow(Net::HTTP).to receive(:new) { http }

      subject.call('state')
    end

    it 'should send POST request with Authorization header' do
      http = double.as_null_object
      expect(http).to receive(:request).with { |req| !req['Authorization'].nil? }
      allow(Net::HTTP).to receive(:new) { http }

      subject.call('state')
    end
  end

  describe '#http' do
    it 'should return Net::HTTP instance' do
      expect(subject.http).to be_a(Net::HTTP)
    end

    it 'should be enabled SSL' do
      expect(subject.http.use_ssl?).to be_true
    end
  end

  describe '#uri' do
    it 'should return URI instance' do
      expect(subject.uri).to be_a(URI)
    end

    it 'should contain :owner, :repo and :sha in its path' do
      expect(subject.uri.path).to match(/#{owner}/)
      expect(subject.uri.path).to match(/#{repo}/)
      expect(subject.uri.path).to match(/#{sha}/)
    end
  end
end
