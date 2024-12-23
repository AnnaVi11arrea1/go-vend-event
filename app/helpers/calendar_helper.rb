module CalendarHelper
  def month_calendar(options = {}, &block)
    options[:month_header_class] ||= 'month-name'
    options[:previous_link_class] ||= 'previous-link'
    options[:next_link_class] ||= 'next-link'
    
    SimpleCalendar::MonthCalendar.new(self, options).render(&block)
  end
end
