    
require 'will_paginate/view_helpers'
WillPaginate::ViewHelpers.pagination_options[:previous_label] = '--page'
WillPaginate::ViewHelpers.pagination_options[:next_label] = 'page++'

