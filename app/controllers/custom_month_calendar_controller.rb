class CustomMonthCalendar < SimpleCalendar::MonthCalendar
  def render(&block)
    content_tag(:div, class: options[:month_header_class]) do
      super(&block)
    end
  end
end
