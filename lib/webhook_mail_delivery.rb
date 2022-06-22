require 'uri'
require 'net/http'
require 'nokogiri'

# WebhookMailDelivery posts emails using a webhook, e.g. to a Discord channel.
#
# It allows staff to then manually send the email, which is useful when regular
# delivery using SMTP is broken.
#
# Special characters in the message are backslash-escaped (this is suitable for
# destinations that render using Markdown-like syntax, such as Discord).
class WebhookMailDelivery
  attr_accessor :settings

  def initialize(values)
    self.settings = values
  end

  def deliver!(mail)
    body_html = mail.body.decoded
    body_text = html_to_plain_text(body_html)
    body_text = body_text.rstrip + "\n.\n" # add a visual separator between messages
    body_escaped = escape_message_for_markdown(body_text)
    post_webhook "To: #{mail.to.join(' ')}\nSubject: #{mail.subject}\n\n#{body_escaped}"
  end

  def html_to_plain_text(html)
    # convert links to plain text
    # e.g. '<a href="https://...">Click here</a>' becomes 'Click here: https://...'
    html = html.gsub(/<a href="([^"]*)">([^<]*)<\/a>/, '\2: \1')
    # strip remaining HTML tags
    Nokogiri::HTML(html).text
  end

  def escape_message_for_markdown(text)
    # replace non-ASCII characters with "?"
    text = text.encode('ascii', :undef => :replace, :invalid => :replace)
    # replace control characters (other than newline, \x0A) with "?"
    text = text.gsub(/[\x00-\x09\x0B-\x1F\x7F]/, '?')
    # backslash-escape all characters except those known to be safe (very conservative)
    text = text.gsub(/[^A-Za-z0-9_ \n]/) {|s| '\\' + s}
    text
  end

  def post_webhook(content)
    uri = URI(Setting.find_by_key("system/mailer/webhook").value)
    data = { "content" => content }
    request = Net::HTTP::Post.new(uri)
    request.body = data.to_json
    request["Content-Type"] = "application/json"
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      response = http.request(request)
      Rails.logger.info "Webhook response status: #{response.inspect}"
      if !response.is_a?(Net::HTTPSuccess)
        Rails.logger.error "Webhook response body: #{response.body.inspect}"
        response.value # to raise an HTTP error
      end
    end
  end
end
