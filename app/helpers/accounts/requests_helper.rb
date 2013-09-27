module Accounts::RequestsHelper
  @@request_display = {
    ['Group','invite','User'] => {
      description: lambda { |request| "<b>#{link_to(h(request.requester.username), request.requester)}</b> invites #{current_user == request.subject ? 'you' : link_to(h(request.subject.username), request.subject)} to join the group <b>#{permitted_to?(:show, request.object) ? link_to(h(request.object.name), request.object) : h(request.object.name)}</b>" },
      accept: lambda { |request| accept_members_group_path(request.object, request) },
      reject: lambda { |request| reject_members_group_path(request.object, request) },
    }
  }

  def request_description request
    format = request_display_format(request)
    if format.nil?
      raw "Request #{h request.object_type.downcase} <b>#{request.object_id}</b> #{h request.verb.downcase} #{h request.subject_type.downcase} <b>#{request.subject.id}</b>"
    else
      raw instance_exec(request, &format[:description])
    end
  end

  def accept_request_path request
    format = request_display_format(request)
    if format.nil?
      nil
    else
      instance_exec(request, &format[:accept])
    end
  end

  def reject_request_path request
    format = request_display_format(request)
    if format.nil?
      nil
    else
      instance_exec(request, &format[:reject])
    end
  end

  def link_to_accept_request request
    link = accept_request_path request
    if link.nil?
      "Accept (No link)"
    else
      link_to 'Accept', link, :method => :put
    end
  end

  def link_to_reject_request request
    link = reject_request_path request
    if link.nil?
      "Reject (No link)"
    else
      link_to 'Reject', link, :method => :put
    end
  end

  def request_display_format request
    @@request_display[[request.object_type, request.verb, request.subject_type]]
  end
end
