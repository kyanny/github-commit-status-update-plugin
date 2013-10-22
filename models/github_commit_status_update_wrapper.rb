require_relative '../lib/github_commit_status_update_client'
require 'stringio'

# Jenkins plugin to call GitHub Commit Status API
class GithubCommitStatusUpdateWrapper < Jenkins::Tasks::BuildWrapper
  display_name 'Commit_status_update build wrapper'

  # Invoked with the form parameters when this extension point
  # is created from a configuration screen.
  def initialize(attrs = {})

  end

  # Perform setup for a build
  #
  # invoked after checkout, but before any `Builder`s have been run
  # @param [Jenkins::Model::Build] build the build about to run
  # @param [Jenkins::Launcher] launcher a launcher for the orderly starting/stopping of processes.
  # @param [Jenkins::Model::Listener] listener channel for interacting with build output console
  def setup(build, launcher, listener)
    # TODO: get git commit sha1 from $GIT_COMMIT environment variable somehow
    sha1 = begin
             workspace = build.send(:native).workspace.to_s
             io_capture = StringIO.new

             cmd = []
             cmd << "cd #{workspace}"
             cmd << 'git rev-parse head'

             launcher.execute('bash', '-c', cmd.join(' && '), { out: io_capture })
             io_capture.string.chomp
           end
    listener.info("SHA1: #{sha1}")
    @client = GithubCommitStatusUpdateClient.new('', 'kyanny', 'test', sha1)
    @client.pending({})
  end

  # Optionally perform optional teardown for a build
  #
  # invoked after a build has run for better or for worse. It's ok if subclasses
  # don't override this.
  #
  # @param [Jenkins::Model::Build] the build which has completed
  # @param [Jenkins::Model::Listener] listener channel for interacting with build output console
  def teardown(build, listener)

  end
end
