# frozen_string_literal: true

module Helsinki
  module MailInterceptors
    # Prevents sending emails to the auto-generated email addresses.
    class GeneratedRecipientsInterceptor
      def self.delivering_email(message)
        return unless @skip_domains
        return unless @skip_domains.is_a?(Array)
        return if @skip_domains.empty?

        # Regexp to match the auto-generated emails
        regexp = /^[^@]+@#{@skip_domains.join("|")}$/

        # Remove the auto-generated email from the message recipients
        message.to = message.to.grep_v(regexp) if message.to
        message.cc = message.cc.grep_v(regexp) if message.cc
        message.bcc = message.bcc.grep_v(regexp) if message.bcc

        # Prevent delivery in case there are no recipients on the email
        message.perform_deliveries = false if message.to.empty?
      end

      def self.configure_domains(*domains)
        @skip_domains = domains
      end
    end
  end
end
