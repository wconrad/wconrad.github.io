require 'date'
require 'delegate'

Event = Struct.new(:name, :date)

class Schedule

  attr_reader :events

  def initialize
    @events = []
  end

end

class DecoratedSchedule < SimpleDelegator

  def burden
    case events.size
    when 0
      "Nothing to do.  Perfect!"
    when 1
      "Something to do.  Sigh."
    else
      "Much too much to do!"
    end
  end

end

class DecoratedEvent < SimpleDelegator

  def format_date
    date.strftime("%D %R")
  end

end

def make_schedule
  schedule = Schedule.new
  schedule.events << Event.new('Mow the lawn', Date.new(2015, 1, 1))
  schedule.events << Event.new('Stop watering the lawn', Date.new(2015, 2, 1))
  schedule.events << Event.new('Rake up dead lawn', Date.new(2015, 6, 1))
  schedule
end

def show_schedule(schedule)
  puts schedule.burden
  schedule.events.each do |event|
    event = DecoratedEvent.new(event)
    puts "#{event.format_date} - #{event.name}"
  end
end

schedule = make_schedule
schedule = DecoratedSchedule.new(schedule)
show_schedule schedule

# => Much too much to do!
# => 01/01/15 00:00 - Mow the lawn
# => 02/01/15 00:00 - Stop watering the lawn
# => 06/01/15 00:00 - Rake up dead lawn
