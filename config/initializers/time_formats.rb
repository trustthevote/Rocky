Date::DATE_FORMATS[:month_day_year] = lambda { |date| "%d/%d/%d" % [date.month, date.mday, date.year] }
Time::DATE_FORMATS[:month_day_year] = lambda { |date| "%d/%d/%d" % [date.month, date.mday, date.year] }
