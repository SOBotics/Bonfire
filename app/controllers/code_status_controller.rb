class CodeStatusController < ApplicationController
  def index
    @gem_versions = Gem::Specification.sort_by{|x| [x.name.downcase, x.version]}.sort_by(&:name)
    @important_gems = [
      "rails",
      "rack",
      "mysql",
      "turbolinks",
      "octokit",
      "passenger",
      "devise"
    ]
  end

  def api
    @repo = Octokit.repository "SOBotics/Bonfire"
    @compare = Octokit.compare "SOBotics/Bonfire", CurrentCommit, @repo[:default_branch]
    @compare_diff = Octokit.compare "SOBotics/Bonfire", CurrentCommit, @repo[:default_branch], accept: "application/vnd.github.v3.diff"
    @commit = Octokit.commit "SOBotics/Bonfire", CurrentCommit
    @commit_diff = Octokit.commit "SOBotics/Bonfire", CurrentCommit, accept: "application/vnd.github.v3.diff"
  end 
end
