ab_test 'Question responding helpers' do
  alternatives :none, :google_search_link, :bing_results
  metrics :question_posted
  complete_if { true }
  identify { |c| c.identifier }
end
