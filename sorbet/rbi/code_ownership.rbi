# typed: true

# Tried generating this file using tapioca but it pulled in a lot of additional dependencies and complexity that
# caused errors in the Sorbet type check oputput.

# source://code_ownership//lib/code_ownership/mapper.rb#5
module CodeOwnership
  requires_ancestor { Kernel }

  class << self
    # @param file [String]
    # @return [CodeTeams::Team, nil]
    #
    # source://code_ownership//lib/code_ownership.rb#30
    def for_file(file); end
  end
end
