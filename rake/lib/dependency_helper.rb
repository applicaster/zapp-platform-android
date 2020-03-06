# frozen_string_literal: true

module DependencyHelper
  def dependency_repos
    return unless ENV["dependency_repos"].present?

    JSON.parse(ENV["dependency_repos"]).each_with_object("") do |repo, result|
      result << ",':#{repo}'"
      result << ", ':ViewPagerIndicatorLibrary'" if repo == "applicaster-android-sdk"
    end
  end

  def transitive_excluded_projects
    "\n\t\texclude group:\
    \'com.applicaster\', module: 'applicaster-android-sdk\'\n\t\texclude group:\
    \'com.applicaster\', module: 'zapp-root-android\'\n\t"
  end
  module_function :transitive_excluded_projects
end
