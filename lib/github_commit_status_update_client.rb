require 'net/https'
require 'uri'
require 'json'
require 'pathname'

# Client for GitHub Commit Status API
class GithubCommitStatusUpdateClient
  GITHUB_API_V3_ENDPOINT = 'https://api.github.com/'

  def initialize(github_oauth_token, owner, repo, sha)
    @github_oauth_token = github_oauth_token
    @owner = owner
    @repo = repo
    @sha = sha
  end

  %w[pending success error failure].each do |state|
    define_method(state) do |params|
      call(state, params)
    end
  end

  # Public:
  #
  # state  - The String of State of the status
  # params - The Hash of optional parameters of Statuses API
  #          :target_url  - Target URL to associate with this status (optional String)
  #          :description - Short description of the status (optional String)
  def call(state, params = {})
    req = Net::HTTP::Post.new(uri.path)
    req['Authorization'] = "token #{@github_oauth_token}"
    req.body = params.merge(state: state).to_json
    http.request(req)
  end

  def http
    @http ||= begin
                http = Net::HTTP.new(uri.host, uri.port)
                http.use_ssl = true
                http.verify_mode = OpenSSL::SSL::VERIFY_NONE
                http
              end
  end

  def uri
    @uri ||= begin
               path = Pathname.new('')
               path += File.join('repos', @owner, @repo, 'statuses', @sha)
               uri = URI.join(GITHUB_API_V3_ENDPOINT, path.cleanpath.to_s)
               uri
             end
  end
end
