
module.exports = (robot) ->

  robot.respond /food trucks/i, (msg) ->
    url = "http://www.chicagofoodtruckfinder.com/services/daily_schedule?appKey=bbI9Xb5b"
    emit = ["```"]

    msg.http(url).get() (err, res, body) ->
      return msg.send "Unable to pull today's food truck locations. ERROR:#{err}" if err
      return msg.send "Unable to pull today's food truck locations: #{res.statusCode + ':\n' + body}" if res.statusCode != 200
      daily = JSON.parse(body)
      trucks = daily.trucks
      stops = daily.stops
      locations = daily.locations
      #nearby_stops = [5, 6, 7, 11]
      nearby_trucks = []
      date = new Date
      now = date.getTime()

      for stop in stops
        #if stop.location in nearby_stops && ((new Date(stop.startMillis).getTime() < now) && (new Date(stop.endMillis).getTime() > now))
        if ((new Date(stop.startMillis).getTime() < now) && (new Date(stop.endMillis).getTime() > now))
          nearby_trucks.push(stop)
      for location in locations
        live = []
        for ntruck in nearby_trucks
          if ntruck.location == location.id-1
            for truck in trucks
              if truck.id == ntruck.truckId
                live.push("  #{truck.name} until #{ntruck.endTime}")
        if live.length > 0
          emit.push("Trucks at #{location.shortenedName}")
          emit.push(live.join("\n"))

      if emit.length == 1
        emit.push("Sorry, no food trucks were found.")

      emit.push("```")

      return msg.send emit.join("\n")
