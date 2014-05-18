require 'date'

Event = Struct.new(:name, :date)

class Schedule

  attr_reader :events

  def initialize
    @events = []
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
  case schedule.events.size
  when 0
    puts "Nothing to do.  Perfect!"
  when 1
    puts "Something to do.  Sigh."
  else
    puts "Much too much to do!"
  end
  schedule.events.each do |event|
    puts "#{event.date.strftime("%D")} - #{event.name}"
  end
end

schedule = make_schedule
show_schedule schedule
# => Much too much to do!
# => 01/01/15 00:00 - Mow the lawn
# => 02/01/15 00:00 - Stop watering the lawn
# => 06/01/15 00:00 - Rake up dead lawn
