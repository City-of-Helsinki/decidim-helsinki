# frozen_string_literal: true

# Modify the proposal content parser because it matches also links to plans and
# other components as well and interprets them as proposals. There is a reported
# bug for this at Metadecidim:
# https://meta.decidim.org/processes/bug-report/f/210/proposals/14311
module Helsinki
  module ProposalParserExtensions
    URL_REGEX_SCHEME = '(?:http(s)?:\/\/)'
    URL_REGEX_CONTENT = '[\w.-]+[\w\-\._~:\/?#\[\]@!\$&\'\(\)\*\+,;=.]+'
    URL_REGEX_END_CHAR = '[\d]'
    URL_REGEX = /#{URL_REGEX_SCHEME}#{URL_REGEX_CONTENT}\/proposals\/#{URL_REGEX_END_CHAR}+/i

    Decidim::ContentParsers::ProposalParser.send(:remove_const, :URL_REGEX_END_CHAR)
    Decidim::ContentParsers::ProposalParser.const_set(:URL_REGEX_END_CHAR, URL_REGEX_END_CHAR)
    Decidim::ContentParsers::ProposalParser.send(:remove_const, :URL_REGEX)
    Decidim::ContentParsers::ProposalParser.const_set(:URL_REGEX, URL_REGEX)
  end
end
