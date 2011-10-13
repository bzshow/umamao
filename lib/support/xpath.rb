module Support
  module Xpath
    def case_insensitive_xpath(string)
      "translate(@name,'#{('A'..'Z').to_a.to_s}'," <<
      "'#{('a'..'z').to_a.to_s}')='#{string}'"
    end
  end
end
