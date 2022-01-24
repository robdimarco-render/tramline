class Integrations::Github::Api
  attr_reader :app_id, :installation_id, :jwt, :client

  def initialize(app_id, installation_id)
    @app_id = app_id
    @installation_id = installation_id
    @jwt = Integrations::Github::Jwt.new(@app_id)
    set_client
  end

  def create_branch!(repo, working_branch_name, new_branch_name)
    execute do
      @client.create_ref(repo, "heads/#{new_branch_name}", head(repo, working_branch_name))
    end
  end

  def create_pr!(repo, to, from, title, body)
    execute do
      @client.create_pull_request(repo, to, from, title, body)
    end
  end

  def repos
    execute do
      @client.list_app_installation_repositories
    end
  end

  def head(repo, working_branch_name)
    execute do
      @client.commits(repo, options: {sha: working_branch_name}).first[:sha]
    end
  end

  private

  def execute
    yield
  rescue Octokit::Unauthorized
    set_client
    retry
  end

  def set_client
    client = Octokit::Client.new(bearer_token: jwt.fetch)
    installation_token = client.create_app_installation_access_token(installation_id)[:token]
    @client ||= Octokit::Client.new(access_token: installation_token)
  end
end