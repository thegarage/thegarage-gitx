require 'thor'
require 'thegarage/gitx'
require 'thegarage/gitx/cli/base_command'

module Thegarage
  module Gitx
    module Cli
      class IntegrateCommand < BaseCommand
        desc 'integrate', 'integrate the current branch into one of the aggregate development branches (default = staging)'
        def integrate(target_branch = 'staging')
          run_cmd "git pull origin #{current_branch.name}", :allow_failure => true
          run_cmd "git pull origin #{Thegarage::Gitx::BASE_BRANCH}"
          run_cmd 'git push origin HEAD'

          branch = current_branch.name
          assert_not_protected_branch!(branch, 'integrate') unless aggregate_branch?(target_branch)
          raise "Only aggregate branches are allowed for integration: #{AGGREGATE_BRANCHES}" unless aggregate_branch?(target_branch) || target_branch == Thegarage::Gitx::BASE_BRANCH
          say "Integrating "
          say "#{branch} ", :green
          say "into "
          say target_branch, :green

          refresh_branch_from_remote target_branch
          run_cmd "git pull . #{branch}"
          run_cmd "git push origin HEAD"
          run_cmd "git checkout #{branch}"
        end

        private

        # nuke local branch and pull fresh version from remote repo
        def refresh_branch_from_remote(target_branch)
          run_cmd "git branch -D #{target_branch}", :allow_failure => true
          run_cmd "git fetch origin"
          run_cmd "git checkout #{target_branch}"
        end
      end
    end
  end
end
